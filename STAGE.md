# Stage 2: safe, still messy and wrong

**Safety first.** Until a program is safe, nothing about it can be reasoned about: a write outside
an array may change any variable, and arithmetic C++ gives no meaning to lets the compiler do
anything at all. So the first move is not to make the machine right. It is to make every line
safe: no memory error, every loop ends, nothing touched that was not handed over.

```sh
make safe        # the sanitizers watch, and ten seeds of random commands are fed in: "safe: PASS"
make test        # the old tests still pass
```

## What stage 1 did, under the sanitizers

`make safe` is new in this stage. Run its check on stage 1's machine, and it stops at the first
seed:

```sh
git show 1-unsafe:coffee.cpp > build/stage1.cpp
c++ -std=c++17 -g -fsanitize=address,undefined -fno-sanitize-recover=all -o build/stage1 build/stage1.cpp
sh tests/safe.sh build/stage1      # safe: FAIL: seed 1, index 4 out of bounds for type 'int [4]'
```

Each of these, tried alone:

| Command | What the sanitizer said |
| ------- | ----------------------- |
| `buy 4` | `index 4 out of bounds for type 'int [4]'` |
| `buy 2`, with credit | `global-buffer-overflow`: "enjoy your caramel macchiato" is 28 bytes, and `display` holds 24 |
| `coin 2147483647`, `coin 1` | `signed integer overflow: 2147483647 + 1 cannot be represented in type 'int'` |
| `restock 7 1` | a load outside `pods` |
| `fill 2147483647` | `signed integer overflow: 2000 + 2147483647` |

The tests never tried a fifth slot, the drink with the long name, or a big number. A customer at
the machine would, sooner or later.

## What changed

- Every number is `uint32_t`. Unsigned arithmetic always has a meaning: it wraps.
- What the customer types is read by `strtoul`, which has a meaning for every input.
- Every slot is tested (`a >= 4`) before it is used as an index.
- Text is written with its size (`snprintf`), into room enough.

Nothing else. The shape is the same.

## What this rests on

That every line is safe is now **checked, not proved**: by the sanitizers, on the inputs the
seeds made. That is the assumption the rest of the lesson stands on, stated plainly: *every line of
code is safe.* Safe, not correct.

## Still wrong

The machine is safe and still gives wrong answers. The sanitizers cannot see them: a wrong answer
is not a memory error. For instance:

```sh
make && printf 'coin 100\ncoin 100\nbuy 0\nrefund\n' | build/coffee
```

**Next, `3-domains`:** before the errors can be found, the machine is cleaned into domains, so that
each rule (money, pods, water, what may be sold) can be reasoned about alone.
