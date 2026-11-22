# Stage 4: the errors found

The machine is the same as in `3-domains`: safe, in domains, and wrong. What is new is what tries
it. Each domain's rule is no longer tried on the inputs a test thought of. It is tried **for every
input, from every state its invariant allows**, by a machine:

```sh
sh tools/lean.sh && pixi install      # once: Lean, and a Python that reads C++ as Clang does
sh tools/proofs.sh --each             # every check, going on past what fails
make counterexamples                  # the inputs that break each rule, run
```

`tools/proofs.sh` is a full compile in three steps, each one refusing the program:

1. **compile** every domain alone, every warning an error;
2. **lint**: the prover's reader refuses what has no exact meaning; code that is not proved reaches
   a domain only by a `_checked` name, so the boundary can be found by `grep`; and at each call,
   what it may write has no second name;
3. **prove** each domain (`tools/prover`): from the C++ alone it is worked out what is owed, that
   no method commits a memory error and every one keeps the invariant, for every input; a proof
   of that, written in Lean (`src/strong/*.claims.lean`), is checked by Lean and audited, trusted
   for nothing. A domain's *claims* (`src/strong/*.proof.cpp`, tests that loop over every 32-bit
   number and so could never be run) are proved the same way, and first run at small bounds.

## What was found

`sh tools/proofs.sh --each` ends:

```
proofs: FAIL: 5 found:
compile: FAIL: src/strong/vend.h
FAIL: Credit: a proof does not hold (claims/CreditClaims.lean)
FAIL: PodRack: a proof does not hold (claims/PodRackClaims.lean)
FAIL: WaterTank: a PROVE of proofs/WaterTank.proof.cpp is not proved: run at small bounds, it is false, ...
FAIL: vend_checked: the prover stopped (build/proofs/vend_checked.log)
```

(`vend` stops at the compiler again, inside the prover, for the same dead test.)

A proof that does not go through says where to look, not yet that the code is wrong: the proof
might be. So each was looked at until one input broke the rule, and those inputs are
`tests/counterexamples.cpp`. `make counterexamples`:

| | The rule | The input that breaks it | Found by |
| - | -------- | ------------------------ | -------- |
| 1 | vend: no drink sold from an empty slot | paid, no pod, water: sold | the compiler: `pods < 0` of an unsigned number is always false, so the test is dead |
| 2 | vend: sold with exactly a cup left | 250 ml: "out of water" | vend's claim, once 1 is fixed: `water > 250` should be `>=` |
| 3 | Credit: only 5, 10, 25 and 100 cents are taken | a 3-cent coin is taken | Credit's claim |
| 4 | Credit: at most 1000 cents | eleven dollar coins: 1100 | Credit's invariant: `insert` |
| 5 | Credit: nothing left once paid | 100 in, 50 paid: 50 left, and refunded again | Credit's claim: `pay` gives the change *and* keeps it |
| 6 | Credit: at most 1000 cents | a price more than the balance: 4294967295 | Credit's invariant: `pay` |
| 7 | PodRack: at most 10 a slot | the eleventh pod taken from ten: 4294967295 | PodRack's invariant: `take` |
| 8 | PodRack: at most 10 a slot | a pod put in a full slot: 11 | PodRack's invariant: `restock` |
| 9 | WaterTank: a full tank stays full | 4294967295 ml poured in: 1999 | WaterTank's claim, run at small bounds: the sum wraps |

Every one is **safe**: `make safe` passes, and `make counterexamples` runs under the sanitizers
too. They are wrong answers, and no sanitizer can see a wrong answer. Most of them were in stage 1,
behind passing tests: change given twice (5), a sold-out slot selling (1, 7), a full slot taking
more (8), any coin taken (3). One, 6, the machine never reaches, because it asks `vend` before it
pays; but a domain's rule holds for every input from anyone, so `Credit` cannot lean on its
caller asking first.

## How it was found: isolation

Each was found by reasoning about one domain, alone. To know that `PodRack` can hold 11, nothing
was read but `podrack.h`: every line of the program is safe, so nothing outside it can change
`count`, and it is reached only by its `_checked` methods. Without the domains, the same question
is about every line of `coffee.cpp`.

## A proof of the set

A domain is a set of classes and functions; the simplest is one of either, and `vend` is a
function. Each class and function is proved alone, and a proof file may also claim what they do
together: it is of its own domain and of every domain proved before it. `vend_checked.proof.cpp`
says, besides what `vend` answers, that a machine just filled sells any drink the credit covers:
it makes a `Credit`, a `PodRack` and a `WaterTank`, puts in a coin, and asks `vend`.

**Next, `5-strong`:** each error fixed in its domain, and every domain proved.
