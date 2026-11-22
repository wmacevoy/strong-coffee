# Strong domains

*A draft. The example throughout is this repository's coffee machine; its five branches are the
lesson this document explains.*

## Safe ⇒ Strong

**The assumption, first: every line of code is safe.** It commits no memory error, it ends, and it
touches nothing of what calls it beyond what it is lent. Safe, not correct: it may compute the
wrong thing. This is not proved. It is chosen knowingly, stated here, and checked by other means:
tests, fuzzers, sanitizers, review, a language that holds it, a run-time check that ends the
process. In the coffee machine, `make safe` checks it of the edge, the code that is not proved.

**Given that, strong is proved.** Each strong domain is isolated, so it is reasoned about alone,
and its invariants are proved for every input. A wrong answer from code beside it is one more
input, so a strong domain stays strong next to code that is safe but incorrect, and that code can
in turn be reasoned about: whatever it does, it cannot reach the domain's state. A program's claim
has this form: *if every line is safe, these domains are strong.*

Safety comes first for a plain reason. Until a program is safe, nothing about it can be reasoned
about at all: a write outside an array may change any variable, and arithmetic the language gives
no meaning to lets the compiler do anything.

## What strong means

**Strong** means three things together: isolation, simplified reasoning, and proof of invariants.

- *Isolation:* what is true of a domain follows from its own code, the statements of what it calls,
  and the obligations of its callers, relative to the stated assumptions.
- *Simplified reasoning:* so that is all a reader (a person, a proof, an agent) must hold, and it
  does not grow as the program does.
- *Proof of invariants:* what is always true of the domain's state is shown for every input, by a
  machine, and audited.

Each alone falls short. Isolation and simple reasoning without a proof is a good design. A proof
without isolation must reason about the whole program.

## A domain

A strong domain is a set of classes, functions and state (fields, thread-locals, retained
contexts) that alone guards that state. The simplest is one class or one function. Its
**implementation** is the inside; its **ABI** is the boundary, the only way in. What is always
true of its state is its **invariant**, written in the program's own language:

```cpp
/* No slot holds more than 10. */
bool invariant() const { return count[0] <= 10 && count[1] <= 10 && count[2] <= 10 && count[3] <= 10; }
```

The coffee machine has four domains: `Credit`, `PodRack` and `WaterTank`, each one class, and
`vend`, one function: may a drink be sold?
The rest, `src/machine.cpp`, is the **edge**: it reads commands, asks the domains, and prints.

## What isolation takes

Seven conditions. Each removes a kind of code you would otherwise have to read.

| # | Condition | What you stop reading |
|---|---|---|
| 1 | **Owned state.** Only the domain's own code reads or writes its state. | every other reader and writer |
| 2 | **One name for what is written, as if on one thread.** While a call runs, what it may write has no second name, and no other thread touches what it was lent. | other names, other threads |
| 3 | **History in one sentence.** The invariant says all the past can have left behind, so each method is read from any state the invariant allows. | the calls that led here |
| 4 | **Hidden inputs are stated assumptions.** Beyond its arguments and its state, what a method depends on crosses a named boundary: a system or library call, a resource opened and closed, a context retained. | the world past the boundary |
| 5 | **Fully defined meaning.** Each operation means one thing: unsigned arithmetic, bounded indices, loops and recursion that end. That the machine has memory and stack enough is assumed. | the compiler's choices |
| 6 | **Callees by their statement.** What the domain calls is known by its promise, not its body. | the bodies of what it calls |
| 7 | **Callers by their obligation.** What the domain expects is a type or a stated condition, held at every call by a check of the whole program. | every caller |

1, 2 and 7 are the *frame*: what the domain touches, nobody else touches. 3 is abstraction over
time. 4 and 5 make the text mean one thing. 6 lets domains build on each other.

## The ABI: a borrow, not an event

Actors and event-driven designs get isolation from a boundary only messages cross: each message
is a copy, so nothing is shared. That costs a copy, and often an allocation, at every crossing,
which code that must be fast, embedded code included, cannot always pay.

A borrow gets the same isolation for reasoning with no copy: **a caller may lend references to
its own state for the length of one call; the domain uses them only through the lent names and
keeps none.**

| What a message gives | What a borrow gives instead |
|---|---|
| nothing shared after it is sent | nothing kept after the call returns |
| nobody changes it while it is read | nothing lent for writing has a second name during the call |
| one handler at a time | no other thread touches what is lent during the call |

Domain-driven design as such does not ask for events: an aggregate's root is reached by ordinary
calls, its invariant holds whenever no change is under way, and another aggregate is referred to
only by its identity. A strong domain is that border, made something a program refuses to let be
broken. What domain-driven design has not got is the third axis: **what may be relied on**,
strong or not.

## The implementation: a handle only the domain opens *(design)*

Code outside a domain may hold its state only as an opaque **handle**, which it carries and never
moves, clones, reads or writes. Only the domain opens it, and every open has two outcomes the
domain's code must handle: **fresh** (here is the state, and the invariant holds) or **already
open** (this instance is open further up the stack, or is another argument of this call, or is
open on another thread: the fact, and no access). A call that comes back into a domain cannot see
its state half-made, so the invariant need hold only where the domain is entered and left; and
`x.merge( x )` is a case the domain gives a meaning to, not an alias nobody saw. It costs a bit
and a branch. The coffee machine does not need it: no domain calls another.

