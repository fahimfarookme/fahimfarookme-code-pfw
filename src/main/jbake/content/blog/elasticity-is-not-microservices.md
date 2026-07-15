title=Elasticity Is Not Microservices
date=2026-07-15
type=post
tags=microservice, architecture, critique
status=draft
subtitle=On service discovery, fixed topologies, and the category error hiding inside "cloud-native"
description=How to bootstrap Jasypt in Spring Cloud environments so encrypted properties are decrypted before the config server pulls remote configurations.
~~~~~~

An architecture review recently flagged a service-discovery setup as an anti-pattern. The system resolved east–west traffic between services on a fixed set of VMs through a highly available reverse proxy — active/standby, VIP failover, health-based routing. The verdict: static, brittle, not cloud-ready; rip it out and add a client-side service registry.

In the abstract, every sentence in that verdict is defensible. In context, it was wrong — not because the reviewer misread the code, but because *anti-pattern* is not a property of a pattern. It is a property of a pattern in a context. Strip the context away and you are not reviewing architecture; you are matching against a style guide.

## Concede what's true

First principles cut both ways, so start with the concessions. Netflix-era client-side discovery is dated and largely in maintenance mode; it is not the default for a greenfield platform. Service discovery is a genuine requirement in any distributed system — you cannot wave it away. A registry that hardcodes instance addresses would be brittle.

All true. None of it supports the conclusion that was drawn. And notice the move the review leaned on to get there: *legacy*, *outdated*, *not modern*. Recency is not an argument. The question for any mechanism is fitness for the constraint in front of you, not its vintage — "different is not better," as Ousterhout puts it. A review that treats newness as a verdict has smuggled in a preference and called it a finding.

## The category error

"Cloud-native" quietly fuses three independent axes into one virtue word, and the review collapsed all three.

There is an *architectural* axis — how the system is decomposed: bounded contexts, independent deployability. That is what "microservices" means; it is what Fowler and Lewis's original characterisation actually lists. There is an *operational* axis — how the running system behaves under change: elasticity, autoscaling, dynamic lifecycle. That is a property of the platform and its economics, not of the code. And there is a *platform* axis — the primitives the substrate hands you: dynamic discovery, health-driven traffic management, mesh features. Those arrive when you adopt an orchestrator.

The review took the absence of the operational and platform properties and called it a violation of the *architectural* one — a breach of "microservice best practice." But you can have textbook bounded contexts and independent deployability with zero elasticity. A monolith on an autoscaling group is elastic and is not microservices. A set of properly bounded services on fixed VMs is microservices and is not elastic. The axes are orthogonal.

The same confusion hides in the word "scaling." Cloning instances behind a load balancer is the X-axis of the AKF Scale Cube — the oldest horizontal-scaling move there is. It does not require elasticity; a fixed, provisioned set of replicas behind a proxy *is* horizontal scaling. Elasticity is only the *automated, demand-driven* version of it. Demanding platform primitives from an application, and calling their absence an architectural defect, is a category confusion, not a finding.

## An architecture is not a checklist

The tell of a checklist review is that the prescription doesn't have to cohere with itself. Ask for the replacement design as a *system* and the seams show: a registry demanded on infrastructure with no autoscaling to feed it; an "elasticity" fix that scales instances within a single host — one failure domain — offered in the same breath as a high-availability requirement that means spanning hosts; proxy-layer resilience dismissed as inferior to a service mesh, when a mesh *is* a proxy, just one sidecar per service. Each item is fashionable in isolation. Together they don't compose, and several contradict the very constraints the platform was built under.

An architecture is defined by how its parts fit under a given set of constraints — not by how many modern nouns appear in the review. A list of cloud-native terms is not a design. It is a wish, and often a self-contradicting one.

## Mechanism follows rate of change

Service discovery answers exactly one question: where is instance X right now? The mechanism you need is a function of how fast that answer changes.

Client-side discovery — a registry plus a client baked into every service — exists to track membership that changes faster than any human or pipeline can follow: instances appearing and vanishing on autoscaling and preemption, on the order of seconds. That is the problem it was built for. On a fixed topology where the instance set changes only on a deliberate, scheduled deploy — weeks apart, through a change process — server-side discovery via an HA proxy with health-based ejection is not a degraded stand-in for the real thing. It is the mechanism sized to the actual rate of change. Server-side discovery is a first-class pattern in every catalogue, ELB included; reaching past it for a registry you don't need is solving a churn problem you don't have, and paying for it in coupling and new failure modes. A registry is itself a replicated, eventually-consistent subsystem with its own partition behaviour — you are adding a distributed-systems problem to avoid editing a config file.

## The portability inversion

There is an irony worth sitting with. Client-side discovery makes the service *smart* — it embeds the discovery mechanism into application code. Platform-side discovery keeps the service *dumb*: it calls a name, something else resolves it, and the application stays ignorant of how. Portable services are dumb services — it is why the entire service-mesh movement worked to pull discovery, retries, and circuit breaking *out* of the application and into a sidecar.

So demanding a client-side registry in the name of cloud-readiness pushes you toward smart, mechanism-coupled services — away from the portability that "cloud-ready" is supposed to mean. If the goal is a service you can lift onto an orchestrator later with a config change and no code change, the registry is the thing standing in your way, not the reverse proxy. (I've contributed to the Spring Cloud Netflix stack; this isn't secondhand.)

## The reviewable question

None of this makes a client-side registry wrong. It makes it *conditional* — right when your topology churns fast enough to earn its cost, wrong when it doesn't. The same is true of the reverse proxy. The choice was never "NGINX or Eureka." It was: what is the rate of change of this topology, and does the mechanism match it?

A review that does not state the operating context it assumes has not reviewed the architecture. It has expressed a preference. State the context. Match the mechanism to the rate of change. The rest is fashion.