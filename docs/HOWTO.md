# How it is done

The branches show each stage; this says how to do it yourself: what to run, how a stage was made,
and how to write a domain and its proof. The example throughout is `WaterTank`, the smallest
domain, with `Machine` where a domain has parts.

## Getting the tools

```sh
make test                 # needs only a C++17 compiler
sh tools/lean.sh          # once: Lean 4.36.0 into .tools/ (about 3 GB unpacked; Linux)
pixi install              # once: a Python with libclang into .pixi/ (https://pixi.sh)
```

If you have Lean and a Python with libclang elsewhere, set `LEAN` (the path to `bin/lean`) and
`PYTHON` instead.

## The checks

| Run | What it says | Proves anything? |
| --- | ------------ | ---------------- |
| `make test` | each `tests/*.in` fed to the machine says what `tests/*.out` says: `PASS` | no: the inputs written down |
| `make safe` | built with the address and undefined-behavior sanitizers, fed 2000 random commands from each of ten seeds (`tests/shake.sh`): `safe: PASS` | no: the inputs the seeds made |
| `make counterexamples` | each input that once broke a rule, run against the fixed code: none breaks one | no: one input per rule |
| `sh tools/proofs.sh` | compile, lint and prove every domain: `proofs: PASS` | yes, for every input, of what each domain owes and claims |
| `sh tools/proofs.sh WaterTank` | the same, proving only the domains named (compile and lint are of everything) | yes, of those |
| `sh tools/proofs.sh --each` | goes on past what fails, and ends with one line per failure: for finding errors, not passing | |

`tools/proofs.sh` is a compile in three steps, and each can refuse the program:

1. **compile**: each header under `src/strong/` alone, every warning an error;
2. **lint**: the prover's reader refuses C++ it cannot give an exact meaning to; code that is not
   proved reaches a domain only by a name ending `_checked`; at each call, what it may write has no
   second name;
3. **prove**: for each domain, what is owed is worked out from the C++ and nothing else (no method
   commits a memory error, each ends, each keeps the invariant), and the Lean proof beside the
   domain is checked against it and audited.

A domain alone takes seconds once Lean is there (`WaterTank`: about 10 on a laptop).

## How the stages were made

Each branch is one commit on the one before, so `git diff 3-domains 4-errors` is exactly what a
stage changed, and its `STAGE.md` says why. Each stage was made the same way: run the next check,
read what it finds, change only what it found, and show the check now passes.

| Stage | What was run | What it found | What changed |
| ----- | ------------ | ------------- | ------------ |
| `1-unsafe` | `make test` | nothing: the tests pass | written as it often is: one file, globals, `int` |
| `2-safe` | the sanitizers, and seeded random commands (`make safe`, new) | five errors no test had reached: three reads or writes outside an array, two signed overflows | unsigned numbers, every index tested, text written with its size; nothing else |
| `3-domains` | the same 6000 random commands, fed to this machine and to `2-safe`'s | the same 6000 answers: no answer changed, the wrong ones included | each rule moved into a class of its own under `src/strong/`, its state private, its rule written as `invariant()`; the reading and printing left in `src/machine.cpp`, the edge |
| `4-errors` | `sh tools/proofs.sh --each` (the prover copied in) | five failures; followed up, nine broken rules, each kept as one input in `tests/counterexamples.cpp` | the methods the edge calls renamed `_checked`; claims written (`*.proof.cpp`); no fix yet |
| `5-strong` | the same, after each fix | `proofs: PASS`, and each counterexample now holds | each error fixed in its domain |
| `6-parts` | the same | that the rule spanning the domains (a sale takes a pod, a cup and the price) was in the edge, where no proof looks | a `Machine` that has the three as parts, and keeps that rule; proved |

A proof that fails says where to look, not yet that the code is wrong: the proof may be. So in
`4-errors` each failure was followed until one input broke the rule, and that input became a
test. Then the code is wrong, and the test says so to someone who never runs Lean.

## Writing a domain

A domain is a class under `src/strong/`, in namespace `Strong`:

```cpp
class WaterTank
{
public:
  WaterTank() { level = 2000; }

  uint32_t getLevel_checked() const { return level; }

  /* Water drawn for a cup, if there is that much. */
  bool draw_checked( uint32_t ml )
  {
    if ( level < ml ) return false;
    level = level - ml;
    return true;
  }

  /* It never holds more than 2000 ml. */
  bool invariant() const { return level <= 2000; }

private:
  uint32_t level;
};
```

- **The invariant first.** `invariant()` is what is always true of the state, in C++. If you
  cannot write it, there is nothing to prove yet.
- **Whole numbers of a fixed width, unsigned** where a value can overflow: unsigned arithmetic
  wraps, which has a meaning; signed overflow has none.
- **Every method the edge calls ends in `_checked`**, so the boundary can be found by `grep`.
- **No pointer, reference or iterator into the state** is given out or kept.
- **A part** is a field whose type is another domain (`Machine` has `Credit credit;`). It is made in
  the constructor's list and changed only by its own methods. Those that change it are statements,
  so ask first by its const methods: `Machine::buy_checked` tests `rack.podsIn_checked( slot ) ==
  0` before it calls `rack.take_checked( slot )`.

