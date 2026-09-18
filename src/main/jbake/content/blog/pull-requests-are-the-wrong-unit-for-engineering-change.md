title=Pull Requests Are the Wrong Unit for Engineering Change
date=2026-09-07
type=post
tags=empirical-software-engineering, engineering-excellence
status=published
references=show
subtitle=On preparatory refactoring, and the decision your tooling makes for you
description=Preparatory refactoring is four decisions, not one - whether it pays off, how tightly it is bound to the fix, what order to work in, and what you hand a reviewer.
~~~~~~

<span class="marginnote" id="note-yegor">"In a large codebase with legacy code, where every fix may require preliminary refactorings in a number of places, we don't do them all in a single PR. Instead, we make a series of them, with refactorings and code polishing, until the broken place is fully ready for a small change that is easy to review and understand. As Kent Beck once said, 'make the change easy, then make the easy change.'"<br><br>Yegor Bugayenko, *Angry Tests* (2024)</span>

Kent Beck says ["Make the change easy, then make the easy change"](https://x.com/KentBeck/status/250733358307500032). Martin Fowler defines the "make the change easy" part as [Preparatory Refactoring](https://martinfowler.com/articles/preparatory-refactoring-example.html) which shall preserve existing behaviour. I came across [this](https://www.linkedin.com/posts/yegor256_in-a-large-codebase-with-legacy-code-where-activity-7502126973662715904-oPa0?utm_source=share&utm_medium=member_desktop&rcm=ACoAAAu9hMABzjpBHYxSNdNNMdzDzVwUvQTqw2s) <span data-note="note-yegor">LinkedIn post</span> recently, where Yegor Bugayenko introduces the idea of putting preparatory refactoring into its own pull request, or a series of pull requests.

<span class="marginnote" id="note-refactoring">Note that I use <i>refactoring</i> to refer to the preparatory work, whether behaviour-preserving or not.</span><span class="marginnote" id="note-change">Note that I use <i>change</i> to refer to the original intended change, either a bug fix or a feature.</span>
It raised several questions in my mind about the <span data-note="note-refactoring"><i>refactoring</i></span> and the <span data-note="note-change"><i>change</i></span>, and about whether this advice is complete.

1. How far is the refactoring worth doing?
2. How tightly is the refactoring coupled to the change?
3. When should the refactoring be done?
4. How should the refactoring be packaged?

<span class="marginnote" id="who-answers-what">I have not read everything they have written, so this is based on what I have seen. Let me know if I have got it wrong.</span><span data-note="who-answers-what">Here is who answers what.</span>

<span class="marginnote" id="beck-imply-business">Beck asks: <i>Is there enough time to do your work?</i> in deciding <i>later</i>. I'm not sure if he meant the business urgency here.</span>
<span class="marginnote" id="first-after-later">Later: when no immediate payoff and can be done incrementally.<br/>After: otherwise makes the change incomplete or makes the next change more expensiv.</br>First: when the payoff is immediate</span>

| Question | Who answers it | What they say | What's missing |
|---|---|---|---|
| Worth? | Fowler, Beck | Fowler: only if the time you spend refactoring comes back later as quicker change.</br>Beck: never refactor, if the code won't change again or there's nothing to learn from tidying it. | Fowler's measure is time saved, and specifically coding time. Beck aditionally count's code author's learning. Code review and the rest of delivery are not counted by either. |
| Coupled? | Nobody | | Does the refactoring make sense even if the change never happens? |
| When? | Fowler, Beck, Yegor | Fowler, Yegor: Refactor before the change<br/>Beck: <span data-note="first-after-later">First, after, or later</span>  | Both decide from the perspective of the code author. <span data-note="beck-imply-business">Neither weighs how urgent the change is for the business</span> |
| Packaging? | Beck, Yegor | Beck: sstructure (refactoring) and behaviour (change) in separate pull requests<br/>Yegor:  a series of refactoring pull requests, then the change in the last one  | Assumes the refactoring pull request can be reasoned without seeing the change. The author knows why, the reviewer doesn't. |

Those first two questions are easy to run together, so it's worth being clear about the difference. "Will it pay for itself" counts the fix as payoff, which is why Fowler's answer is usually yes. "How tightly is it bound" asks whether anybody other than you could tell why you did it. A seam can pay for itself handsomely and still be unreadable to the next person, and that combination is where all the trouble is.

One more thing about the four before we start. Only the second one is purely about the code. You answer it by reading the diff, and for a given change it has one right answer that doesn't depend on where you work. The other three all depend on your company; how expensive your releases are, how urgent this bug is, who is waiting on you. Which makes it odd that the second one is the one nobody asks.

## Will it pay for itself?

<span class="marginnote" id="note-econ">Fowler files this under "Is refactoring wasteful rework?" in *Workflows of Refactoring*, next to two instructions people quote far less often: balance refactoring with feature delivery, and don't try to fix things completely.</span>Fowler's answer is the right one. Don't restructure unless you expect to <span data-note="note-econ">get that time back</span> later, through work that goes quicker because you did. The strongest version is reuse; the seam you add now helps the next change too, so you aren't paying for one change, you're paying for several.

And the rule works. For preparatory refactoring he makes the comparison explicit: refactoring first and then making the change is often faster overall than making the change without the refactoring. Run that on the VAT bug honestly. The one-line conditional is ten minutes. The `TaxRule` seam plus the fix is two hours. You are not getting an hour and fifty minutes back, so the rule tells you not to bother, and the rule is right.

What it cannot tell you is anything about the rest of this post, and it's worth being exact about where the edge sits.

Fowler is not only counting your afternoon. In the same deck he writes that refactoring "makes it easier to understand the code - which makes subsequent changes quicker and cheaper", and his comprehension refactoring workflow exists so that "nobody has to build it from scratch in their head again". Other people's time is in the sum.

But every one of those people is reading code that already landed. They open the file, they follow it, they make their change. A reviewer is doing a different job: reading code that has *not* landed, and deciding whether it should. What they are handed is an interface with one implementation and no second implementation anywhere, and the question in front of them is not "can I follow this" but "should this go in".

Fowler never writes about that decision. His deck ends on "Refactoring → Clean Code → Faster Delivery", and delivery in his vocabulary is the whole path to production, so the reviewer is in there somewhere. But it is an outcome with no parts. Review never appears as an activity with a cost of its own, his flow charts run from *add the feature* straight to *done*, and a release is never a thing you pay for each time you do one. There is no resolution at which you could ask what happens to review when one change becomes four.

Notice also which way that claim points. Clean code delivers faster is an argument for doing the restructuring. It says nothing about how to hand it over. You cannot get "put the restructuring in its own pull request" out of it.

And here is the part worth being fair about. In his workflow that costs him nothing. He restructures and makes the change in one sitting, so one change reaches the reviewer, and that reviewer's job is no harder for the preparation having happened. His sum is complete for the way he works.

It only springs a leak when somebody uses that rule to justify splitting the work across pull requests. Now there are four approvals instead of one, and somebody is holding a piece with no successor in place. Neither of those exists in his world. So this is not a mistake of his; it's what breaks when his rule is carried into a decision he wasn't writing about.

One more thing about the shape of it. His returns are partly deferred, arriving whenever somebody next opens the file. The costs of splitting all land up front.

There is also a second question the rule doesn't ask, and it turns out to matter more than the first.

> **Would you do this restructuring if the bug didn't exist?**

Yes means the work has its own case and the bug is just when you happened to notice. No means the only payoff is this fix, and the real question is whether the fix actually needs it, which is the next section.

There's one answer that looks like a yes and isn't, and it's the interesting one. "Yes, because three more tax jurisdictions land next quarter." That may well be true. But it's true in your head and nowhere in the diff, and the reviewer cannot see next quarter. The restructuring isn't the problem in that case. The problem is that the thing justifying it lives somewhere the reviewer can't reach, and most of the rest of this post is about that.

One caution on reuse, since it's the argument people lean on hardest. Nobody has measured how often the second consumer actually turns up. Until somebody does, it's a forecast, not a benefit.

## How tightly is the restructuring bound to the fix?

Three answers, and they are visible in code, so let's start there.

### Case A: the refactoring stands on its own

A retry helper has been copy-pasted into four service classes and has drifted in each of them.

```java
// OrderService.java
public OrderStatus submit(Order order) {
    int attempts = 0;
    while (true) {
        try {
            return gateway.submit(order);
        } catch (TransientException e) {
            attempts++;
            if (attempts >= 3) throw e;
            sleep(200L * attempts);
        }
    }
}

// InvoiceService.java
public Invoice issue(InvoiceRequest req) {
    int attempts = 0;
    while (true) {
        try {
            return billing.issue(req);
        } catch (TransientException e) {
            attempts++;
            if (attempts >= 3) throw e;
            sleep(200L);              // drifted: no backoff
        }
    }
}
```

Two more copies live elsewhere. Your bug is in one of them and you cannot see it clearly, since the logic is smeared across four places.

So you extract it.

```java
public final class Retry {
    public static <T> T times(int attempts, Duration base, Supplier<T> action) {
        for (int i = 1; ; i++) {
            try {
                return action.get();
            } catch (TransientException e) {
                if (i >= attempts) throw e;
                sleep(base.multipliedBy(i));
            }
        }
    }
}

// OrderService.java
public OrderStatus submit(Order order) {
    return Retry.times(3, Duration.ofMillis(200), () -> gateway.submit(order));
}
```

Now hand that pull request to a reviewer who has never heard of your bug. They can still approve it - four near-identical blocks became one, the drift is gone, the backoff is consistent everywhere. Notice that the justification never mentions the bug.

<span class="marginnote" id="note-chartests">Michael Feathers' term, from *Working Effectively with Legacy Code*. The point of a characterisation test is not to assert correct behaviour. It is to pin down current behaviour so you notice when you change it by accident.</span>Other things in the same category; deleting code that became unreachable when a config flag was retired, renaming a `process()` method that takes an order and returns a shipping estimate, or writing <span data-note="note-chartests">characterisation tests</span> that capture what the code does today, correct or not.

### Case B: the refactoring is only justified by the fix

Invoicing applies one VAT rate to every order.

```java
public class InvoiceService {
    public Money total(Order order) {
        Money net = order.lines().stream()
            .map(Line::amount)
            .reduce(Money.ZERO, Money::plus);
        return net.plus(net.multipliedBy(VAT_RATE));
    }
}
```

The bug is that export orders are charged domestic VAT. They should be zero-rated.

The rate now depends on where the order is going, so the obvious move is to stop treating it as a constant. The tax calculation has to become a decision before it can become the right decision, and making it a decision is the preparatory change.

*Pull request 1 - introduce the seam.*

```java
public interface TaxRule {
    Money taxOn(Money net);
}

public final class DomesticTaxRule implements TaxRule {
    public Money taxOn(Money net) {
        return net.multipliedBy(VAT_RATE);
    }
}

public class TaxRules {
    public TaxRule forDestination(Country destination) {
        return new DomesticTaxRule();
    }
}

public class InvoiceService {
    private final TaxRules rules;

    public Money total(Order order) {
        Money net = order.lines().stream()
            .map(Line::amount)
            .reduce(Money.ZERO, Money::plus);
        return net.plus(rules.forDestination(order.destination()).taxOn(net));
    }
}
```

That compiles, and every existing test passes, since `forDestination` returns the same rule whatever you hand it.

*Pull request 2 - the fix.*

```java
public final class ExportTaxRule implements TaxRule {
    public Money taxOn(Money net) {
        return Money.ZERO;
    }
}

// in TaxRules
public TaxRule forDestination(Country destination) {
    return destination.isHome() ? new DomesticTaxRule() : new ExportTaxRule();
}
```

Now do the same exercise as before. Hand pull request 1 to a reviewer, with pull request 2 not yet written and the bug not mentioned. What do they see?

An interface with one implementation. A lookup that takes a destination and ignores it. A rate that used to sit next to the arithmetic and now sits two indirections away from it. Behaviour is identical and the structure is more elaborate than it was.

There's no code-health story to tell. The only honest answer to *why is this better* is *because of a change you cannot see*.

Same category; splitting an interface so a later change can substitute one half, threading a parameter through call sites where every caller passes the same value it used to read from ambient state, or adding a seam whose only consumer is the pending change. In each of these the structure became more general in a direction that only the unwritten change uses. A general mechanism with nothing using it looks like a guess about the future, and until the fix lands that is exactly what it is.

And now the uncomfortable part. Look at what fixing that bug actually takes on its own.

```java
return net.plus(order.destination().isHome()
        ? net.multipliedBy(VAT_RATE)
        : Money.ZERO);
```

One line. No interface, no lookup, no seam. Export orders are zero-rated and the bug is gone.

So `TaxRule` was never required. I'd have failed my own test from the last section: without this bug I would not have sat down to build a tax rule lookup. The bug gave me cover.

This is not an argument that the seam is bad work. Fowler's own worked example inserts a no-op function with one caller for a change he hasn't written yet, which is exactly this shape, from someone who knows what he is doing. The difference is that he does it inside one continuous piece of work, and the function never faces a reviewer on its own.

So the position is narrower than "don't do it". **Case B structure is a fine way to work and a bad thing to ship on its own.** It belongs in your head and in your commits. It does not belong in a pull request with nothing behind it.

### Case C: the restructuring is the fix

An account keeps a balance and the time it was last valid, in two fields.

```java
private BigDecimal balance;
private Instant balanceAsOf;

public void credit(Money amount) {
    balance = balance.add(amount.value());
    balanceAsOf = clock.instant();
}
```

The bug is that a reader can land between those two lines and see a new balance with an old timestamp. Statements go out with numbers that never existed.

You cannot fix that by adjusting either line. The two values have to move together, which means they have to be one value.

```java
private volatile Balance balance;   // record Balance(BigDecimal amount, Instant asOf)

public void credit(Money amount) {
    balance = balance.plus(amount, clock.instant());
}
```

<span class="marginnote" id="note-volatile">`volatile` is doing real work here and it's worth being precise about what. It does not make the update atomic. It makes the single reference swap visible to other threads immediately, and because both values now sit behind one reference there is no longer a window where a reader sees one without the other.</span>Introducing <span data-note="note-volatile">`Balance`</span> looks like a refactoring. It isn't. It is the fix. There is no version of this where the restructuring lands first and the fix follows, because once the restructuring has landed the bug is already gone.

Same category; reordering who takes which lock to break a deadlock, or moving a computation to where the data it needs actually exists. In each case the structure was the defect.

### Two questions that tell you which one you have

**Can you write the fix without changing the structure?** If you can't, you're in Case C and there is nothing to decide. Ship them together, because they are the same thing.

**Cover the fix with your hand and read the restructuring.** If it still earns a yes, you're in Case A. If that yes depends on something that is not in the diff, you're in Case B.

Ask them in that order. Most arguments about preparatory refactoring are between two people who never asked the first question and are in different cases without knowing it.

Standalone value is really a spectrum, not two boxes. It behaves like two boxes anyway, because the thing it feeds is a reviewer deciding whether to approve, and that is a yes or a no.

## The case for keeping them apart

The next two questions both turn on the same thing, so it's worth doing once. What do you get, and what do you pay, for letting the restructuring and the fix land separately rather than as one change?

Here's the strongest case for keeping them apart. Much of it is Beck's own. In *Tidy First?* he says structural changes and behaviour changes belong in separate pull requests, with as few tidyings in each as possible.

- **Smaller diffs get better review.** A reviewer holding three hundred lines is doing a different job from one holding three thousand. There is evidence for this, and it is the argument everybody leads with.
- **Separating structure from behaviour makes the behavioural change auditable.** Mix them and nobody can tell which lines were supposed to change behaviour and which were not. Separate them and the claim attached to each piece is clear; this one says nothing changed, that one says exactly this changed.
- **Behaviour-preserving work is safe, so land it early and shrink the risky part.** By the time the fix arrives it is small, and the small thing is the only thing carrying risk. Anyone else waiting on the new structure can start straight away instead of waiting for your bug.
- **Small steps are reversible.** If step three turns out wrong, revert step three.
- **Small steps are faster and less stressful to work in.** Beck argues for tiny steps, and Fowler's worked example ends on this point. Working in small verified increments beats one long risky push.
- **It leaves a record.** Six months later the history says why the structure changed, instead of burying it inside a fix.
- **Small batches clash less.** The longer work waits to merge, the more likely it collides with someone else's, and the more likely a batch quietly changes behaviour. That is Beck's batch-size argument.

That is a good argument. Most of it is even true. Here is why almost none of it reaches the conclusion people draw from it.

- **Smaller diffs get better review, if each diff can be judged.** In Case B it cannot. The reviewer can read every line of an interface with one implementation and still have nothing to judge it against. And the evidence is narrower than the claim; the one significant result is fewer wrong objections, not more defects found, and the study's split group could see both halves, which is not the situation being argued about.
<span class="marginnote" id="note-hats">The metaphor is Beck's. Fowler says he "passed on Kent's metaphor" in the *Refactoring* book. Two modes, and you can only wear one at a time: refactoring keeps the tests green by construction, adding function breaks them on purpose.</span>- **Separating structure from behaviour is right, and it is an argument about commits.** The <span data-note="note-hats">two hats</span> describe what you are doing at a given moment. Fowler is explicit about the granularity: "during programming you may swap frequently between hats, perhaps every couple of minutes." Every couple of minutes is not a pull request. It is not even a commit. Nothing in "wear one hat at a time" reaches packaging at all.
- **"Behaviour-preserving" is a claim, not a fact.** Split off from the fix, it merges with nothing new checking it. And the code you most want to restructure has the thinnest coverage you own, which is usually why it got that way.
- **Reverting step three of six is not an ordinary operation.** Steps four, five and six sit on top of it. And in Case B, keeping step three after reverting the fix buys you nothing, because it was worth nothing alone.
- **Small steps being nicer to work in is about authoring, not packaging.** You can take twenty small verified steps and put them in one pull request. This point survives completely and says nothing about pull requests.
- **A record is made by commits.** Separate pull requests add nothing to the history that ordered commits do not already give you.
- **Merging early also spreads the half-finished shape.** A seam that lands early is a seam other people start building on before anyone knows whether the change it was for will arrive.

Notice the shape of that. Nearly every argument on the list is an argument for small, ordered, separately-readable steps. Hold on to that, because it turns out to matter enormously which of those words you take seriously.

Fowler, incidentally, argues the other way on delivery. His own economic advice is that "refactoring should be done in conjunction with adding new features", and that preparatory refactoring "can pay for itself when adding the feature you're preparing for". In conjunction with. Pays for itself when the feature arrives. Both of those are arguments for keeping them together, from the person who named the practice.

Beck's separate-pull-request advice rests on one assumption: that each tidying can be judged on its own. For most of his tidyings that holds. A guard clause or a deleted dead branch explains itself. But one of his own, *New Interface, Old Implementation*, can take exactly the Case B shape: write the interface you wish you could call, make it delegate to the old one, and call it from the change you're about to make. Ship that tidying first, in its own pull request, and the reviewer sees a pass-through that nothing uses yet.

## What survives, and what it costs

Three things survive that list. Small pieces are genuinely easier to review, you can undo one without losing the other, and work somebody else is blocked on lands early instead of at the end. All three are smaller than they looked, and the first is the only one with evidence behind it.

It costs two things.

**The window.** From the first merge to the last, the system sits in a shape nobody designed.

- The bug is still in production for the whole window, and that bill accrues daily while nobody counts it.
- Trunk is half-migrated, and other people write code against the half-migrated version.
- Every piece you add makes the window longer. Each one waits for a reviewer to pick it up, load the context and answer, and they run one after another because each depends on the one before it. Where your organisation ties merging to releasing, each piece waits for a release slot as well, and six release slots is months. Where merging and releasing come apart, it is only the reviews you are waiting on. Merging is not releasing. Beck makes the same point about fixed review and deployment costs, as one side of his batch-size trade-off.
- Some of that length is work you would not otherwise do. Each piece has to compile and pass on its own, so you sometimes write scaffolding whose only job is to hold the intermediate state together until the last piece lands, and which you then delete.
- The window may never close. Priorities move, authors change teams, a board says no. This is the only genuine risk on the page. Everything else here is a certainty you are choosing.

**The whole is never checked.** Restructuring plus fix is one thing. Split apart, nothing ever evaluates it as one thing.

- No test does. The first pull request preserves behaviour, the second one changes it, and the second one's tests are what exercise the two together. Merge the first on its own and its reviewer cannot lean on those tests, because they don't exist yet.
- No person does either. Nobody sits down and reads the pieces together. The complete change is in no artifact, so it ends up in no head.

Time is not a third cost. The window is measured in time; that is what a window is. And risk is not a cost of its own either. One thing here is a risk, the window never closing. The rest you know will happen the moment you decide to split.

Now notice what the three benefits have in common. Every one of them needs the piece to be worth something on its own. A reviewer can only judge it if it stands alone. Keeping it through a revert is only worth doing if it stands alone. Somebody else can only build on it if it stands alone.

Three benefits, one condition, and the costs don't care either way.

## When do you do it?

This only comes up if the restructuring can be separated. In Case C there is nothing to decide, because the restructuring is the fix. Before asking how tightly the refactoring is coupled to the change, make sure it is a refactoring at all. Sometimes what looks like preparation is the change itself.

<span class="marginnote" id="note-tweet">The tweet everybody quotes gives one answer. *Tidy First?* (2023), eleven years later, gives these four, and is quoted far less.</span>Beck gives <span data-note="note-tweet">four answers</span>, and they're the right place to start.

- **First.** Refactor, then make the change. The advice everybody quotes.
- **After.** Make the change, then refactor straight away, in the same piece of work.
- **Later.** Make the change, and come back to the refactoring as a separate task. Beck keeps a list of these; most teams would call it debt.
- **Never.** Already answered by the first question: the refactoring doesn't pay for itself.

This is purely about the order you do the work in. It says nothing yet about what you hand anybody, which is the next question and is not the same question. Keep them apart in your head for a few paragraphs; the whole argument turns on it.

Beck's *after* and *later* both put the change first. Fowler draws the same option, just not for this workflow. His flow for litter-pickup and comprehension refactoring has a decision box asking "fix now?", and the "no" branch is finish the feature first, then clean up. Two branches, both ending clean.

His flow for preparatory refactoring has no such box. It asks "good fit?", and if the answer is no you refactor, then add the feature. There is no branch where you add the feature first and restructure afterwards.

I don't think that asymmetry is deliberate. It just follows from how preparatory refactoring is framed; the whole idea is that the restructuring makes the change easy, so doing the change first sounds like giving up the point. It isn't, and the rest of this section is about why.

**In Case B, the refactoring can't go ahead of the change on its own.** Everything you get from keeping them apart goes to zero at once, and for the same reason.

- A reviewer can't judge it. They follow every line and still have nothing to judge it against.
- Keeping it through a revert buys nothing. A seam with no consumer is worth nothing alone, which is what put you in Case B.
- Nobody is waiting on it. Nothing can consume it until the fix exists.

The costs are identical to Case A. So you pay the full bill and get nothing back. That leaves first or after, in the same piece of work as the change, or later. And changing first has a property worth having here: do it and you find out whether you ever wanted the seam at all. Often you won't.

**In Case A all three are live.** Here is what moves the answer.

| What you're looking at | Code or company | Pushes toward |
|---|---|---|
| The change is urgent, like a live bug costing money | Company | After or later |
| You don't yet know what the end structure should be | Code | After, or later if the tidying is big |
| The change is error-prone in the current code | Code | First |
| Somebody else is waiting on the refactoring | Company | First |
| Test coverage over that code is thin | Code | After |
| The refactoring is small | Code | First or after |

The middle column is worth a moment. Four of those rows are facts about your code and you can look them up. Two are facts about your company and they are different in every building. That is why this question has no universal answer, and why anybody who hands you one is generalising from their own office.

Two rows carry more weight than the rest.

**Urgency, because the failure modes are not symmetric.** Either plan can be left unfinished. The bills are different.

- **First**, abandoned at step four: the bug is still live, and trunk is left in a shape nobody designed.
- **Later**, never done: the bug is fixed, and you owe some debt.

Same risk, one fails safe and one doesn't. Beck lists after and later as options, for reasons of cost, payoff and learning. None of his reasons is about what you're left with if the work stops halfway.

**Coverage, because the fix's test is doing more work than it looks.** That test is what exercises the restructured code. Make the change first and its test is already there when you refactor, so the refactoring is checked as you go. Refactor first in a pull request of its own and the refactoring lands on whatever coverage already existed, which in the code you most want to restructure is usually the thinnest coverage you own.

And the honest costs of changing first, since they are real. With *later*, the refactoring often never happens. Beck disagrees: he says later works, on one condition, that the team believes it has enough time to do its work. That's a fact about the company, not the code, and in a lot of companies it isn't true. There, a cleanup with no urgency loses every prioritisation argument it enters. You write the hack, then the clean version, then delete the hack, which is more total work. And fixing inside bad structure is more error-prone, which is the whole reason Beck's advice exists in the first place.

## How is it packaged?

Here is the step nearly everybody skips. Having settled the order you'll work in, you still have to decide what you hand somebody. Those are two different decisions, and a grid makes it obvious.

| | One pull request, one diff | One pull request, ordered commits | Separate pull requests |
|---|---|---|---|
| **First** | works | the default for Case B | Beck's default, and the thing everybody argues about |
| **After** | works | works | works |
| **Later** | not possible | not possible | the only option |

Only *later* forces the answer. For first and after, the order you work in doesn't decide what you hand over.

Which matters, because the advice we started with runs the two together. "Make the change easy, then make the easy change" is a claim about work order. "Put the restructuring in its own pull request" is a claim about packaging. The LinkedIn post offers the second as though it followed from the first, and it doesn't. Beck does argue for separate pull requests, but on grounds of their own, and those grounds assume the refactoring can be judged on its own. First, in one pull request, is an ordinary cell, and in Case B it's the one that wins.

Now look again at the case for keeping them apart. Nearly every argument on that list was about small, ordered, separately-readable steps. Not one of them was about separate pull requests. **You collect the benefits at commit granularity. You pay the costs at pull request granularity.** That is the whole of it.

Two things bear on packaging specifically, and neither belongs in the question about work order.

- **Whether the restructuring is big enough to swamp the fix in review.** A fact about your code.
- **What each trip to production costs you in change records, board slots and release windows.** A fact about your company, quietly deciding how somebody reads a diff.

### What the research actually says

Before the options, the evidence. Reviewability, the first of the three things keeping them apart buys you, is the only part of this with a real empirical literature behind it. It's worth knowing about, because it's more nuanced than either side of the usual argument.

Herzig and Zeller established the baseline problem. Across five open-source Java projects they found between 7 and 20 percent of bug fixes consisted of multiple tangled changes, and that this tangling corrupts downstream analysis badly enough that at least 16.6 percent of source files end up incorrectly associated with bug reports. That's an argument for separation, though note that the argument is about data quality and not about review.

The most directly relevant work I found is a controlled experiment by di Biase, Bruntink, van Deursen and Bacchelli, published in 2019. They set up almost exactly the scenario in this post. Twenty-eight participants, professionals and graduate students, reviewing a change to a small Java system. One group got a single pull request with a refactoring and a feature tangled together, the other got the same work split into two pull requests. Three functional defects were deliberately planted.

The results do not land where either camp expects.

<span class="marginnote" id="note-cliff">Cliff's delta measures how often a value from one group beats a value from the other, without assuming the data is normally distributed. It runs from -1 to 1, and 0.36 is conventionally read as a medium effect. Useful here because defect counts are small integers and badly behaved.</span>The split group reported fewer false positives, i.e. fewer confident objections to code that was actually fine. Six across the tangled group against one across the split group, at p = 0.03, with a medium effect size (<span data-note="note-cliff">Cliff's delta 0.36</span>). That is the one statistically significant result in the paper. The split group also wrote more suggested improvements, nineteen against seven, though that difference did not reach significance and the authors report it as an observation worth following up rather than a finding. From the screen recordings they showed noticeably more context-seeking behaviour, opening referenced classes to build a picture before judging.

