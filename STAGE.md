# Stage 1: unsafe, messy and wrong

`coffee.cpp` is a pod coffee machine, written the way a first version often is: one file, the
state in globals, a loop that reads commands. It takes coins, sells four drinks, gives change,
and is restocked with pods and water.

```sh
make test        # PASS: an espresso bought, and a drink refused for want of credit
```

The tests pass. Every case they try is right. And the machine is:

- **unsafe**: some input makes it write outside its memory, or makes arithmetic that C++ gives no
  meaning to. Then nothing about it can be reasoned about at all: not the next line, not the
  next customer.
- **messy**: every rule of the machine (money, pods, water) is in one loop, beside the parsing and
  the printing, and every line can change every piece of state.
- **wrong**: some sequences of commands give the wrong answer, safely.

Before you switch branches: how many of each can you find? Write them down. Then try them:

```sh
make && printf 'coin 100\ncoin 100\nbuy 0\nrefund\n' | build/coffee
```

**Next, `2-safe`:** finding what is unsafe takes tools that watch the memory (sanitizers) and
inputs nobody thought of (a seeded run of random commands). Safety comes first, because until a
program is safe, nothing else about it can be reasoned about.
