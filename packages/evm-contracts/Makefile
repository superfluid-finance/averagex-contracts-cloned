DEV_TARGETS = test-tdd lint
TDD_FORGE_OPTS = "-vv"

dev:
	nodemon -e sol -x sh -- -c "make $(DEV_TARGETS) || exit 1"

build:
	forge build

lint:
	solhint -w 0 `find script src test -name '*.sol' ! -name '.*'`

test-tdd:
	FOUNDRY_PROFILE=tdd forge test $(TDD_FORGE_OPTS)

test-ci:
	FOUNDRY_PROFILE=ci forge test -vv

test-coverage:
	FOUNDRY_PROFILE=coverage forge coverage

N_FUZZ_CONTRACT ?= SuperBoringTorexStatefulFuzzTest
N_FUZZ_TEST ?= testStatefullFuzzComplete
test-n-fuzz: build-evm-contracts
	../../script/n-fuzz.sh $(N_FUZZ_CONTRACT) $(N_FUZZ_TEST) $(N_FUZZ_EXTRA_OPTS)

.PHONY: dev build lint test-*