But they did not find more defects. The tangled group found twenty and the split group seventeen, a difference in the wrong direction for the folklore and nowhere near significance at p = 0.6. They did not report a better understanding of the change rationale either. And they were not faster, despite each pull request being smaller. The authors put that down to the context switch between the two reviews eating the saving, which is their explanation rather than something the experiment measured.

One result cuts the other way and belongs here. Tao and Kim ran a user study on partitioning composite changes and found participants understood the partitioned versions significantly better than the originals, in roughly the same time. That is the opposite of di Biase's null on rationale understanding. Two studies, same broad question, opposite answers, neither of them large.

So the empirical case for splitting is real, but a lot narrower than the folklore. The one solid result is that it makes reviewers more accurate about what's wrong, rather than better at finding what's wrong. That's worth having, but it is not what most people think they're buying.

Two limits are worth stating plainly, since they bound what the study can be used for. The system was about three thousand lines and the changeset around a hundred lines across seven files, hence this is not evidence about large enterprise changes. And, more importantly for the argument here, the split group could see both pull requests. That is not the same situation as reviewing preparatory change three of six with the fix still unwritten. The experiment tests decomposition where the whole is visible; it does not test decomposition where the justification is absent. As far as I can tell nobody has tested that, which is a pity, because that's the case people actually argue about.

