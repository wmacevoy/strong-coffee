# Stage 5: strong

Each error from `4-errors` is fixed in the domain it belongs to, and every domain is proved.

```sh
make test                  # PASS, and two new cases: change given once, and what is refused
make safe                  # safe: PASS
make counterexamples       # none: every rule holds on these inputs
sh tools/proofs.sh         # proofs: PASS
```

| | Fixed in | How |
| - | -------- | --- |
| 1 | `vend.h` | sold out when `pods == 0`, not the dead `pods < 0` |
| 2 | `vend.h` | water for a cup is `>= 250`, not `> 250` |
| 3, 4 | `credit.h` | `insert` takes only 5, 10, 25 or 100 cents, and only while the balance stays at most 1000; it says whether it took the coin |
| 5, 6 | `credit.h` | `pay` leaves nothing behind, and pays nothing from a balance that does not cover the price |
| 7 | `podrack.h` | `take` takes nothing from an empty slot |
| 8 | `podrack.h` | `restock` puts in nothing that does not fit |
| 9 | `watertank.h` | `fill` tests what fits (`ml > 2000 - level`) before adding, so nothing wraps |

The edge, `src/machine.cpp`, now says "coin returned" and "slot 1 has room for 0". Nothing else in
it changed.

## What "strong" means here

Every domain is:

- **isolated**: its state is private and reached only by its `_checked` methods. Nothing else in
  the program can change it, so what is true of it follows from its own text.
- **simple to reason about**: each is read alone. `podrack.h` is 52 lines, and those 52
  lines are all there is to know about the pods.
- **proved**: for every input, from every state its invariant allows, no method commits a memory
  error, every method ends, and every method keeps the invariant. Its claims (`*.proof.cpp`) are
  proved too. Lean checks each proof, and the audit trusts it for nothing. And what they do
  together: `vend_checked.proof.cpp` proves that a machine just filled sells any drink the credit
  covers, from any slot, a claim of the four domains at once.

## What it rests on

Proved is relative to what is assumed, stated here:

- **every line of code is safe**: it commits no memory error, it ends, and it touches nothing it
  was not handed. Safe, not correct. The edge is not proved; that it is safe is checked by
  `make safe`, not proved. A strong domain stays strong beside code that is safe and wrong: a
  wrong answer from it is one more input;
- the compiler, the libraries and the machine do what they say, and there is memory and stack
  enough to run;
- the prover reads the C++ rightly (it compares its model with the compiled C++ on 2001 calls a
  domain, which is a test, not a proof), and Lean is right;
- the invariant says what you meant. It is a line of C++: read it.

What is **not** proved: that the edge prints the right words, and that the machine as a whole
serves coffee. Those are tested.

`main` has the slides (`slides/`) and the approach written out (`docs/STRONG_DOMAINS.md`).
