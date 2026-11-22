# strong-coffee

A lesson in five branches: a pod coffee machine, written first as it often is (unsafe, messy and
wrong, with passing tests), then made **safe**, cleaned into **domains**, its **errors found**, and
finished **strong**: every domain isolated, simple to reason about, and its invariants proved by a
machine for every input.

| Branch | The machine is | What moves it on |
| ------ | -------------- | ---------------- |
| `1-unsafe` | unsafe, messy and wrong; its tests pass | |
| `2-safe` | safe, still messy and wrong | sanitizers, and a seeded run of random commands |
| `3-domains` | safe, in domains, still wrong | private state, one rule each, an edge for the I/O |
| `4-errors` | the same, with its errors found | invariants and claims, tried for every input |
| `5-strong` | strong | the errors fixed, and every claim proved |

`main` is `5-strong`, with the slides (`slides/`) and the approach written out (`docs/`). Each
branch has a `STAGE.md`: what this stage is, what is wrong with it, and what the next one does.

```sh
git switch 1-unsafe
make test        # the tests pass
```

MIT licensed (`LICENSE`).