### Three ways to hand it over


*Separate pull requests.* You pay both costs in full. The window stays open until the last piece lands, held open by review round trips in sequence and by release slots wherever merging and releasing are tied together, with the completion odds falling as the chain lengthens. Nothing checks the whole. In Case B you also get nothing back for it.

*One pull request, one diff.* The fix ships with its test and that test runs against the restructured code. One review, one merge, one change record, no window. What it gives up is reviewability; a two-line fix buried inside a two-thousand-line restructuring is where false positives and missed context live. It also gives up selective undo, since reverting the bad fix takes the restructuring with it.

*One pull request, ordered commits.*

```
1. Extract Retry helper, replace four copies
2. Add characterisation tests for export order invoicing
3. Introduce TaxRule seam, one implementation, no behaviour change
4. Fix: export orders use the zero-rated rule
```

Same merge, same change record, same window of zero. But each step stays small, the shape of the whole stays visible because it is all in one place, and reverting one commit is an ordinary operation. It is the only option that keeps both halves of the reading problem, and it keeps selective undo as well.

Beck mentions this option too, as a fallback: if separate pull requests are too costly to review, at least keep structure and behaviour in separate commits. For Case B I'd put it first, not second.

I should be honest about the gap in that claim. The experiment above tested separate pull requests, not ordered commits within one. The closest evidence is Baum, Schneider and Bacchelli, who tried the same idea one level down. They cut a change into parts, showed those parts to fifty reviewers in different orders, and measured how fast defects were found. The result went the way they predicted, but the groups were too small to confirm it. So ordering is not untested. It was tested, the study was too small to settle it, and what it tested was the order of parts inside one review, not commits that each carry their own message and their own approval. Nobody has tested that. And per-commit review in most tools is a worse experience than reviewing separate pull requests. That's a tooling deficiency rather than a property of the idea, but a tooling deficiency you have to live with is still a real cost.

