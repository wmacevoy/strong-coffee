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

From `4-errors` on, the domains are proved. That needs Lean and a Python that reads C++ as Clang
does, fetched once (Linux, x86_64 or aarch64; Lean is about 3 GB unpacked):

```sh
sh tools/lean.sh          # Lean 4.36.0 into .tools/
pixi install              # Python with libclang into .pixi/ (https://pixi.sh)
sh tools/proofs.sh        # compile, lint and prove every domain: "proofs: PASS" on 5-strong
```

| | |
|---|---|
| `slides/strong-coffee.md` | the lesson as slides ([Marp](https://marp.app) Markdown; it reads as plain Markdown too), rendered at https://wmacevoy.github.io/strong-coffee/slides/ |
| `site/`, `.github/workflows/pages.yml` | the lesson's page, https://wmacevoy.github.io/strong-coffee, built on every push to `main` |
| `docs/STRONG_DOMAINS.md` | the approach: safe ⇒ strong, what a domain is, what a proof rests on (a draft) |
| `src/strong/` | the domains, each with its proof beside it |
| `src/machine.cpp` | the edge: commands in, words out; not proved, checked safe |
| `tools/prover/` | the prover: reads the C++, says what is owed, audits the proof |

MIT licensed (`LICENSE`).
