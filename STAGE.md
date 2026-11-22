# Stage 3: safe, in domains, still wrong

The machine's rules were in one loop, beside the parsing and the printing, and every line could
change every piece of state. Now each rule has a place of its own, a **domain**: its state private,
reached only through its methods, and what is always true of it written down as `invariant()`.

| Domain | What it is | Its rule |
| ------ | ---------- | -------- |
| `src/strong/credit.h`, `Credit` | the money put in and not yet spent | never more than 1000 cents |
| `src/strong/podrack.h`, `PodRack` | the pods in four slots | a slot holds at most 10 |
| `src/strong/watertank.h`, `WaterTank` | the water | at most 2000 ml |
| `src/strong/vend.h`, `vend` | may a drink be sold? | a function: no state, its answer depends only on what it is told |

The simplest domain is one class, or one function: `vend` is a domain too.

What is left is the **edge**, `src/machine.cpp`: it reads a command, asks the domains, and prints.
It is not one of the domains and is not proved: it is safe (`make safe`), and that is all that
is assumed of it.

```sh
make test        # PASS
make safe        # safe: PASS
```

## Nothing was fixed

This stage moved code and changed no answer. The same 6000 random commands, fed to this machine and
to `2-safe`'s, give the same 6000 answers, wrong ones included:

```sh
for i in 1 2 3; do sh tests/shake.sh $i; done > build/s.in
git show 2-safe:coffee.cpp > build/s2.cpp && c++ -std=c++17 -o build/s2 build/s2.cpp
build/s2 < build/s.in > build/a.out; make -s && build/coffee < build/s.in > build/b.out
cmp build/a.out build/b.out && echo same
```

## What it bought

Read `src/strong/podrack.h` alone. It is 50 lines, and nothing outside it can change `count`: not
the edge, not `Credit`, not a stray write (every line is safe). So to know whether a slot can ever
hold more than 10, you read 50 lines, not the machine. That is **isolation**, and it is what makes
the reasoning simple: each rule is checked against one domain, from any state its invariant
allows.

Each domain's rule is written, and none has been checked. Some do not hold.

**Next, `4-errors`:** each rule is tried for every input, not the inputs a test thought of. The
errors are found there.