## Why the argument never resolves

Go back to the four questions. The advice usually arrives as Beck's one-line tweet, with the second question never asked and the fourth one smuggled in, and practitioners inherit that and argue downstream of it. Nobody says which question they are answering, and half the time the two people are not even in the same case.

The person advocating a preparatory series has answered "when" with first, and "how is it packaged" with separate pull requests, which is what Beck recommends, usually without asking whether the refactoring can be judged on its own. On reviewability they are right, with evidence behind them.

The person in an enterprise saying it will never be approved is naming release cost, which is a different row of the same table. They are right too. It is not process obstruction. A change board asks what changes, what the blast radius is, and what the rollback is. A preparatory refactoring answers "nothing changes for the user", which is simultaneously unverifiable and unrewarding, and you're requesting risk budget for zero delivered value, several times over. Rejecting that is a correct response to how it was presented.

The person objecting that the bug is live is naming urgency, which is a third row. Also right.

Three people, three rows of one table, and each one thinks the other two are being careless.

Look at which rows though. Release cost and who is blocked are facts about a company. Urgency is a fact about a business. None of the three is arguing about the code, which is why none of them can win; they are all generalising correctly from offices that are not the same office.

Meanwhile the one question with a determinate answer, how tightly the restructuring is bound to the fix, is sitting there unasked. It takes a minute and a diff to settle, and settling it removes options from the table before anybody starts arguing about the rest.