Then tell the prover about it:

1. `src/strong/WaterTank.from` names the file: one line, `src/strong/watertank.h`. A domain with
   parts says so, a line each (`Machine.from`: `uses Credit`, `uses PodRack`, `uses WaterTank`).
2. Add the name to `ALL` in `tools/proofs.sh`, after every domain it uses.

## Writing the proof of what is owed

Run the prover before writing any proof:

```sh
sh tools/proofs.sh WaterTank
# FAIL: WaterTank: a proof does not hold (claims/WaterTankClaims.lean)
```

It has worked out what must be proved, and written it into `build/proofs/gen/`:

- `WaterTankModel.lean`: each method as a Lean function, generated from the C++. A method gives
  `none` where the C++ would commit a memory error, so a result at all means it is safe. `Inv` is
  `invariant()`.
- `WaterTankOwed.lean`: `structure WaterTank.Owed`, one field per thing owed, each with a line
  saying what it means:

```lean
  /-- `draw_checked` leaves the invariant true. -/
  draw_checked_inv : ∀ (me : WaterTank) (ml : BitVec 32) (me' : WaterTank) (r : BitVec 8),
    WaterTank.Inv me → WaterTank.draw_checked me ml = some (me', r) → WaterTank.Inv me'
```

Read these; never edit them. Then write `src/strong/WaterTank.claims.lean`, a theorem per field and
`owed` to gather them:

```lean
import WaterTankOwed

namespace WaterTank
namespace Claims

theorem draw_checked_inv : ∀ (me : WaterTank) (ml : BitVec 32) (me' : WaterTank) (r : BitVec 8),
    Inv me → WaterTank.draw_checked me ml = some (me', r) → Inv me' := by
  intro me ml me' r hinv h
  simp only [WaterTank.draw_checked] at h   -- the method, as the model says it
  split at h                                -- one case for each side of its `if`
  · simp at h; rw [← h.1]; exact hinv       -- nothing drawn: the state is as it was
  · simp at h; rw [← h.1]; simp only [Inv] at *; bv_omega   -- the arithmetic, on 32-bit numbers

-- ... a theorem for each other field ...

theorem owed : WaterTank.Owed :=
  { new_safe, new_inv, getLevel_checked_safe, getLevel_checked_same, fill_checked_safe, fill_checked_inv,
    draw_checked_safe, draw_checked_inv }

end Claims
end WaterTank
```

Most proofs here are that shape: unfold the method with `simp only [...]`, take each case of each
`if` with `split` or `by_cases`, and leave the arithmetic to `bv_omega`. A domain with parts may
`import CreditClaims` and use a part's own theorems (`Machine.claims.lean` does). What is not
allowed: `sorry`, an axiom of your own, `native_decide` or `bv_decide`. The audit refuses them
(`tools/prover/README.md`).

Run it again: `PROVED WaterTank: 8 statements`. When a step fails, the Lean error is in
`build/proofs/WaterTank.log`, with the line of the claims file.

## Breaking it on purpose

A proof never seen failing has not been seen to work. Break the code and run it again. Here the
tank's overflow test is off by one, `ml > 2001 - level`:

```
claims/WaterTankClaims.lean:29:47: error: omega could not prove the goal:
...
proofs: FAIL: WaterTank: a proof does not hold (claims/WaterTankClaims.lean)
```

Line 29 is `fill_checked_inv`: the proof that filling keeps the tank at 2000 ml or less. Then put
the code back.

## Writing claims: what the domain does

The invariant says what is always true; a claim says what the domain does. Claims are written as a
test that loops over every 32-bit number, and so could never be run, in
`src/strong/WaterTank.proof.cpp`:

```cpp
#include "src/strong/watertank.h"
#include "forall.h"

/* Pouring water into a full tank leaves it full, whatever is poured. */
PROOF( a_full_tank_stays_full )
{
  for ( uint32_t ml : all<uint32_t>() ) {
    Strong::WaterTank tank;
    tank.fill_checked( ml );
    PROVE( tank.getLevel_checked() == 2000 );
  }
}
```

The prover first runs it with small bounds, as a test. A false claim usually stops there:

```
false when run at small bounds: PROVE( tank.getLevel_checked() == 1999 ), line 17
```

Then it writes what must be proved for every round to `build/proofs/gen/WaterTankProofOwed.lean`,
and you prove it in `src/strong/WaterTank.proof-claims.lean`, the same way. The C++ of a proof file
is plain on purpose. A local made from a method's answer (`uint32_t paid = m.getBalance_checked();`)
is refused, so to compare before and after, make two objects and give them the same inputs
(`Machine.proof.cpp`).

A proof file is of a set: its own domain and every domain proved before it in the same run. So it
may claim what several domains do together.

## What is proved, and what is not

`proofs: PASS` means: for every input, from every state the invariant allows, each domain's
methods commit no memory error, end, keep the invariant, and do what the claims say. It rests on
every line being safe (checked by `make safe`, not proved), on the compiler and the machine, on the
prover reading the C++ rightly, and on Lean. The edge, `src/machine.cpp`, is not proved: it is
tested. And nothing proves the invariant says what you meant; that is read by a person.
