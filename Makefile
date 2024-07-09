DEV_TARGETS = test-tdd-evm-contracts lint-evm-contracts
TDD_FORGE_OPTS = "-vv"

################################################################################
# Git Submodule Routines
################################################################################

# https://faun.pub/git-submodule-cheatsheet-29a3bfe443c3

submodule-init:
	git submodule update --init --recursive

submodule-update:
	git submodule update --recursive

submodule-sync:
	git submodule update --remote --recursive
	git submodule sync

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

test: test-ci-evm-contracts

test-tdd-evm-contracts: build-evm-contracts
	cd packages/evm-contracts && npm run test-tdd -- $(TDD_FORGE_OPTS)

test-ci-evm-contracts: build-evm-contracts
	cd packages/evm-contracts && npm run test-ci

test-coverage-evm-contracts: build-evm-contracts
	cd packages/evm-contracts && npm run test-coverage

N_FUZZ_CONTRACT ?= SuperBoringTorexStatefulFuzzTest
N_FUZZ_TEST ?= testStatefullFuzzComplete
test-n-fuzz: build-evm-contracts
	cd packages/evm-contracts && ./script/n-fuzz.sh $(N_FUZZ_CONTRACT) $(N_FUZZ_TEST) $(N_FUZZ_EXTRA_OPTS)

@PHONY: dev build build-* lint lint-* test test-*

love:
	sl | lolcat