That's the pattern. People argue about the questions that depend on where they work, and skip the one that doesn't. It was never a disagreement about refactoring.

## Why you cannot just weigh these up

So why is any of this hard? Whether it can be separated is a fact you look up. When to do it is a table with six rows. That is an ordinary engineering situation. You weigh it and you decide.

Except you cannot, because the tool will not let you decide these things separately.

Here is the cleanest way I can put it. Deciding how to hand work to a reviewer should be a question about the code and the reader; how big it is, what it claims, whether a human can hold it. Deciding what reaches production and when should be a question about the company; blast radius, rollback, who signs. Two different kinds of force, and they should pull two different levers.

The pull request is one lever. So a change board's release policy ends up deciding how somebody reads a diff, and a reviewer's attention span ends up deciding what ships. Neither of those should be true.

Beck has noticed the same problem from the other side. His answer to expensive reviews is to stop requiring review for tidying-only changes. That fixes a lever that's too coarse, and for Case A it's a good fix: a tidying that explains itself doesn't need a gatekeeper. For Case B it's the wrong one. A structure with no visible purpose then merges with nobody asking why.

Step back from the benefits and costs for a moment and look at what is actually being sized. Four different things, and something different sets the natural size of each. What the tests cover. What a reviewer can hold at once. What one release covers, sized by blast radius and rollback policy. What counts as a delivered outcome. Underneath all four sits the commit, i.e. the granularity at which work gets recorded, which is substrate rather than a fifth unit.

