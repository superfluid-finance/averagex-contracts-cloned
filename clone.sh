#!/usr/bin/env bash

_D=$(readlink -f "$(dirname "$0")")

set -xe

# by default, it is under a worktree of averageX project
TARGET_BRANCH_GIT_DIR="$_D/../develop"

rsync --archive "${TARGET_BRANCH_GIT_DIR}"/{Makefile,.envrc,flake.lock,flake.nix} "$_D"/
rsync --archive "${TARGET_BRANCH_GIT_DIR}"/packages/evm-contracts/ "$_D"/packages/evm-contracts/
# TODO using xxd -r -p due to some stupid forge ffi hex string issue
(cd "${TARGET_BRANCH_GIT_DIR}"; ./tasks/show-git-rev.sh) > sync.git-rev
