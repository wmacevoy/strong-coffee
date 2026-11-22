#!/bin/sh
# tests/shake.sh SEED [COUNT]: COUNT random commands (default 2000), the same ones for the same SEED.
# Numbers are drawn to reach the edges: small ones, slots past the last, and ones near 2^31 and 2^32.
seed=${1:?tests/shake.sh SEED [COUNT]}
awk -v seed="$seed" -v n="${2:-2000}" 'BEGIN {
    srand(seed)
    split("coin buy refund restock fill status", cmd, " ")
    split("0 1 2 3 4 5 9 10 25 100 250 2000 -1 2147483647 2147483648 4294967295", edge, " ")
    for (i = 0; i < n; i++) {
        c = cmd[int(rand() * 6) + 1]
        a = (rand() < 0.5) ? int(rand() * 6) : edge[int(rand() * 16) + 1]
        b = (rand() < 0.5) ? int(rand() * 12) : edge[int(rand() * 16) + 1]
        print c, a, b
    }
}'
