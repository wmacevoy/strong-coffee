#!/bin/sh
# tools/proofs.sh: the full compile of what is proved, in three steps, each refusing the program:
#   1. compile: each file under src/strong compiles alone, every warning an error;
#   2. lint: the generator reads each domain and refuses what has no exact meaning; nothing that
#      is not proved reaches in; at a call, nothing it may write has a second name;
#   3. prove: for each domain, what is owed (no memory error, every loop ends, the invariant kept)
#      is generated from the C++, and the claims' proof of it is checked by Lean and audited.
# Success prints "proofs: PASS". tools/proofs.sh DOMAIN... proves only those (compile and lint
# are still of everything). tools/proofs.sh --each goes on past what fails, and ends with every
# failure found, one line each: for finding the errors, not for passing.
#
# A domain D's files stand beside it under src/strong: D.from (which file; "function" if it is one),
# D.claims.lean (the proof of what is owed), and, if there are any, D.proof.cpp (what is claimed of
# it, as a test that cannot be run) and D.proof-claims.lean (the proof of those claims).
#
# tools/prover is a copy of the prover of strong-domain-driven-design, at a4de40f, where it is made
# and tested.
#
# Needs Lean 4.36.0 (tools/lean.sh fetches it into .tools/) and a Python with libclang (pixi
# install). Or set LEAN and PYTHON.
set -e
cd "$(dirname "$0")/.."
: "${LEAN:=$PWD/.tools/lean-4.36.0-linux/bin/lean}"
[ -n "$PYTHON" ] || { [ -x .pixi/envs/default/bin/python ] && PYTHON=$PWD/.pixi/envs/default/bin/python; } || PYTHON=python3
export LEAN PYTHON
[ -x "$LEAN" ] || { echo "proofs: cannot start: no Lean at $LEAN (sh tools/lean.sh, or set LEAN)"; exit 2; }
"$PYTHON" -c 'import clang.cindex' 2>/dev/null || { echo "proofs: cannot start: $PYTHON has no libclang (pixi install, or set PYTHON)"; exit 2; }
CC=${CC:-cc}; CXX=${CXX:-c++}; export CC CXX

# Each domain, in the order it is proved.
ALL="Credit PodRack WaterTank Machine"
EACH=; [ "$1" != --each ] || { EACH=1; shift; }
DOMAINS=${*:-$ALL}
FOUND=$PWD/build/found.txt; : > "$FOUND"
found() { echo "$1" >> "$FOUND"; [ -n "$EACH" ] || { echo "proofs: $1"; exit 1; }; }
STRONG=src/strong

# The prover reads a domain as a directory (from/, claims/, proofs/); it is put together in
# build/proofs from the files beside each class, with the program's src as it stands, less them.
W=$PWD/build/proofs
rm -rf "$W" && mkdir -p "$W/from" "$W/claims" "$W/proofs" "$W/subject"
for d in $ALL; do
    at=$(dirname "$(find "$STRONG" -name "$d.from")")
    cp "$at/$d.from" "$W/from/$d"
    [ ! -f "$at/$d.claims.lean" ] || cp "$at/$d.claims.lean" "$W/claims/${d}Claims.lean"
    [ ! -f "$at/$d.proof.cpp" ] || cp "$at/$d.proof.cpp" "$W/proofs/$d.proof.cpp"
    [ ! -f "$at/$d.proof-claims.lean" ] || cp "$at/$d.proof-claims.lean" "$W/claims/${d}ProofClaims.lean"
done
tar -c --exclude='*.from' --exclude='*.lean' --exclude='*.proof.cpp' src | tar -x -C "$W/subject"
SUBJECT=$W/subject; SUBJECT_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo none); export SUBJECT SUBJECT_COMMIT
PROVER=$PWD/tools/prover

# 1. compile
for f in "$SUBJECT/$STRONG"/*.h; do
    echo "#include \"${f#$SUBJECT/src/}\"" | "$CXX" -std=c++17 -fsyntax-only -Wall -Wextra -Werror -I"$SUBJECT/src" -x c++ - || found "compile: FAIL: ${f#$SUBJECT/}"
done
[ -s "$FOUND" ] || echo "compile: ok"

# 2. lint
READ_ONLY=1 DOMAIN="$W" "$PROVER/prove.sh" $ALL
STRONG=$STRONG DOMAIN="$W" "$PYTHON" "$PROVER/ingress.py" $ALL
STRONG=$STRONG INCLUDE="$W/subject" "$PYTHON" "$PROVER/lint.py"

# 3. prove
# A proof file is of a set: its own domain and every one proved before it in the same run. So each
# domain is proved in one run with those before it that were proved.
ok=""
for d in $DOMAINS; do
    DOMAIN="$W" "$PROVER/prove.sh" $ok $d > "$W/$d.log" 2>&1 || { tail -n 30 "$W/$d.log"; found "$(grep -E '^FAIL' "$W/$d.log" | tail -n 1 | grep . || echo "FAIL: $d: the prover stopped (build/proofs/$d.log)")"; continue; }
    grep -E "^(PROVED|RAN) $d[ ,:]" "$W/$d.log" || true
    ok="$ok $d"
done
if [ -s "$FOUND" ]; then echo "proofs: FAIL: $(wc -l < "$FOUND") found:"; cat "$FOUND"; exit 1; fi
echo "proofs: PASS"
