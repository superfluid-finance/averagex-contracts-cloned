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

build: build-evm-contracts

build-evm-contracts:
	make -C packages/evm-contracts build

lint: lint-evm-contracts

lint-evm-contracts:
	make -C packages/evm-contracts lint

test: test-ci-evm-contracts

test-tdd-evm-contracts: build-evm-contracts
	make -C packages/evm-contracts test-tdd

test-ci-evm-contracts: build-evm-contracts
	make -C packages/evm-contracts test-ci

test-coverage-evm-contracts: build-evm-contracts
	make -C packages/evm-contracts test-coverage

@PHONY: build build-* lint lint-* test test-*

love:
	sl | lolcat
