#!/bin/sh
# tests/run.sh MACHINE: each tests/*.in is fed to the machine, and what it says must be tests/*.out.
# Prints "PASS" when every case says what it should.
machine=${1:?tests/run.sh MACHINE}
fail=0
for input in tests/*.in; do
    expected=${input%.in}.out
    if "$machine" < "$input" | diff -u "$expected" - > /dev/null; then
        echo "ok   $input"
    else
        echo "FAIL $input"; "$machine" < "$input" | diff -u "$expected" -; fail=1
    fi
done
[ $fail = 0 ] && echo PASS || { echo FAIL; exit 1; }