None of those four sizes has any reason to match the others. Test coverage does not follow blast radius. What a reviewer can hold in their head has nothing to do with what a change board authorises.

Now look at what a pull request actually is. Gating changes on review is old, and forges did not invent it; patches on mailing lists worked that way for decades. The difference is that there a reviewer approved a patch and a maintainer separately decided what to apply, so what was reviewed and what landed were never forced to match. The pull request forces it. Approving and merging are one act. It feels fundamental because it's everywhere, not because anybody designed it to carry this weight. And it collapses all four units into a single object.

So the moment you choose a review granularity, you've also chosen what the tests get run against, what ships, and what you can roll back, whether you wanted any of them or not. That's why the trade-off feels impossible. It is not really a hard trade-off, it's four decisions welded onto one lever.

Time has it worst, since it is not merely welded on, it's missing. Forges do track time; milestones, due dates, review turnaround targets. What none of them record is what delay costs on this change. There's no deadline on a chain, and no way to say that step four of six is holding back a live defect. Hence the question of what delay costs has no mechanism to answer it and falls back to whoever argues hardest in the thread. That gets called politics, but a missing primitive is a better description of it.

Two observations in support of this, because otherwise it's a nice-sounding claim with nothing behind it.

<span class="marginnote" id="note-gerrit">Worth knowing if you go looking at Gerrit: a relation chain is usually pushed all at once, and every change in it is visible to the reviewer of any one of them. So Gerrit's version of a chain is closer to the whole-is-visible case than to the preparatory series this post is about. That difference matters more than it looks.</span>First, the industry has been building escape hatches for years. <span data-note="note-gerrit">Gerrit</span> treats each commit as separately reviewable with declared dependencies. Phabricator did stacked diffs, and Sapling and Graphite continue that line. Every team that has ever said "please review this one commit at a time" is manually unwelding the same object. Nobody builds that many workarounds for something that's correctly shaped.

