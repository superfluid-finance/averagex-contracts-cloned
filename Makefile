DEV_TARGETS = test-evm-contracts lint-evm-contracts
TEST_FORGE_OPTS = "-vv"

################################################################################
# Git Submodule Routines
################################################################################

# https://faun.pub/git-submodule-cheatsheet-29a3bfe443c3

submodule-update:
	git submodule update --recursive

submodule-sync:
	git submodule update --remote --recursive
	git submodule sync

submodule-init:
	git submodule update --init --recursive

submodule-deinit:
	git submodule deinit --all --force

@PHONY: submodule-*

################################################################################
# Dev Targets
################################################################################

dev:
	nodemon -e sol -x sh -- -c "make $(DEV_TARGETS) || exit 1"

build: build-evm-contracts

build-evm-contracts:
	cd packages/evm-contracts && npm run build

lint: lint-evm-contracts

lint-evm-contracts:
	cd packages/evm-contracts && npm run lint

test: test-evm-contracts

test-evm-contracts: build-evm-contracts
	cd packages/evm-contracts && yarn test-tdd $(TEST_FORGE_OPTS)

N_FUZZ_CONTRACT ?= SuperBoringTorexStatefulFuzzTest
N_FUZZ_TEST ?= testStatefullFuzzComplete
test-n-fuzz: build-evm-contracts
	cd packages/evm-contracts && ./script/n-fuzz.sh $(N_FUZZ_CONTRACT) $(N_FUZZ_TEST) $(N_FUZZ_EXTRA_OPTS)

@PHONY: dev build build-* lint lint-* test test-*

love:
	sl | lolcat
