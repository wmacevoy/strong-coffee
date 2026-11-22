---
marp: true
title: Strong coffee
paginate: true
---

# Strong coffee

A pod coffee machine, from **unsafe, messy and wrong** to **strong**, in five branches.

`git switch 1-unsafe` … `git switch 5-strong`

---

## Safe ⇒ Strong

**The assumption, first:** every line of code is *safe*.
No memory error, it ends, it touches only what it was lent.
Safe, **not** correct.

**Given that, strong is proved:**
each domain is isolated, reasoned about alone, and its invariants are proved for every input.

---

## What "strong" means

- **Isolation**: what is true of a domain follows from its own text
- **Simplified reasoning**: that text is all a reader must hold
- **Proof of invariants**: shown for every input, by a machine, audited

---

## 1. `1-unsafe`: the tests pass

```cpp
int credit = 0;
int pods[4] = { 10, 10, 10, 10 };
char display[24];
...
} else if ( strcmp( word, "buy" ) == 0 ) {
  if ( credit < prices[a] ) {
```

`make test`: **PASS**. Two cases, both right.

How many errors can you find?

---

## 2. `2-safe`: safety first

`make safe`: sanitizers watching, random commands from ten seeds.

| Command | Sanitizer |
|---|---|
| `buy 4` | index 4 out of bounds |
| `buy 2` | buffer overflow: "caramel macchiato" |
| `coin 2147483647`, `coin 1` | signed integer overflow |

Fixed: unsigned numbers, tested indices, sized writes.
Until it is safe, **nothing** can be reasoned about.

---

## Safe is not correct

```sh
printf 'coin 100\ncoin 100\nbuy 0\nrefund\n' | build/coffee
```

```
enjoy your espresso
change 50
change 50
```

Change given twice. No sanitizer can see a wrong answer.

---

## 3. `3-domains`: one rule, one place

| Domain | Rule |
|---|---|
| `Credit` | at most 1000 cents |
| `PodRack` | at most 10 a slot |
| `WaterTank` | at most 2000 ml |
| `vend` | a function: no state |

State private. Rule written as `invariant()`. The edge, `machine.cpp`, only reads, asks and prints.

No answer changed: 6000 random commands, same 6000 answers.

---

## What isolation buys

To know whether a slot can hold 11:

- before: read all of `coffee.cpp`
- now: read `podrack.h`, 50 lines

Every line is safe, so nothing else can change `count`.

---

## 4. `4-errors`: for every input

```cpp
PROOF( a_drink_is_sold_exactly_when_it_is_paid_for_and_can_be_made )
{
  for ( uint32_t credit : all<uint32_t>() )
    for ( uint32_t price : all<uint32_t>() )
      for ( uint32_t pods : all<uint32_t>() )
        for ( uint32_t water : all<uint32_t>() )
          PROVE( Strong::vend_checked( credit, price, pods, water ) != 0
                 || ( credit >= price && pods > 0 && water >= 250 ) );
```

A test that can never be run: 2^128 rounds. Proved instead.

---

## Nine rules broken

| Found by | Error |
|---|---|
| the compiler | `pods < 0` is always false: sold-out is dead code |
| a claim | `water > 250`: refuses with exactly a cup |
| a claim | any coin taken; change kept and given again |
| an invariant | 1100 cents; a slot of 11; a slot of 4294967295 |
| a claim, run small | a full tank poured into: 1999 ml |

A failed proof says *where*. One input says *it's the code*: `make counterexamples`.

---

## A proof of the set

```cpp
PROOF( a_full_machine_sells_whenever_the_credit_covers_the_price )
{
  for ( uint32_t coin : all<uint32_t>() )
    for ( uint32_t price : all<uint32_t>() )
      for ( uint32_t slot : all<uint32_t>( 0, 3 ) ) {
        Strong::Credit credit;
        Strong::PodRack rack;
        Strong::WaterTank tank;
        credit.insert_checked( coin );
        PROVE( Strong::vend_checked( credit.getBalance_checked(), price,
                 rack.podsIn_checked( slot ), tank.getLevel_checked() ) == 0
               || credit.getBalance_checked() < price );
      }
}
```

Each domain proved alone; what they do together, proved too.

---

## 5. `5-strong`

```sh
make test              # PASS
make safe              # safe: PASS
make counterexamples   # none: every rule holds
sh tools/proofs.sh     # proofs: PASS
```

```
PROVED Credit: 10 statements
PROVED Credit, as proofs/Credit.proof.cpp says it: every round of every loop
PROVED PodRack: 8 statements
...
```

---

## What it rests on

- every line is safe (checked: `make safe`)
- compiler, libraries, machine; memory enough
- the prover reads the C++ rightly (compared, not proved)
- the invariant says what you meant: **read it**

Not proved: that the machine as a whole serves coffee. That is tested.

---

## Design, test, prove

| Held by | Holds |
|---|---|
| design | what is true by form: `private`, `_checked` |
| proof | what one domain does, for every input |
| test | what nothing else reaches yet |

*"I should test this"* → *"could I prove this, and what would make it simpler?"*

---

## Not events: a borrow

Actors isolate by copying every message.
A borrow isolates for reasoning **without the copy**:

- lend references for one call
- none kept
- nothing lent for writing has a second name

Fast enough for embedded code.

---

## Take away

1. Safety first, and say how it is checked
2. One rule, one domain, state private
3. Write the invariant first
4. Try every input, not the ones you thought of
5. A failed proof says where to look; keep the input that broke it
6. Say what is proved, what is assumed, what is not yet

`docs/STRONG_DOMAINS.md`