## Threads: as if single-threaded *(design)*

A program may run many threads. Reasoning about memory that is not `volatile` is as-if
single-threaded: whoever lends a reference guarantees that no other thread touches it during the
call. Strong code reaches another thread only through a method whose `volatile` arguments say so
(inside, each read of one is an input, any value) or by isolated work (a thread handed only what is
its own). A handle two threads can reach opens by an atomic test-and-set.

## What a proof rests on

A proof is a statement about a text, and it holds only under its assumptions. Each is chosen,
named, and written where it is load-bearing:

- **every line of code is safe** (above);
- **the environment**: the hardware, the kernel, the loader and runtime, the libraries, the tools
  that built it, memory and stack enough, and anyone with the rights to change or view the
  process;
- **hidden inputs**, at the boundary: each system or library call does what it says; whoever
  makes a window onto memory keeps it valid; a retained context is retained;
- **the method's own**: the prover reads the C++ rightly (compared with the compiled program on
  thousands of calls, a test and not a proof), and the proof checker is right;
- **the invariant says what you meant.** It is a line of code: read it.

Input is not on the list. What comes in through the program's interfaces is what the proofs are
about, from anyone.

**Change or view** is the access-control question, and the same line as the proof's. Anyone who
can change the state from outside makes every proof about it void: that is integrity. View is
confidentiality, and a proof says nothing of it. Shrinking who may change or view a process
shrinks the assumptions a proof rests on.

## Design, test, prove

Every claim about a program is held one of three ways. The work is moving claims leftward.

| Held by | What it can hold | In the coffee machine |
|---|---|---|
| **Design**: a type, a place, a lint rule | what is true of the whole program, by its form | `private` state; the edge reaches a domain only by `_checked` names |
| **Proof**: a statement derived from the code, for every input, audited | what one domain does: no memory error, it ends, the invariant holds, and its claims | the four domains; `*.proof.cpp` |
| **Test**: a run, on the inputs tried | what nothing else reaches yet, and whether the other two work | the edge (`make test`, `make safe`); the counterexamples |

When you feel "I should test this", ask "could I prove this, and what would make proving it
simpler?" Say the worry as a statement over every input, try to prove it, and treat what blocks
the proof as a finding about the design. Reshape the code until the statement is easy; then break
the code on purpose and watch the proof fail. The coffee machine's `4-errors` is that: nine rules
broken, each found by trying to prove it.

## The lesson, branch by branch

1. **`1-unsafe`**: one file, globals, passing tests. Unsafe, messy and wrong.
2. **`2-safe`**: sanitizers and seeded random commands find five memory errors; unsigned numbers,
   tested indices and sized writes fix them. Safe, still wrong: safety first.
3. **`3-domains`**: each rule in its own domain, its state private, its invariant written. No
   answer changes. What it buys is that each rule can be read alone.
4. **`4-errors`**: each rule tried for every input. The compiler, the invariants and the claims
   find nine errors; one input each shows it is the code and not the proof.
5. **`5-strong`**: each fixed where it lives, and every domain proved.

## Guidelines

1. Make it safe before anything else, and say how safety is checked.
2. Start a domain where input arrives from someone who may be wrong or lying.
3. Write the invariant first. If you cannot say what is always true, there is nothing to prove.
4. Keep numbers and positions, not pointers. Use unsigned arithmetic where a value can overflow.
5. Take arguments by value, and bytes as a window; give nothing out that points in.
6. Put I/O, clocks and other people's types in an edge beside the domain, a few lines long.
7. Prefer small methods with one decision each: a proof walks every path, and so does a reader.
8. A domain's rule holds for every input from anyone. Do not lean on the caller asking first.
9. A proof that will not go through says where to look; one input that breaks the rule says the
   code is wrong. Keep that input as a test.
10. Say plainly what is proved, what is assumed, and what is not yet.

## Related work

SPARK (Ada) is the nearest: a checked subset of a language, writable parameters that may not
alias, global effects stated, used in embedded code. Hylo lends references for a call and never
stores them, as the borrow does; Swift's law of exclusivity is the one-name rule; Rust's borrow
checker holds both in the compiler. The handle draws on Morris's sealer and unsealer (1973) for
an opaque token only its maker opens, and on Spec#'s pack and unpack for an invariant that holds
only while packed. seL4 proves much more (that the code does what a specification says) at much
more cost. Frama-C, VeriFast and CBMC prove C directly.

## What the prover does, and does not yet

The prover in `tools/prover` reads a small subset of C++ and refuses the rest, with the line.
It proves each class and each function alone: no memory error, ending, and the invariant, for
every input, with Lean checking each proof. A proof file is of a set: its own domain and every
domain proved before it. It may make objects of their classes, call their methods (const ones
handed numbers too) and call their functions, so what several domains do together is claimed
and proved (`vend_checked.proof.cpp`: a machine just filled sells any drink the credit covers).
Not yet: one invariant across several classes; reference parameters under the borrow; the
handle; and `volatile` methods.
