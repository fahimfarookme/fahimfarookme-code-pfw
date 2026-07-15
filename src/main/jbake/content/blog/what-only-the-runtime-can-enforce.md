title=What only the runtime can enforce
date=2026-07-01
type=post
tags=thesis, open-jdk, eliya, asymm
status=draft
subtitle=Answering common questions
description=Answering common questions stemming from the policy placement argument for Eliya JDK
~~~~~~

I built an OpenJDK distribution called [Eliya](https://asymm.systems/product/eliya), and wrote the thesis version of the idea for Foojay - [Where production policy belongs](https://foojay.io/today/where-production-policy-belongs-building-eliya-in-public/). InfoQ also covered the [the launch](https://www.infoq.com/news/2026/06/eliya-jvm-diagnostic-profile/).

Four questions kept coming up in response to the argument. Here are the precise answers, along with the research they rest on and the limits I'd want a sceptical reader to hold me to.

## The boundary, and the science behind it

Every configurable system has two spaces. 
- The **configuration space** is every behaviour you can reach by turning the knobs the system already exposes. 
- The **implementation space** is the residu - the behaviour that that requires someone to change the
internals.

A wrapper script, a helm chart, an admission webhook, a `-javaagent` compose external behaviour around the JVM. They do far more than configuring a JVM i.e. picking a JVM flag, but they all operate in the configuration space, and they all hit a floor: they cannot reach the implementation space. A wrapper can't rewrite the heap-dump byte stream as that stream is being written. It can't tell you whether a flag's value came from the command line or from the runtime's own ergonomics. Even a JVMTI agent — the strongest external case,
running inside the JVM's address space — acts through the runtime's *published*
extension points, not its internals.

That much is just an observation. The argument that gives it force is the
**end-to-end argument** (Saltzer, Reed & Clark, *End-to-End Arguments in System
Design*, ACM TOCS 1984). Their claim, stripped to its core: a function can be
completely and correctly implemented only at the layer that has the knowledge and
the position to implement it; a lower or outer layer can provide, at best, an
*incomplete* version. Their canonical example is reliable file transfer — the
end-to-end correctness check has to live at the endpoints, because no amount of
per-hop reliability in the network actually guarantees the file arrived intact. The
network can help; it cannot finish the job.

Apply that to a process boundary instead of a network. A policy that depends on
state internal to a running JVM — the live object graph, the bytes a dump writer is
about to emit, the resolved origin of a setting, whether a crypto call inside a
third-party library used an approved algorithm — can be *completely* implemented
only by the layer with that knowledge and position, which is the runtime itself. An
external layer can provide an incomplete version: it can act before or after the
fact, it can constrain what it can see, it can configure defaults. What it cannot do
is stand inside the process at the moment the internal state exists. The end-to-end
argument is usually read as a reason to push functions *outward*, to the endpoints.
Read correctly it's directional in both senses: it says a function belongs at the
layer with complete knowledge, and sometimes — rarely, specifically — that layer is
further *in*, not further out.

I want to be exact about the limit, because this is where the argument is easy to
abuse. Separating policy from mechanism (the HYDRA paper named that separation in
1975) does **not** mean policy has to live inside the mechanism. Most systems
externalise their policy correctly and should: Kubernetes pushes authorisation to
admission controllers, applications delegate access decisions to IAM, a service mesh
owns mTLS. I cannot and do not claim "policy belongs in the runtime." The claim is
narrower and harder to dispute: *some* policies depend on what only the runtime can
see or do, and for those, externalising the enforcement isn't a style preference —
it produces an incomplete control. The formal version I used on Foojay states it as
a set: let `B` be the behaviours external controllers can produce, and `B'` the
behaviours that depend entirely on runtime-internal state. Every wrapper or webhook
is a selector inside `B`. A `B'` behaviour can be obtained only by changing the
runtime. So the policy targeting `B'` is, narrowly, the one that belongs in the VM.
`B'` is just the end-to-end argument's "functions the outer layer can only implement
incompletely," named for this specific boundary.

## What puts a behaviour in B': two gates

"Depends on runtime-internal state" is the intuition; it isn't yet a test. Here is
the test. A control falls into `B'` — can only be made complete inside the JVM — when
it trips one of exactly two **capability gates**. They aren't a feature list; they
are the only two ways an external layer loses the ability to enforce a value at all.

**Reach.** The behaviour has no external surface to act on, so the runtime is the
only place to stand. This takes three forms. *Acting before exposure* — a native
diagnostic writer emits cleartext as it streams, so any external tool can only touch
the artefact after it already exists on disk; the leak has happened by the time the
outer layer can act. *Controlling memory lifecycle* — the runtime owns allocation and
garbage collection, so the existence, location, and erasure of a secret in the
managed heap are governed from inside. *Attesting internal state* — only the runtime
can vouch for its own resolved configuration; an external observer can sign what it
*saw*, not what was internally *true*.

**Non-overridability.** A surface exists, but a force inside the process can override
the configured value, and only the runtime can make the value hold. Two such forces:
application or library code at runtime (a call that re-registers a crypto provider, or
constructs its own connection with a weak protocol), and a later-resolved launch input
winning flag precedence (a value injected through `JAVA_TOOL_OPTIONS` or a baked-in
entrypoint, after the reviewed spec). The decisive question here is not whether the
value is *settable* from outside — it usually is — but whether it can be *enforced*
from outside against unaudited in-process code. Where it can't, the runtime is
necessary even though the knob is externally visible. "Settable" and "enforceable" are
not the same property, and most of the confusion in this area comes from conflating
them.

That gives a clean rule for the layering question — *how do you decide what belongs in
Kubernetes or the mesh versus the JVM?* The honest answer is a default and an exception. The default: if a requirement
can be fully enforced outside the JVM, it should be, because coupling a concern to the
runtime when an outer layer can own it is bad design. Network identity, authorisation
between services, resource limits, image provenance, secrets injection — these cross
the process boundary, and the platform owns them; Eliya doesn't compete there. The
next layer down is ordinary JVM configuration — heap sizing, GC selection, enabling
flags — which belongs in a wrapper or an opinionated default, not a patch. The
exception is the residue that trips a gate: the bytes a writer emits, whether the JVM
should start, the origin of a resolved value, whether an in-process override can be
refused. The membrane is the whole picture in one line — Kubernetes governs what
*crosses* the process boundary; the runtime governs what happens *inside* one process.
A mesh enforcing mTLS has no view of which crypto provider a library loaded internally;
a seccomp profile can't redact a `.hprof`; a network policy can't refuse a
`Security.addProvider` call. The two layers are complements, and neither can do the
other's job.

There's a third dimension, and it's orthogonal to the two gates, so I keep it
separate to avoid the temptation to fold everything into one grand scheme. **Authority**
is about *who owns the constraint*, not who is trying to change it. An operator-owned
constraint serves the operator's own goal — diagnosability, say — so an operator who
overrides it is entitled to, and the runtime should yield. A regulator-owned
constraint serves an external party the operator can't speak for, so a conflicting
override is refused and the runtime fails closed. The same mechanism can sit on either
side: setting a heap-dump path is permitted under an operational profile and refused
under a compliance profile, because the *owner* changed, not the mechanism. The gates
decide whether a control can live only in the JVM; authority decides, for the ones that
do, whether enforcement is rigid or set-and-step-aside.

## The cases, and what each one actually costs

The first question is the concrete one — *give me real scenarios where the external
approach proves insufficient, and say why the fix had to move inside.* The cases below
are grouped by the gate they trip. Two cautions first, both of which I'd
rather state than have a reader catch. Eliya ships in phases; Phase 1 is shipped today
and is overwhelmingly opinionated defaults, while several cases below are roadmap, and
I mark which. And the standards back these cases to *different* degrees — some mandate
the outcome, some only an objective the runtime serves better — a distinction I'll come
back to, because it's where the argument has to be honest to survive a knowledgeable
reader.

**A heap dump writes live secrets to disk.** PCI DSS v4 Requirement 3.5.1 says a PAN
must be unreadable anywhere it is stored. A heap dump of a payment service writes live
card numbers to disk in cleartext. You can handle this from outside: disable heap dumps,
or encrypt the volume, or sanitise the dump after capture. Look at what each costs.
Disabling dumps throws away the forensic evidence that was the reason to run with them.
Volume encryption protects the disk at rest but the dump still travels cleartext from
memory to the writer, inside the trust boundary, and decrypts transparently to anything
with filesystem access — PCI is explicit that disk encryption alone does not render a
PAN unreadable. Post-capture sanitisation runs *after* the cleartext is already on disk;
the exposure the standard forbids has already occurred. Redacting the dump *as the stream
is written*, inside the writer, removes the dilemma instead of trading one risk for
another. This is a `heapDumper.cpp` problem; you cannot compose it from existing flags.
And it is not a hypothetical fix that only a vendor would attempt: OpenJDK itself
proposed exactly this (JDK-8337517, *Redacted Heap Dumps*, adding `-XX:+HeapDumpRedacted`
to zero field values as the dump streams) and **withdrew it for lack of upstream
consensus**. The gap is real, acknowledged, and currently open.

**A flight recording carries secrets off-host.** This is the strongest external evidence
that the reasoning is sound, because it isn't mine. JEP 536, *JFR In-Process Data
Redaction*, is targeted for JDK 27, and its rationale reads almost exactly like the
argument above: the existing post-hoc `jfr scrub` is repetitive and error-prone,
unredacted artefacts exist until scrubbing completes, copies can be left in temporary
locations if the JVM crashes, and streamed data can leave the host unredacted — so the
fix is in-process, secure-by-default redaction. OpenJDK reached the same conclusion I
did, for this class, in their own words. Two honest notes. It validates *this class* —
the exposure-before-external-action form of Reach — not everything Eliya does. And since
it lands in JDK 27, the JDK 25 LTS line, where regulated estates sit for years, doesn't
get it without a backport; bringing the in-process approach to the LTS line is the
contribution, not inventing it.

**A crash log leaks the environment.** The fatal-error handler writes `hs_err_pid` during
the crash itself — the command line, the `-D` properties that often carry secrets, the
process environment, stack and register memory — to a file that's typically
world-readable. On a terminating container there may be no guaranteed "after" in which to
run a cleanup step. Redaction has to happen inside the fatal-error handler as the file is
written. JEP 536 doesn't cover this — it's JFR-only — so as far as I know this is a
distinct, unfilled gap.

**Proving what actually ran.** An auditor wants evidence that a process ran in the
approved configuration, not a runbook asserting it should have. The launch command shows
what was *passed*, not what the JVM *resolved* — environment variables, properties files,
and ergonomics all change the effective value. HotSpot can expose the resolved values and
their origin via `-XX:+PrintFlagsFinal`, so this is *not* an observability gap, and I had
to correct myself on exactly this point: the information isn't trapped inside. The gap is
that `PrintFlagsFinal` is unsigned, opt-in stdout the workload controls, covers only `-XX`
flags, and carries no proof it came from the real process. Only the runtime can
*authentically attest* its own resolved state — a sidecar can sign what it observed, not
vouch for what was internally true. Eliya's roadmap contribution is a signed attestation
of the full posture (approved-mode state, active provider and certificate, integrity
result, the profile's flag values with origin), bound to the process. And here is the
limit a security reviewer will press, so I'll press it first: a software runtime signing
its own state has a trust floor. The signature proves "something holding this key produced
this," not "this is true" — a compromised or counterfeit runtime holding the key could
sign a false record. Self-attestation is only as strong as the key's anchoring; the strong
form anchors the signing key outside the process, in a TPM, a TEE, or a cloud instance
identity, with a verifier nonce for freshness. It is better than unsigned stdout, and it
is not magic.

The next two cases trip Non-overridability rather than Reach, and they're where the
standards-backing distinction bites.

**A reviewed posture has to actually hold at runtime.** PCI Req 12, SOX ITGC, and NIST
800-53 CM-6 require controlled, enforced configuration. An admission controller validates
the *declared pod spec*; it does not see the *effective* configuration the JVM resolves at
startup, which `JAVA_TOOL_OPTIONS`, a baked-in entrypoint, or flag precedence can shift.
If those channels aren't governed as tightly as the spec, the reviewed intent and what
actually ran diverge, and nothing outside the process notices. Eliya can evaluate the
final resolved configuration during startup and fail closed if it conflicts with an active
compliance profile. But notice what the standard actually requires: the *objective*
(enforced configuration), not this *mechanism*. So the honest claim isn't "the standard
requires the JVM to fail closed" — it's "this meets the enforced-configuration objective
more reliably than a control that can't see the effective state." That's a stronger
mechanism for a real objective, not a mandate, and pretending otherwise would be the kind
of overstatement a careful auditor dismantles.

**Crypto has to stay approved even against the application's own code.** This one the
standard *does* mandate at the outcome level, and it's worth a section of its own.

## The FIPS case, in more depth than fits an interview

Here is a fact that surprises most people who haven't been through a FIPS audit: **no
JDK binary is FIPS-validated.** It can't be, structurally. The NIST Cryptographic Module
Validation Program validates cryptographic *modules* — a specific, version-pinned unit of
crypto, whose boundary is welded to its exact bytes by a self-test (typically an HMAC the
module computes over itself at startup). A JDK is not a cryptographic module; it's a whole
runtime that patches quarterly. What a JDK can legitimately do is operate in a documented
FIPS *approved mode* that *delegates* to a validated module — and the right question to ask
any vendor claiming "FIPS" is which CMVP certificate number their approved mode delegates
to, and whether that certificate is still active. "Approved mode" itself has a precise
meaning: the module is using only FIPS-approved algorithms *and* has passed its power-on
self-tests, including the integrity self-test. So "FIPS-validated JDK" is a category error;
"approved mode delegating to certificate #X" is the real, defensible thing.

Now the enforcement problem. FIPS — via FISMA, FedRAMP, and NIST 800-53 SC-13 — requires
that only approved cryptography run. You can configure that: set the provider order in
`java.security`, disable weak algorithms in `jdk.tls.disabledAlgorithms`. But the Java
Cryptography Architecture is *designed* to be extended at runtime. Any code can call
`Security.addProvider` to register a non-approved provider, or construct an `SSLContext`
that enables a weak protocol, and nothing fails — the JVM silently uses the non-approved
path. The configuration sets a default; it does not enforce an invariant against the
application's own code. With the SecurityManager permanently disabled (JEP 486, JDK 24),
there isn't even a policy mechanism left to restrict this from inside the standard surface. So enforcing
approved-mode-that-holds is a Non-overridability case: only the runtime can refuse the
bypass at the point it's attempted.

There's a second axis the usual solution gets wrong. On Red Hat you can switch the whole
OS into FIPS mode — a system-wide crypto policy plus a kernel flag — and the JVM picks up
the OS's validated crypto automatically. That works, but it ties your compliance to that
operating system. Move the workload to a different base image — Ubuntu, Alpine, a
distroless image — and the enforcement is gone. For a fleet that runs the same service on
a dozen base images, OS-coupled FIPS is enforcement you can't carry with you. Building the
enforcement into the runtime instead — shipping the validated module wired in as the active
provider, and making a non-approved algorithm or weak-TLS attempt fail rather than silently
succeed — behaves identically on any base image, so compliance stops depending on the OS.
That portability, plus refusing the in-process bypass, is the part a wrapper and an OS flag
can't jointly provide. (This is Phase 2 on the roadmap; I'm describing the design, not
claiming it shipped.)

## Migrating to it

The third question was practical — *what changes for developers and operations when they
switch?* Outside the opt-in profile, Eliya stays deliberately close to upstream OpenJDK, so
adopting it is a distribution-level drop-in, the same kind of move as switching between
Temurin, Corretto, and Zulu, because that's what it is. For developers, effectively nothing
in day-to-day code: no new language features, no API differences, no build changes; existing
libraries and frameworks work unchanged.

For operations, three things change, and the third is the one to understand before rollout.
A single opt-in flag, `-XX:EliyaProfile=Production`, sets a coherent group of
production-readiness ergonomics — the per-service "what flags should be on" list, usually
written after a team's first incident, shipped as one intent-level control. Every flag is
still settable by hand; the profile just means you don't have to. Diagnostic output moves to
predictable, structured, per-service paths instead of wherever the container happened to
start. And the override semantics carry the authority distinction from earlier: under
`Production`, normal JVM precedence holds and a command-line value beats the profile's
ergonomic value, because the profile's constraints are operational and the operator owns the
goal — `Production` yields. Under a future compliance profile this inverts on purpose: where
a constraint is regulator-owned, a conflicting override is refused at startup and the JVM
fails closed. The useful side effect is that turning on a compliance profile surfaces latent
non-compliance as a refused startup — you find out where you were non-compliant before an
auditor does.

## Innovation without divergence

The fourth question is the one enterprises actually worry about — *you patched OpenJDK; how do
you keep behaviour predictable across releases?* The answer is about *where* the changes live.
The Java SE specification, validated by the TCK, fixes the semantics — the language, the
bytecode, the API contracts. It deliberately leaves other things to the implementation: the
*default values* of tunable flags, and the configuration of the crypto provider framework.
Eliya's changes live in that implementation-defined space, not in the semantics. A conformant
program behaves identically; what differs is the default posture and, on the roadmap, the
opt-in enforcement. `java.security` is bit-identical to upstream — TLS 1.0/1.1 already disabled,
weak ciphers already blocked. GC selection is left to JDK 25's own ergonomics. We've applied for
TCK access from Oracle and intend to ship TCK-verified, so "predictable behaviour" becomes an
attested property rather than my assertion.

Two design choices keep it from drifting. New capability attaches at one named opt-in flag as
new *values*, never by changing how an existing flag behaves — so an operator who sets nothing,
or sets `EliyaProfile=None`, gets upstream behaviour exactly. And the distribution tracks
upstream on the quarterly Critical Patch Update cadence within a fixed window of each GA, so
security fixes arrive on a known schedule and the Eliya layer rides on top instead of forking
away from it. One clarification I'd make to anyone who reads "fails closed" as
unpredictability: predictability is not permissiveness. A profile that always yields would be
predictable and useless for compliance; a profile that refuses a conflicting, opted-into
constraint is *equally* predictable and actually enforces the intent. Failing closed on a
documented contract isn't a surprise change to behaviour — it's the system doing exactly what
it was told.

## The honest boundaries

A research-oriented claim earns trust by stating where it stops, so here are the four limits I
hold this argument to.

The standards back the cases unevenly, and the distinction matters. Two of them mandate the
*outcome*: PCI 3.5.1 ("PAN unreadable wherever stored") and the FIPS-via-FISMA/FedRAMP mandate
("only approved crypto may run"). For those, the standard requires the result and the runtime is
the necessary mechanism — that's not overstatement. The fail-closed-on-conflict and attestation
cases serve an *objective* the standards state (controlled, auditable configuration) without
mandating the mechanism. For those the honest framing is "a stronger mechanism that closes a gap
the outer layer can't see," never "the standard requires this." Collapsing the two kinds together
is the easiest way to lose a knowledgeable reader.

Self-attestation has a trust floor, as above: software signing its own state is only as strong as
the key's anchoring, and the strong form reaches for hardware or instance identity. I'd rather say
that than imply a software runtime can prove its own integrity unconditionally.

Every enforcement case assumes the team runs Eliya at all — and an application team can choose a
different JDK. That isn't a hole in the argument; it's where the argument points. These controls
belong at the JDK a *platform team standardises on*, because they do in-process what the platform's
own tools — admission control, mesh, seccomp — structurally cannot reach, and the attestation
primitive is what proves which runtime actually ran. Eliya asks nothing of the application team; it
gives the platform team enforcement-plus-proof their existing controls can't provide. A platform
team can standardise on a wrapper too, of course — but a wrapper hits the same gate wall, so
standardising on the runtime is the version that can also do the `B'` things.

And some of what makes Eliya useful today is a wasting asset, which is worth admitting in the same
breath as claiming it. The reach into old enterprise Linux that a low glibc floor buys, for
instance, is real across the JDK 25 acquisition window and gone after it; if Eliya is still
positioning on it at the next LTS, that means the durable part — the compliance enforcement above
— didn't get built. I'd want to be measured against the durable claim, not the temporary one.

What would falsify the core thesis? If you could exhibit an external mechanism that redacts a heap
dump *before* cleartext reaches disk, completely and without relocating the exposure into another
process, the Reach gate's exposure-window form would collapse for that case. If a future JVM exposed
a stable, non-overridable surface for the crypto-provider invariant, the FIPS case would move out of
`B'` and into ordinary configuration — and I'd happily ship a wrapper instead. The argument isn't
that the JVM is special in principle; it's that, for a specific and characterisable set of policies,
the runtime is currently the only layer with complete knowledge and position. Name a layer that
gets both, and the policy moves there. That's the end-to-end argument working as intended, and it's
the test I'd want applied to my own claims.

---

*Eliya is an OpenJDK 25 LTS distribution from Asymm Systems, built for compliance-conscious
production in regulated industries. The engineering — reproducible builds, the glibc floor, release
signing, the one source patch Phase 1 shipped — is being written up piece by piece on Foojay;
[part 1, the thesis, is here](https://foojay.io/today/where-production-policy-belongs-building-eliya-in-public/).*

---

### References

- Saltzer, Reed & Clark, "End-to-End Arguments in System Design", *ACM Transactions on Computer
  Systems* 2(4), 1984
- Levin, Cohen, Corwin, Pollack & Wulf, "Policy/Mechanism Separation in HYDRA", SOSP 1975
- Saltzer & Schroeder, "The Protection of Information in Computer Systems", *Proc. IEEE* 63(9), 1975
- Johnson & Goldstein, "Do Defaults Save Lives?", *Science* 302, 2003
- Yin et al., "An Empirical Study on Configuration Errors in Commercial and Open Source Systems",
  SOSP 2011
- Xu et al., "Hey, You Have Given Me Too Many Knobs!", ESEC/FSE 2015
- JEP 536, "JFR In-Process Data Redaction" (targeted JDK 27)
- JDK-8337517, "Redacted Heap Dumps" (proposed and withdrawn)
- PCI DSS v4.0 Req 3.5.1 / 3.3.1; NIST SP 800-53r5 (CM-3, CM-6, SC-13, SI-11); NIST SP 800-63B;
  ISO/IEC 27001:2022 (A.8.12, A.8.15); FIPS 140-3