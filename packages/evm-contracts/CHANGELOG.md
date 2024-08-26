ChangeLog
=========

All notable changes to the evm-contracts of SuperBoring (code name: AverageX) will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.1.1-dev] TO BE RELEASED

### Added

**Torex**

- Univ3 multi hop twap observer (#130).

### Fixes

**SuperBoring**

- Improved _requireRC3Quirk using block number (#139).

## [v0.1.0] 2024-08-06

This is the version after completing the sherlock.xyz private auditing contest.

### Added

**SuperBoring**

- EmissionTreasury to support emission boost factor (#109).
- SuperBoring.govUpdateLogic completed, and added test SuperBoringUpgradabilityTest (#109).

### Changed

**Torex**

- Torex.VERSION: 1.0.0-rc3 -> 1.0.0
- Torex to require 0.8.26 solc (#101).
- ITorex interface now has VERSION function.
- New error `Torex.LIQUIDITY_MOVER_NO_SAME_BLOCK` for disallowing LMEs in the same block.

**SuperBoring**

- _updateStake now also adjustEmission (#109).

**Misc**

- Update to solc 0.8.26 (#101).

### Fixes

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
  - added new test contract: SuperBoringMoreQETest.
  - ensure emission pool created in govQEEnableForTorex (#129)

**Misc**

- Fix toInt96(int256) range issue (#107)
  - the bug does not have production impact.

## [UNVERSIONED]

This is the first public launch of SuperBoring. It is launched on BASE. Previously, it was also launched on CELO as the
test environment, and an earlier version of contracts on Optimism L2 as a stealth launch.
