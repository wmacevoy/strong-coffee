# Stage 6: parts

The four domains of `5-strong` were each proved, but the rule that spans them was not. A drink is
sold only when it is paid for and can be made, and then a pod, a cup of water and the price are
all taken. That rule was in the edge, `src/machine.cpp`, which is not proved:

```cpp
switch ( Strong::vend_checked( credit.getBalance_checked(), prices[a], rack.podsIn_checked( a ), tank.getLevel_checked() ) ) {
  case 0:
    rack.take_checked( a );
    tank.draw_checked( 250 );
    ...
    credit.pay_checked( prices[a] )
```

Forget one of those three lines and every domain is still proved. Here the rule moves into a domain
of its own, `Strong::Machine` (`src/strong/machine.h`), which **has** a Credit, a PodRack and a
WaterTank as parts:

```sh
make test                  # PASS: the machine says what it said on 5-strong
make safe                  # safe: PASS
make counterexamples       # none: every rule holds on these inputs
sh tools/proofs.sh         # proofs: PASS
```

| | Where | What |
| - | ----- | ---- |
| the sale | `Machine::buy_checked` | sold only when the credit covers the price, the slot has a pod, and the tank a cup; then one pod, one cup and the price are taken, and the rest is change |
| what it owes | `Machine::invariant` | at most 10.00 at once: the credit not yet spent and the change not yet given back |
| the edge | `src/machine.cpp` | one `Strong::Machine`; it reads commands, asks the machine, and prints. It no longer knows how a drink is sold |
| `vend` | gone | its rule is the machine's now, so it is not kept in two places |

## What a part is

A part is a field whose type is another proved class (`Machine.from` says `uses Credit`, and so
on). The machine makes each part in its constructor and changes it only by that part's own
methods. It never copies a part or hands it on. So:

- each part is still proved **alone**, and knows nothing of the others or of drinks;
- the machine is proved from what each part's methods do. That a part keeps its own rule is taken
  from the part's proof, not proved again (`Machine.claims.lean` imports `CreditClaims` and the
  others);
- the machine's invariant is each part's own, and then the machine's: `change <= 1000 - balance`.

The rule that spans the domains now has one home, and it is proved there.

## What it rests on

The same as `5-strong`: every line of code is safe; the compiler, the libraries and the machine do
what they say; the prover reads the C++ rightly, and Lean is right; and the invariant says what you
meant.

What is **not** proved: that the edge prints the right words, and that it hands `buy` the right
price for a slot. Those are tested.

`tools/prover` is the prover at strong-domain-driven-design's a4de40f, the first that proves a part.