Second, look at what a forge stores when somebody clicks approve. It records that a person approved a set of lines. What that person actually believed was *I think this achieves X*. The belief is the valuable part, and it's thrown away on the spot.

That second one explains the Case B problem exactly. In Case B, the reviewer's X is a change that is not in front of them, hence there's nothing for the approval to be about. The pull request is not difficult to review, it's unreviewable in principle. The research finding that decomposition improves precision but not defect detection is consistent with this; splitting helps a reviewer be accurate about what they can see, and cannot help at all with what is not there.

There are two more holes once you start looking. The most consequential claim in a refactoring pull request is "this does not change behaviour". Conventions for saying it exist; Conventional Commits has `refactor:`, and parts of the LLVM world write NFC for no functional change. But it is prose either way. Nothing checks it, nothing can query it, and nothing objects when a commit claiming no behaviour change also edits what its tests expect. So when something breaks three weeks later you cannot ask which merged changes claimed behaviour preservation over the affected files.

And a series of preparatory changes is a multi-step write to shared state, since the main branch is one variable that everybody reads. A six-step series has seven possible states, five of them shapes nobody designed. Databases handle this with transactions and, where transactions are impossible, with sagas, which require a defined undo for every forward step. Forges let you start a saga and specify only the forward path. When a chain is abandoned at step four - which happens whenever priorities move or the author changes teams - the tool does not even know that a chain existed.

