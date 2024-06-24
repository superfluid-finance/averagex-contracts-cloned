#!/usr/bin/env sh

N_FUZZ_CONTRACT="$1"
N_FUZZ_TEST="$2"
shift 2

set -xe
seq 1 "${N_FUZZ_PARALLEL:-4}" | \
    xargs -P9999 -l1 -- sh -c \
        "forge test --match-contract="$N_FUZZ_CONTRACT" --match-test="$N_FUZZ_TEST" \
            --fuzz-runs "${N_FUZZ_RUNS:-3000}" "$@""
