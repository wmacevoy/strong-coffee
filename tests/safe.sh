#!/bin/sh
# tests/safe.sh MACHINE: the machine, built with the sanitizers, is fed the random commands of ten
# seeds. A sanitizer that catches anything ends the run, and says where. Prints "safe: PASS" if none did.
machine=${1:?tests/safe.sh MACHINE}
for seed in 1 2 3 4 5 6 7 8 9 10; do
    if ! sh tests/shake.sh $seed | "$machine" > build/shake.out 2> build/shake.err; then
        echo "safe: FAIL: seed $seed"; grep -m1 -E "ERROR|runtime error" build/shake.err; exit 1
    fi
done
echo "safe: PASS (ten seeds, 2000 commands each)"
