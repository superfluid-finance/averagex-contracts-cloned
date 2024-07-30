ChangeLog
=========

All notable changes to the evm-contracts of SuperBoring (code name: AverageX) will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.1.0] (!!WIP!!)

This is the version after completing the sherlock.xyz private auditing contest.

## Added

**SuperBoring**

- EmissionTreasury to support emission boost factor (#109).
- SuperBoring.govUpdateLogic completed, and added test SuperBoringUpgradabilityTest (#109).

## Changed

**Torex**

- Torex to require 0.8.26 solc (#101).
- Mark Torex VERSION 1.0.0-rc4.dev. !!WIP!!

**SuperBoring**

- _updateStake now also adjustEmission (#109).

**Misc**

- Update to solc 0.8.26 (#101).

## Fixes

**Torex**

- Fix Torex 1.0.0-rc3 quirk: onLiquidityMoved was called twice (#100).
  - added TorexController test.

**SuperBoring**

- SuperBoring to include the Torex 1.0.0-rc3 quirk (#103).
- Fix A Few DistributionFeeDIP issues (#106).
  - handle invalid distributor addresses better.
- DistributionFeeDIP should remember prevDistributor (#110).
- Fix a few referral logic (#108)
  - do not create the pod for address(0);
  - fix a bug that creates pods for pods during flow update;
  - make referral logic more robust.
- QE Bug: fix latent QE issue (#111).
  - added new test case: testLatentQE.

**Misc**

- Fix toInt96(int256) range issue (#107)
  - the bug does not have production impact.

## [UNVERSIONED]

This is the first public launch of SuperBoring. It is launched on BASE. Previously, it was also launched on CELO as the
test environment, and an earlier version of contracts on Optimism L2 as a stealth launch.