## What I'd want from a forge

I've wanted to build a forge for a long time, and this argument sharpened what it would be for. Not a better place to store diffs, but a place where intent is a first-class object and changes get evaluated against it.

The core feature is an answer to the Case B problem. Stacked diffs give you a chain, i.e. B depends on A. That's prior art and there's plenty of it. The move I have not seen is making the parent a *target that the children are judged against*.

<span class="marginnote" id="note-bba">You put an abstraction layer in front of the thing you want to replace, make it support both the old and the new implementation, migrate callers across one at a time, then delete the old one. Note what the first step is: an abstraction whose second implementation does not exist yet. Case B, endorsed, for work too big to do in one sitting.</span>Fowler gets close to this, in the one place where he has to. For long-term refactoring, restructuring too big for a single sitting, he says the team needs to agree on a rough end-state and a rough plan to get there, and then aim each piece of ordinary work at it. <span data-note="note-bba">Branch by abstraction</span> is the technique he names. That agreed end-state is exactly what a reviewer of preparatory change three needs and never gets. He asks teams to hold it socially, in their heads and their conversations. I want it to be an artifact, because the thing that is not written down is the thing that goes stale without anybody noticing. You do the whole change first, on a branch you intend to delete. That branch never merges. Its only job is to answer what the finished shape looks like and what made it hard. Then it becomes the target artifact, and each preparatory change declares which part of the target it enables.

The intention is that the reviewer of preparatory change three can see what it's preparing for, that a change which enables no part of the target becomes mechanically visible, and that the series acquires a stopping condition, since the target is either satisfied or it is not.

Whether the first of those actually improves review is an empirical question and I do not know the answer. Nobody has measured it. It's a design I find hard to argue against, which is exactly the kind of design that turns out to be wrong.

The target is discovered rather than planned, i.e. it comes out of an experiment. That's what makes it defensible against the obvious objection, which is that you cannot know the enabling steps in advance. You cannot. So find out first, cheaply, and then throw the branch away.

Three more, each fixing one of the holes above. Store approval as a proposition rather than a signature, so that the reviewer's actual belief is recorded and can be invalidated when the target moves underneath it. Treat chains as sagas, with a defined unwind and abandonment as a first-class operation. And show the cost before the split decision, since the forge already knows how many other branches touch the region and what the median round-trip time is, which turns an ideological argument into an estimate.

Most of the tooling in this space is aimed at making splitting easier to do. I'm more interested in making it accountable.

## Where this leaves the question

Three questions, in order, assuming you've already decided the restructuring is worth doing.

**How tightly is it bound to the fix? Read the code.**

- Can't write the fix without it. Case C. It is the fix. Ship them as one thing and stop thinking about it.
- Can, and it earns a yes on its own. Case A. Next question.
- Can, but it only makes sense because of the fix. Case B. Either do it in the same piece of work as the change, first or after, or leave it for later and find out whether you ever wanted it.

**What order do you work in?**

- The change is urgent: after or later. You don't yet know the end structure: after, or later if the tidying is big.
- Somebody is waiting on the refactoring, or the change is error-prone in the current code: first.
- Coverage is thin: after, so the change's test is there when you refactor.
- The refactoring is small: first or after, whichever is easier.

**What do you hand over?** In Case A, Beck's advice holds: the refactoring can go in its own pull request, because a reviewer can judge it on its own. In Case B it can't be judged on its own, so hand over one pull request with ordered commits rather than one undifferentiated diff.

Notice that the last question has its own answer. It is not read off the one before it, which is the mistake the advice makes. Refactor first and hand over one pull request is a perfectly ordinary way to work. Beck names it only as a fallback; for Case B it should be the default.

And notice what is doing the work in that last step. Ordered commits go unused mostly because the tool welds review granularity to merge granularity so tightly that they feel like a single decision.

They are not a single decision. And when you catch yourself designing a workflow around the shape of your tooling, it's worth asking whether the workflow is really the thing that needs fixing.

---

## References

- Herzig, K. and Zeller, A. (2013). *The Impact of Tangled Code Changes.* MSR '13.
- Herzig, K., Just, S. and Zeller, A. (2016). *The impact of tangled code changes on defect prediction models.* Empirical Software Engineering 21(2).
- di Biase, M., Bruntink, M., van Deursen, A. and Bacchelli, A. (2019). *The effects of change decomposition on code review - a controlled experiment.* PeerJ Computer Science 5:e193.
- Tao, Y. and Kim, S. (2015). *Partitioning composite code changes to facilitate code review.* MSR '15.
- Baum, T., Schneider, K. and Bacchelli, A. (2019). *Associating working memory capacity and code change ordering with code review performance.* Empirical Software Engineering.
- Sadowski, C., Söderberg, E., Church, L., Sipko, M. and Bacchelli, A. (2018). *Modern code review: a case study at Google.* ICSE-SEIP '18.
- Beck, K. (2023). *Tidy First?* O'Reilly. In particular the chapters on separate tidying, batch sizes, and first/after/later/never.
- Fowler, M. (2014). *Workflows of Refactoring.* martinfowler.com. The six workflows, the two hats, and the economic justification.
- Fowler, M. *An Example of Preparatory Refactoring.* martinfowler.com.