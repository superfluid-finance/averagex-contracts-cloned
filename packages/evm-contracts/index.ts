//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CFAv1Forwarder
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xcfA132E353cB4E398080B9700609bb008eceB125)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0xcfA132E353cB4E398080B9700609bb008eceB125)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0xcfA132E353cB4E398080B9700609bb008eceB125)
 */
export const cfAv1ForwarderABI = [
  {
    stateMutability: 'nonpayable',
    type: 'constructor',
    inputs: [
      { name: 'host', internalType: 'contract ISuperfluid', type: 'address' },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'receiver', internalType: 'address', type: 'address' },
      { name: 'flowrate', internalType: 'int96', type: 'int96' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'createFlow',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'receiver', internalType: 'address', type: 'address' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'deleteFlow',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'account', internalType: 'address', type: 'address' },
    ],
    name: 'getAccountFlowInfo',
    outputs: [
      { name: 'lastUpdated', internalType: 'uint256', type: 'uint256' },
      { name: 'flowrate', internalType: 'int96', type: 'int96' },
      { name: 'deposit', internalType: 'uint256', type: 'uint256' },
      { name: 'owedDeposit', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'account', internalType: 'address', type: 'address' },
    ],
    name: 'getAccountFlowrate',
    outputs: [{ name: 'flowrate', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'flowrate', internalType: 'int96', type: 'int96' },
    ],
    name: 'getBufferAmountByFlowrate',
    outputs: [
      { name: 'bufferAmount', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'receiver', internalType: 'address', type: 'address' },
    ],
    name: 'getFlowInfo',
    outputs: [
      { name: 'lastUpdated', internalType: 'uint256', type: 'uint256' },
      { name: 'flowrate', internalType: 'int96', type: 'int96' },
      { name: 'deposit', internalType: 'uint256', type: 'uint256' },
      { name: 'owedDeposit', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'flowOperator', internalType: 'address', type: 'address' },
    ],
    name: 'getFlowOperatorPermissions',
    outputs: [
      { name: 'permissions', internalType: 'uint8', type: 'uint8' },
      { name: 'flowrateAllowance', internalType: 'int96', type: 'int96' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'receiver', internalType: 'address', type: 'address' },
    ],
    name: 'getFlowrate',
    outputs: [{ name: 'flowrate', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'flowOperator', internalType: 'address', type: 'address' },
    ],
    name: 'grantPermissions',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'flowOperator', internalType: 'address', type: 'address' },
    ],
    name: 'revokePermissions',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'receiver', internalType: 'address', type: 'address' },
      { name: 'flowrate', internalType: 'int96', type: 'int96' },
    ],
    name: 'setFlowrate',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'receiver', internalType: 'address', type: 'address' },
      { name: 'flowrate', internalType: 'int96', type: 'int96' },
    ],
    name: 'setFlowrateFrom',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'receiver', internalType: 'address', type: 'address' },
      { name: 'flowrate', internalType: 'int96', type: 'int96' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'updateFlow',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'flowOperator', internalType: 'address', type: 'address' },
      { name: 'permissions', internalType: 'uint8', type: 'uint8' },
      { name: 'flowrateAllowance', internalType: 'int96', type: 'int96' },
    ],
    name: 'updateFlowOperatorPermissions',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  { type: 'error', inputs: [], name: 'CFA_FWD_INVALID_FLOW_RATE' },
] as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xcfA132E353cB4E398080B9700609bb008eceB125)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0xcfA132E353cB4E398080B9700609bb008eceB125)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0xcfA132E353cB4E398080B9700609bb008eceB125)
 */
export const cfAv1ForwarderAddress = {
  10: '0xcfA132E353cB4E398080B9700609bb008eceB125',
  8453: '0xcfA132E353cB4E398080B9700609bb008eceB125',
  42220: '0xcfA132E353cB4E398080B9700609bb008eceB125',
} as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xcfA132E353cB4E398080B9700609bb008eceB125)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0xcfA132E353cB4E398080B9700609bb008eceB125)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0xcfA132E353cB4E398080B9700609bb008eceB125)
 */
export const cfAv1ForwarderConfig = {
  address: cfAv1ForwarderAddress,
  abi: cfAv1ForwarderABI,
} as const

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DistributionFeeManager
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xf28ba7108b96ff7d9bc43a302a504babda68be4b)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0xfdad7082c6d2e07dd232be252bfd65841ea1c83c)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x750c3e12f26a998244ca9c95d300cc20f4dfb485)
 */
export const distributionFeeManagerABI = [
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'torexes', internalType: 'contract ITorex[]', type: 'address[]' },
      { name: 'distributor', internalType: 'address', type: 'address' },
    ],
    name: 'batchSync',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [],
    name: 'castrate',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getCodeAddress',
    outputs: [
      { name: 'codeAddress', internalType: 'address', type: 'address' },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'owner', internalType: 'address', type: 'address' }],
    name: 'initialize',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'owner',
    outputs: [{ name: '', internalType: 'address', type: 'address' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: '', internalType: 'contract ITorex', type: 'address' }],
    name: 'pools',
    outputs: [
      { name: '', internalType: 'contract ISuperfluidPool', type: 'address' },
    ],
  },
  {
    stateMutability: 'pure',
    type: 'function',
    inputs: [],
    name: 'proxiableUUID',
    outputs: [{ name: '', internalType: 'bytes32', type: 'bytes32' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [],
    name: 'renounceOwnership',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
      { name: 'distributor', internalType: 'address', type: 'address' },
    ],
    name: 'sync',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'newOwner', internalType: 'address', type: 'address' }],
    name: 'transferOwnership',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'newAddress', internalType: 'address', type: 'address' }],
    name: 'updateCode',
    outputs: [],
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'uuid',
        internalType: 'bytes32',
        type: 'bytes32',
        indexed: false,
      },
      {
        name: 'codeAddress',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
    ],
    name: 'CodeUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'torex',
        internalType: 'contract ITorex',
        type: 'address',
        indexed: true,
      },
      {
        name: 'distributor',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'inToken',
        internalType: 'contract ISuperToken',
        type: 'address',
        indexed: true,
      },
      {
        name: 'distributedAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'units',
        internalType: 'uint128',
        type: 'uint128',
        indexed: false,
      },
    ],
    name: 'DistributorStatsSynced',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      { name: 'version', internalType: 'uint8', type: 'uint8', indexed: false },
    ],
    name: 'Initialized',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'previousOwner',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'newOwner',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'OwnershipTransferred',
  },
] as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xf28ba7108b96ff7d9bc43a302a504babda68be4b)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0xfdad7082c6d2e07dd232be252bfd65841ea1c83c)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x750c3e12f26a998244ca9c95d300cc20f4dfb485)
 */
export const distributionFeeManagerAddress = {
  10: '0xf28ba7108B96ff7d9BC43a302A504BaBDA68Be4b',
  8453: '0xFdAd7082C6d2e07dD232be252bfD65841Ea1C83C',
  42220: '0x750c3E12F26A998244ca9c95d300Cc20F4Dfb485',
} as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xf28ba7108b96ff7d9bc43a302a504babda68be4b)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0xfdad7082c6d2e07dd232be252bfd65841ea1c83c)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x750c3e12f26a998244ca9c95d300cc20f4dfb485)
 */
export const distributionFeeManagerConfig = {
  address: distributionFeeManagerAddress,
  abi: distributionFeeManagerABI,
} as const

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// EmissionTreasury
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xfdad7082c6d2e07dd232be252bfd65841ea1c83c)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x14a201a50b3ffc7ca9851dd137aa47ff33924025)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x89795bb9aed5fa4c5c91815bb28db790ea7933c9)
 */
export const emissionTreasuryABI = [
  {
    stateMutability: 'nonpayable',
    type: 'constructor',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'balanceLeft',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'boringToken',
    outputs: [
      { name: '', internalType: 'contract ISuperToken', type: 'address' },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [],
    name: 'castrate',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getCodeAddress',
    outputs: [
      { name: 'codeAddress', internalType: 'address', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'emissionTarget', internalType: 'address', type: 'address' },
    ],
    name: 'getEmissionBoostFactor',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'emissionTarget', internalType: 'address', type: 'address' },
    ],
    name: 'getEmissionPool',
    outputs: [
      { name: '', internalType: 'contract ISuperfluidPool', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'emissionTarget', internalType: 'address', type: 'address' },
    ],
    name: 'getEmissionRate',
    outputs: [{ name: 'emissionRate', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'emissionTarget', internalType: 'address', type: 'address' },
      { name: 'member', internalType: 'address', type: 'address' },
    ],
    name: 'getMemberEmissionRate',
    outputs: [{ name: 'emissionRate', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'emissionTarget', internalType: 'address', type: 'address' },
      { name: 'member', internalType: 'address', type: 'address' },
    ],
    name: 'getMemberEmissionUnits',
    outputs: [{ name: 'units', internalType: 'uint128', type: 'uint128' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'owner', internalType: 'address', type: 'address' }],
    name: 'initialize',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'owner',
    outputs: [{ name: '', internalType: 'address', type: 'address' }],
  },
  {
    stateMutability: 'pure',
    type: 'function',
    inputs: [],
    name: 'proxiableUUID',
    outputs: [{ name: '', internalType: 'bytes32', type: 'bytes32' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [],
    name: 'renounceOwnership',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'newOwner', internalType: 'address', type: 'address' }],
    name: 'transferOwnership',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'newAddress', internalType: 'address', type: 'address' }],
    name: 'updateCode',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'emissionTarget', internalType: 'address', type: 'address' },
      { name: 'factorPM', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'updateEmissionBoostFactor',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'emissionTarget', internalType: 'address', type: 'address' },
      { name: 'emissionRate', internalType: 'int96', type: 'int96' },
    ],
    name: 'updateEmissionRate',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'emissionTarget', internalType: 'address', type: 'address' },
      { name: 'member', internalType: 'address', type: 'address' },
      { name: 'units', internalType: 'uint128', type: 'uint128' },
    ],
    name: 'updateMemberEmissionUnits',
    outputs: [],
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'uuid',
        internalType: 'bytes32',
        type: 'bytes32',
        indexed: false,
      },
      {
        name: 'codeAddress',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
    ],
    name: 'CodeUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'emissionTarget',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'factorPM',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'EmissionBoostFactorUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'emissionTarget',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'emissionRate',
        internalType: 'int96',
        type: 'int96',
        indexed: false,
      },
    ],
    name: 'EmissionRateUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'emissionTarget',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'member',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'units',
        internalType: 'uint128',
        type: 'uint128',
        indexed: false,
      },
    ],
    name: 'EmissionUnitsUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      { name: 'version', internalType: 'uint8', type: 'uint8', indexed: false },
    ],
    name: 'Initialized',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'previousOwner',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'newOwner',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'OwnershipTransferred',
  },
] as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xfdad7082c6d2e07dd232be252bfd65841ea1c83c)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x14a201a50b3ffc7ca9851dd137aa47ff33924025)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x89795bb9aed5fa4c5c91815bb28db790ea7933c9)
 */
export const emissionTreasuryAddress = {
  10: '0xFdAd7082C6d2e07dD232be252bfD65841Ea1C83C',
  8453: '0x14a201A50b3FFC7ca9851DD137Aa47fF33924025',
  42220: '0x89795Bb9AEd5Fa4c5c91815Bb28DB790eA7933C9',
} as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xfdad7082c6d2e07dd232be252bfd65841ea1c83c)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x14a201a50b3ffc7ca9851dd137aa47ff33924025)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x89795bb9aed5fa4c5c91815bb28db790ea7933c9)
 */
export const emissionTreasuryConfig = {
  address: emissionTreasuryAddress,
  abi: emissionTreasuryABI,
} as const

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// GDAv1Forwarder
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0x6DA13Bde224A05a288748d857b9e7DDEffd1dE08)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x6DA13Bde224A05a288748d857b9e7DDEffd1dE08)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x6DA13Bde224A05a288748d857b9e7DDEffd1dE08)
 */
export const gdAv1ForwarderABI = [
  {
    stateMutability: 'nonpayable',
    type: 'constructor',
    inputs: [
      { name: 'host', internalType: 'contract ISuperfluid', type: 'address' },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
      { name: 'memberAddress', internalType: 'address', type: 'address' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'claimAll',
    outputs: [{ name: 'success', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'connectPool',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'admin', internalType: 'address', type: 'address' },
      {
        name: 'config',
        internalType: 'struct PoolConfig',
        type: 'tuple',
        components: [
          {
            name: 'transferabilityForUnitsOwner',
            internalType: 'bool',
            type: 'bool',
          },
          {
            name: 'distributionFromAnyAddress',
            internalType: 'bool',
            type: 'bool',
          },
        ],
      },
    ],
    name: 'createPool',
    outputs: [
      { name: 'success', internalType: 'bool', type: 'bool' },
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'disconnectPool',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'from', internalType: 'address', type: 'address' },
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
      { name: 'requestedAmount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'distribute',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'from', internalType: 'address', type: 'address' },
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
      { name: 'requestedFlowRate', internalType: 'int96', type: 'int96' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'distributeFlow',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'from', internalType: 'address', type: 'address' },
      { name: 'to', internalType: 'contract ISuperfluidPool', type: 'address' },
      { name: 'requestedAmount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'estimateDistributionActualAmount',
    outputs: [
      { name: 'actualAmount', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'from', internalType: 'address', type: 'address' },
      { name: 'to', internalType: 'contract ISuperfluidPool', type: 'address' },
      { name: 'requestedFlowRate', internalType: 'int96', type: 'int96' },
    ],
    name: 'estimateFlowDistributionActualFlowRate',
    outputs: [
      { name: 'actualFlowRate', internalType: 'int96', type: 'int96' },
      {
        name: 'totalDistributionFlowRate',
        internalType: 'int96',
        type: 'int96',
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'from', internalType: 'address', type: 'address' },
      { name: 'to', internalType: 'contract ISuperfluidPool', type: 'address' },
    ],
    name: 'getFlowDistributionFlowRate',
    outputs: [{ name: '', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'account', internalType: 'address', type: 'address' },
    ],
    name: 'getNetFlow',
    outputs: [{ name: '', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
    ],
    name: 'getPoolAdjustmentFlowInfo',
    outputs: [
      { name: '', internalType: 'address', type: 'address' },
      { name: '', internalType: 'bytes32', type: 'bytes32' },
      { name: '', internalType: 'int96', type: 'int96' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'pool', internalType: 'address', type: 'address' }],
    name: 'getPoolAdjustmentFlowRate',
    outputs: [{ name: '', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
      { name: 'member', internalType: 'address', type: 'address' },
    ],
    name: 'isMemberConnected',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'account', internalType: 'address', type: 'address' },
    ],
    name: 'isPool',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
      { name: 'memberAddress', internalType: 'address', type: 'address' },
      { name: 'newUnits', internalType: 'uint128', type: 'uint128' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'updateMemberUnits',
    outputs: [{ name: 'success', internalType: 'bool', type: 'bool' }],
  },
] as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0x6DA13Bde224A05a288748d857b9e7DDEffd1dE08)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x6DA13Bde224A05a288748d857b9e7DDEffd1dE08)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x6DA13Bde224A05a288748d857b9e7DDEffd1dE08)
 */
export const gdAv1ForwarderAddress = {
  10: '0x6DA13Bde224A05a288748d857b9e7DDEffd1dE08',
  8453: '0x6DA13Bde224A05a288748d857b9e7DDEffd1dE08',
  42220: '0x6DA13Bde224A05a288748d857b9e7DDEffd1dE08',
} as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0x6DA13Bde224A05a288748d857b9e7DDEffd1dE08)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x6DA13Bde224A05a288748d857b9e7DDEffd1dE08)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x6DA13Bde224A05a288748d857b9e7DDEffd1dE08)
 */
export const gdAv1ForwarderConfig = {
  address: gdAv1ForwarderAddress,
  abi: gdAv1ForwarderABI,
} as const

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// IConstantFlowAgreementV1
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0x204C6f131bb7F258b2Ea1593f5309911d8E458eD)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x19ba78B9cDB05A877718841c574325fdB53601bb)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x9d369e78e1a682cE0F8d9aD849BeA4FE1c3bD3Ad)
 */
export const iConstantFlowAgreementV1ABI = [
  {
    stateMutability: 'pure',
    type: 'function',
    inputs: [],
    name: 'agreementType',
    outputs: [{ name: '', internalType: 'bytes32', type: 'bytes32' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'flowOperator', internalType: 'address', type: 'address' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'authorizeFlowOperatorWithFullControl',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'receiver', internalType: 'address', type: 'address' },
      { name: 'flowRate', internalType: 'int96', type: 'int96' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'createFlow',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'receiver', internalType: 'address', type: 'address' },
      { name: 'flowRate', internalType: 'int96', type: 'int96' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'createFlowByOperator',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'flowOperator', internalType: 'address', type: 'address' },
      {
        name: 'subtractedFlowRateAllowance',
        internalType: 'int96',
        type: 'int96',
      },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'decreaseFlowRateAllowance',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'flowOperator', internalType: 'address', type: 'address' },
      { name: 'permissionsToRemove', internalType: 'uint8', type: 'uint8' },
      {
        name: 'subtractedFlowRateAllowance',
        internalType: 'int96',
        type: 'int96',
      },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'decreaseFlowRateAllowanceWithPermissions',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'receiver', internalType: 'address', type: 'address' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'deleteFlow',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'receiver', internalType: 'address', type: 'address' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'deleteFlowByOperator',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'account', internalType: 'address', type: 'address' },
    ],
    name: 'getAccountFlowInfo',
    outputs: [
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
      { name: 'flowRate', internalType: 'int96', type: 'int96' },
      { name: 'deposit', internalType: 'uint256', type: 'uint256' },
      { name: 'owedDeposit', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'flowRate', internalType: 'int96', type: 'int96' },
    ],
    name: 'getDepositRequiredForFlowRate',
    outputs: [{ name: 'deposit', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'receiver', internalType: 'address', type: 'address' },
    ],
    name: 'getFlow',
    outputs: [
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
      { name: 'flowRate', internalType: 'int96', type: 'int96' },
      { name: 'deposit', internalType: 'uint256', type: 'uint256' },
      { name: 'owedDeposit', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'agreementId', internalType: 'bytes32', type: 'bytes32' },
    ],
    name: 'getFlowByID',
    outputs: [
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
      { name: 'flowRate', internalType: 'int96', type: 'int96' },
      { name: 'deposit', internalType: 'uint256', type: 'uint256' },
      { name: 'owedDeposit', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'flowOperator', internalType: 'address', type: 'address' },
    ],
    name: 'getFlowOperatorData',
    outputs: [
      { name: 'flowOperatorId', internalType: 'bytes32', type: 'bytes32' },
      { name: 'permissions', internalType: 'uint8', type: 'uint8' },
      { name: 'flowRateAllowance', internalType: 'int96', type: 'int96' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'flowOperatorId', internalType: 'bytes32', type: 'bytes32' },
    ],
    name: 'getFlowOperatorDataByID',
    outputs: [
      { name: 'permissions', internalType: 'uint8', type: 'uint8' },
      { name: 'flowRateAllowance', internalType: 'int96', type: 'int96' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'deposit', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'getMaximumFlowRateFromDeposit',
    outputs: [{ name: 'flowRate', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'account', internalType: 'address', type: 'address' },
    ],
    name: 'getNetFlow',
    outputs: [{ name: 'flowRate', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'flowOperator', internalType: 'address', type: 'address' },
      { name: 'addedFlowRateAllowance', internalType: 'int96', type: 'int96' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'increaseFlowRateAllowance',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'flowOperator', internalType: 'address', type: 'address' },
      { name: 'permissionsToAdd', internalType: 'uint8', type: 'uint8' },
      { name: 'addedFlowRateAllowance', internalType: 'int96', type: 'int96' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'increaseFlowRateAllowanceWithPermissions',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'isPatricianPeriod',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'account', internalType: 'address', type: 'address' },
    ],
    name: 'isPatricianPeriodNow',
    outputs: [
      {
        name: 'isCurrentlyPatricianPeriod',
        internalType: 'bool',
        type: 'bool',
      },
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'time', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'realtimeBalanceOf',
    outputs: [
      { name: 'dynamicBalance', internalType: 'int256', type: 'int256' },
      { name: 'deposit', internalType: 'uint256', type: 'uint256' },
      { name: 'owedDeposit', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'flowOperator', internalType: 'address', type: 'address' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'revokeFlowOperatorWithFullControl',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'receiver', internalType: 'address', type: 'address' },
      { name: 'flowRate', internalType: 'int96', type: 'int96' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'updateFlow',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'receiver', internalType: 'address', type: 'address' },
      { name: 'flowRate', internalType: 'int96', type: 'int96' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'updateFlowByOperator',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'flowOperator', internalType: 'address', type: 'address' },
      { name: 'permissions', internalType: 'uint8', type: 'uint8' },
      { name: 'flowRateAllowance', internalType: 'int96', type: 'int96' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'updateFlowOperatorPermissions',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
        indexed: true,
      },
      {
        name: 'sender',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'flowOperator',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'permissions',
        internalType: 'uint8',
        type: 'uint8',
        indexed: false,
      },
      {
        name: 'flowRateAllowance',
        internalType: 'int96',
        type: 'int96',
        indexed: false,
      },
    ],
    name: 'FlowOperatorUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
        indexed: true,
      },
      {
        name: 'sender',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'receiver',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'flowRate',
        internalType: 'int96',
        type: 'int96',
        indexed: false,
      },
      {
        name: 'totalSenderFlowRate',
        internalType: 'int256',
        type: 'int256',
        indexed: false,
      },
      {
        name: 'totalReceiverFlowRate',
        internalType: 'int256',
        type: 'int256',
        indexed: false,
      },
      {
        name: 'userData',
        internalType: 'bytes',
        type: 'bytes',
        indexed: false,
      },
    ],
    name: 'FlowUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'flowOperator',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'deposit',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'FlowUpdatedExtension',
  },
  { type: 'error', inputs: [], name: 'CFA_ACL_FLOW_RATE_ALLOWANCE_EXCEEDED' },
  { type: 'error', inputs: [], name: 'CFA_ACL_NO_NEGATIVE_ALLOWANCE' },
  { type: 'error', inputs: [], name: 'CFA_ACL_NO_SENDER_CREATE' },
  { type: 'error', inputs: [], name: 'CFA_ACL_NO_SENDER_FLOW_OPERATOR' },
  { type: 'error', inputs: [], name: 'CFA_ACL_NO_SENDER_UPDATE' },
  { type: 'error', inputs: [], name: 'CFA_ACL_OPERATOR_NO_CREATE_PERMISSIONS' },
  { type: 'error', inputs: [], name: 'CFA_ACL_OPERATOR_NO_DELETE_PERMISSIONS' },
  { type: 'error', inputs: [], name: 'CFA_ACL_OPERATOR_NO_UPDATE_PERMISSIONS' },
  { type: 'error', inputs: [], name: 'CFA_ACL_UNCLEAN_PERMISSIONS' },
  { type: 'error', inputs: [], name: 'CFA_DEPOSIT_TOO_BIG' },
  { type: 'error', inputs: [], name: 'CFA_FLOW_ALREADY_EXISTS' },
  { type: 'error', inputs: [], name: 'CFA_FLOW_DOES_NOT_EXIST' },
  { type: 'error', inputs: [], name: 'CFA_FLOW_RATE_TOO_BIG' },
  { type: 'error', inputs: [], name: 'CFA_HOOK_OUT_OF_GAS' },
  { type: 'error', inputs: [], name: 'CFA_INSUFFICIENT_BALANCE' },
  { type: 'error', inputs: [], name: 'CFA_INVALID_FLOW_RATE' },
  { type: 'error', inputs: [], name: 'CFA_NON_CRITICAL_SENDER' },
  { type: 'error', inputs: [], name: 'CFA_NO_SELF_FLOW' },
  { type: 'error', inputs: [], name: 'CFA_ZERO_ADDRESS_RECEIVER' },
  { type: 'error', inputs: [], name: 'CFA_ZERO_ADDRESS_SENDER' },
] as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0x204C6f131bb7F258b2Ea1593f5309911d8E458eD)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x19ba78B9cDB05A877718841c574325fdB53601bb)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x9d369e78e1a682cE0F8d9aD849BeA4FE1c3bD3Ad)
 */
export const iConstantFlowAgreementV1Address = {
  10: '0x204C6f131bb7F258b2Ea1593f5309911d8E458eD',
  8453: '0x19ba78B9cDB05A877718841c574325fdB53601bb',
  42220: '0x9d369e78e1a682cE0F8d9aD849BeA4FE1c3bD3Ad',
} as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0x204C6f131bb7F258b2Ea1593f5309911d8E458eD)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x19ba78B9cDB05A877718841c574325fdB53601bb)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x9d369e78e1a682cE0F8d9aD849BeA4FE1c3bD3Ad)
 */
export const iConstantFlowAgreementV1Config = {
  address: iConstantFlowAgreementV1Address,
  abi: iConstantFlowAgreementV1ABI,
} as const

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// IERC20
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

export const ierc20ABI = [
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'owner', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
    ],
    name: 'allowance',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'approve',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'account', internalType: 'address', type: 'address' }],
    name: 'balanceOf',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'totalSupply',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'to', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'transfer',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'from', internalType: 'address', type: 'address' },
      { name: 'to', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'transferFrom',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'owner',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'spender',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'value',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Approval',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      { name: 'from', internalType: 'address', type: 'address', indexed: true },
      { name: 'to', internalType: 'address', type: 'address', indexed: true },
      {
        name: 'value',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Transfer',
  },
] as const

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// IGeneralDistributionAgreementV1
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0x68Ae17fa7a31b86F306c383277552fd4813b0d35)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0xfE6c87BE05feDB2059d2EC41bA0A09826C9FD7aa)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x308b7405272d11494716e30C6E972DbF6fb89555)
 */
export const iGeneralDistributionAgreementV1ABI = [
  {
    stateMutability: 'pure',
    type: 'function',
    inputs: [],
    name: 'agreementType',
    outputs: [{ name: '', internalType: 'bytes32', type: 'bytes32' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
      { name: 'memberAddress', internalType: 'address', type: 'address' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'claimAll',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'connectPool',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'admin', internalType: 'address', type: 'address' },
      {
        name: 'poolConfig',
        internalType: 'struct PoolConfig',
        type: 'tuple',
        components: [
          {
            name: 'transferabilityForUnitsOwner',
            internalType: 'bool',
            type: 'bool',
          },
          {
            name: 'distributionFromAnyAddress',
            internalType: 'bool',
            type: 'bool',
          },
        ],
      },
    ],
    name: 'createPool',
    outputs: [
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'disconnectPool',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'from', internalType: 'address', type: 'address' },
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
      { name: 'requestedAmount', internalType: 'uint256', type: 'uint256' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'distribute',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'from', internalType: 'address', type: 'address' },
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
      { name: 'requestedFlowRate', internalType: 'int96', type: 'int96' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'distributeFlow',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'from', internalType: 'address', type: 'address' },
      { name: 'to', internalType: 'contract ISuperfluidPool', type: 'address' },
      { name: 'requestedAmount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'estimateDistributionActualAmount',
    outputs: [
      { name: 'actualAmount', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'from', internalType: 'address', type: 'address' },
      { name: 'to', internalType: 'contract ISuperfluidPool', type: 'address' },
      { name: 'requestedFlowRate', internalType: 'int96', type: 'int96' },
    ],
    name: 'estimateFlowDistributionActualFlowRate',
    outputs: [
      { name: 'actualFlowRate', internalType: 'int96', type: 'int96' },
      {
        name: 'totalDistributionFlowRate',
        internalType: 'int96',
        type: 'int96',
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'account', internalType: 'address', type: 'address' },
    ],
    name: 'getAccountFlowInfo',
    outputs: [
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
      { name: 'flowRate', internalType: 'int96', type: 'int96' },
      { name: 'deposit', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'from', internalType: 'address', type: 'address' },
      { name: 'to', internalType: 'contract ISuperfluidPool', type: 'address' },
    ],
    name: 'getFlow',
    outputs: [
      { name: 'lastUpdated', internalType: 'uint256', type: 'uint256' },
      { name: 'flowRate', internalType: 'int96', type: 'int96' },
      { name: 'deposit', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'from', internalType: 'address', type: 'address' },
      { name: 'to', internalType: 'contract ISuperfluidPool', type: 'address' },
    ],
    name: 'getFlowRate',
    outputs: [{ name: '', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'account', internalType: 'address', type: 'address' },
    ],
    name: 'getNetFlow',
    outputs: [{ name: '', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
    ],
    name: 'getPoolAdjustmentFlowInfo',
    outputs: [
      { name: '', internalType: 'address', type: 'address' },
      { name: '', internalType: 'bytes32', type: 'bytes32' },
      { name: '', internalType: 'int96', type: 'int96' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'pool', internalType: 'address', type: 'address' }],
    name: 'getPoolAdjustmentFlowRate',
    outputs: [{ name: '', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
      { name: 'memberAddr', internalType: 'address', type: 'address' },
    ],
    name: 'isMemberConnected',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'isPatricianPeriod',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'account', internalType: 'address', type: 'address' },
    ],
    name: 'isPatricianPeriodNow',
    outputs: [
      {
        name: 'isCurrentlyPatricianPeriod',
        internalType: 'bool',
        type: 'bool',
      },
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'account', internalType: 'address', type: 'address' },
    ],
    name: 'isPool',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'time', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'realtimeBalanceOf',
    outputs: [
      { name: 'dynamicBalance', internalType: 'int256', type: 'int256' },
      { name: 'deposit', internalType: 'uint256', type: 'uint256' },
      { name: 'owedDeposit', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
      },
      { name: 'memberAddress', internalType: 'address', type: 'address' },
      { name: 'newUnits', internalType: 'uint128', type: 'uint128' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'updateMemberUnits',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
        indexed: true,
      },
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
        indexed: true,
      },
      { name: 'from', internalType: 'address', type: 'address', indexed: true },
      {
        name: 'bufferDelta',
        internalType: 'int256',
        type: 'int256',
        indexed: false,
      },
      {
        name: 'newBufferAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'totalBufferAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'BufferAdjusted',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
        indexed: true,
      },
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
        indexed: true,
      },
      {
        name: 'distributor',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'operator',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'oldFlowRate',
        internalType: 'int96',
        type: 'int96',
        indexed: false,
      },
      {
        name: 'newDistributorToPoolFlowRate',
        internalType: 'int96',
        type: 'int96',
        indexed: false,
      },
      {
        name: 'newTotalDistributionFlowRate',
        internalType: 'int96',
        type: 'int96',
        indexed: false,
      },
      {
        name: 'adjustmentFlowRecipient',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'adjustmentFlowRate',
        internalType: 'int96',
        type: 'int96',
        indexed: false,
      },
      {
        name: 'userData',
        internalType: 'bytes',
        type: 'bytes',
        indexed: false,
      },
    ],
    name: 'FlowDistributionUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
        indexed: true,
      },
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
        indexed: true,
      },
      {
        name: 'distributor',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'operator',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'requestedAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'actualAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'userData',
        internalType: 'bytes',
        type: 'bytes',
        indexed: false,
      },
    ],
    name: 'InstantDistributionUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
        indexed: true,
      },
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
        indexed: true,
      },
      {
        name: 'account',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'connected', internalType: 'bool', type: 'bool', indexed: false },
      {
        name: 'userData',
        internalType: 'bytes',
        type: 'bytes',
        indexed: false,
      },
    ],
    name: 'PoolConnectionUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
        indexed: true,
      },
      {
        name: 'admin',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'pool',
        internalType: 'contract ISuperfluidPool',
        type: 'address',
        indexed: false,
      },
    ],
    name: 'PoolCreated',
  },
  { type: 'error', inputs: [], name: 'GDA_ADMIN_CANNOT_BE_POOL' },
  { type: 'error', inputs: [], name: 'GDA_DISTRIBUTE_FOR_OTHERS_NOT_ALLOWED' },
  {
    type: 'error',
    inputs: [],
    name: 'GDA_DISTRIBUTE_FROM_ANY_ADDRESS_NOT_ALLOWED',
  },
  { type: 'error', inputs: [], name: 'GDA_FLOW_DOES_NOT_EXIST' },
  { type: 'error', inputs: [], name: 'GDA_INSUFFICIENT_BALANCE' },
  { type: 'error', inputs: [], name: 'GDA_NON_CRITICAL_SENDER' },
  { type: 'error', inputs: [], name: 'GDA_NOT_POOL_ADMIN' },
  { type: 'error', inputs: [], name: 'GDA_NO_NEGATIVE_FLOW_RATE' },
  { type: 'error', inputs: [], name: 'GDA_NO_ZERO_ADDRESS_ADMIN' },
  { type: 'error', inputs: [], name: 'GDA_ONLY_SUPER_TOKEN_POOL' },
] as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0x68Ae17fa7a31b86F306c383277552fd4813b0d35)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0xfE6c87BE05feDB2059d2EC41bA0A09826C9FD7aa)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x308b7405272d11494716e30C6E972DbF6fb89555)
 */
export const iGeneralDistributionAgreementV1Address = {
  10: '0x68Ae17fa7a31b86F306c383277552fd4813b0d35',
  8453: '0xfE6c87BE05feDB2059d2EC41bA0A09826C9FD7aa',
  42220: '0x308b7405272d11494716e30C6E972DbF6fb89555',
} as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0x68Ae17fa7a31b86F306c383277552fd4813b0d35)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0xfE6c87BE05feDB2059d2EC41bA0A09826C9FD7aa)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x308b7405272d11494716e30C6E972DbF6fb89555)
 */
export const iGeneralDistributionAgreementV1Config = {
  address: iGeneralDistributionAgreementV1Address,
  abi: iGeneralDistributionAgreementV1ABI,
} as const

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ISETH
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

export const isethABI = [
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'POOL_ADMIN_NFT',
    outputs: [
      { name: '', internalType: 'contract IPoolAdminNFT', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'POOL_MEMBER_NFT',
    outputs: [
      { name: '', internalType: 'contract IPoolMemberNFT', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'owner', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
    ],
    name: 'allowance',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'approve',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'operator', internalType: 'address', type: 'address' }],
    name: 'authorizeOperator',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'account', internalType: 'address', type: 'address' }],
    name: 'balanceOf',
    outputs: [{ name: 'balance', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'burn',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'newAdmin', internalType: 'address', type: 'address' }],
    name: 'changeAdmin',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'id', internalType: 'bytes32', type: 'bytes32' },
      { name: 'data', internalType: 'bytes32[]', type: 'bytes32[]' },
    ],
    name: 'createAgreement',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'decimals',
    outputs: [{ name: '', internalType: 'uint8', type: 'uint8' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'subtractedValue', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'decreaseAllowance',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'defaultOperators',
    outputs: [{ name: '', internalType: 'address[]', type: 'address[]' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'amount', internalType: 'uint256', type: 'uint256' }],
    name: 'downgrade',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'to', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'downgradeTo',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'wad', internalType: 'uint256', type: 'uint256' }],
    name: 'downgradeToETH',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'account', internalType: 'address', type: 'address' }],
    name: 'getAccountActiveAgreements',
    outputs: [
      {
        name: 'activeAgreements',
        internalType: 'contract ISuperAgreement[]',
        type: 'address[]',
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getAdmin',
    outputs: [{ name: 'admin', internalType: 'address', type: 'address' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'agreementClass', internalType: 'address', type: 'address' },
      { name: 'id', internalType: 'bytes32', type: 'bytes32' },
      { name: 'dataLength', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'getAgreementData',
    outputs: [{ name: 'data', internalType: 'bytes32[]', type: 'bytes32[]' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'agreementClass', internalType: 'address', type: 'address' },
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'slotId', internalType: 'uint256', type: 'uint256' },
      { name: 'dataLength', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'getAgreementStateSlot',
    outputs: [
      { name: 'slotData', internalType: 'bytes32[]', type: 'bytes32[]' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getHost',
    outputs: [{ name: 'host', internalType: 'address', type: 'address' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getUnderlyingDecimals',
    outputs: [
      { name: 'underlyingDecimals', internalType: 'uint8', type: 'uint8' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getUnderlyingToken',
    outputs: [{ name: 'tokenAddr', internalType: 'address', type: 'address' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'granularity',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'addedValue', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'increaseAllowance',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'underlyingToken',
        internalType: 'contract IERC20',
        type: 'address',
      },
      { name: 'underlyingDecimals', internalType: 'uint8', type: 'uint8' },
      { name: 'n', internalType: 'string', type: 'string' },
      { name: 's', internalType: 'string', type: 'string' },
    ],
    name: 'initialize',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'underlyingToken',
        internalType: 'contract IERC20',
        type: 'address',
      },
      { name: 'underlyingDecimals', internalType: 'uint8', type: 'uint8' },
      { name: 'n', internalType: 'string', type: 'string' },
      { name: 's', internalType: 'string', type: 'string' },
      { name: 'admin', internalType: 'address', type: 'address' },
    ],
    name: 'initializeWithAdmin',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'isAccountCritical',
    outputs: [{ name: 'isCritical', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'account', internalType: 'address', type: 'address' }],
    name: 'isAccountCriticalNow',
    outputs: [{ name: 'isCritical', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'isAccountSolvent',
    outputs: [{ name: 'isSolvent', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'account', internalType: 'address', type: 'address' }],
    name: 'isAccountSolventNow',
    outputs: [{ name: 'isSolvent', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'operator', internalType: 'address', type: 'address' },
      { name: 'tokenHolder', internalType: 'address', type: 'address' },
    ],
    name: 'isOperatorFor',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'id', internalType: 'bytes32', type: 'bytes32' },
      { name: 'liquidationTypeData', internalType: 'bytes', type: 'bytes' },
      { name: 'liquidatorAccount', internalType: 'address', type: 'address' },
      { name: 'useDefaultRewardAccount', internalType: 'bool', type: 'bool' },
      { name: 'targetAccount', internalType: 'address', type: 'address' },
      { name: 'rewardAmount', internalType: 'uint256', type: 'uint256' },
      {
        name: 'targetAccountBalanceDelta',
        internalType: 'int256',
        type: 'int256',
      },
    ],
    name: 'makeLiquidationPayoutsV2',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'name',
    outputs: [{ name: '', internalType: 'string', type: 'string' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationApprove',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'subtractedValue', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationDecreaseAllowance',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationDowngrade',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'to', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationDowngradeTo',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'addedValue', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationIncreaseAllowance',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'recipient', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'operationSend',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'recipient', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationTransferFrom',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationUpgrade',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'to', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationUpgradeTo',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
      { name: 'operatorData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'operatorBurn',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'recipient', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
      { name: 'operatorData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'operatorSend',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'realtimeBalanceOf',
    outputs: [
      { name: 'availableBalance', internalType: 'int256', type: 'int256' },
      { name: 'deposit', internalType: 'uint256', type: 'uint256' },
      { name: 'owedDeposit', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'account', internalType: 'address', type: 'address' }],
    name: 'realtimeBalanceOfNow',
    outputs: [
      { name: 'availableBalance', internalType: 'int256', type: 'int256' },
      { name: 'deposit', internalType: 'uint256', type: 'uint256' },
      { name: 'owedDeposit', internalType: 'uint256', type: 'uint256' },
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'operator', internalType: 'address', type: 'address' }],
    name: 'revokeOperator',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'selfApproveFor',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'selfBurn',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'selfMint',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'recipient', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'selfTransferFrom',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'recipient', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'send',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'delta', internalType: 'int256', type: 'int256' },
    ],
    name: 'settleBalance',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'symbol',
    outputs: [{ name: '', internalType: 'string', type: 'string' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'id', internalType: 'bytes32', type: 'bytes32' },
      { name: 'dataLength', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'terminateAgreement',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'amount', internalType: 'uint256', type: 'uint256' }],
    name: 'toUnderlyingAmount',
    outputs: [
      { name: 'underlyingAmount', internalType: 'uint256', type: 'uint256' },
      { name: 'adjustedAmount', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'totalSupply',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'recipient', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'transfer',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'recipient', internalType: 'address', type: 'address' }],
    name: 'transferAll',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'recipient', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'transferFrom',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'id', internalType: 'bytes32', type: 'bytes32' },
      { name: 'data', internalType: 'bytes32[]', type: 'bytes32[]' },
    ],
    name: 'updateAgreementData',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'slotId', internalType: 'uint256', type: 'uint256' },
      { name: 'slotData', internalType: 'bytes32[]', type: 'bytes32[]' },
    ],
    name: 'updateAgreementStateSlot',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'amount', internalType: 'uint256', type: 'uint256' }],
    name: 'upgrade',
    outputs: [],
  },
  {
    stateMutability: 'payable',
    type: 'function',
    inputs: [],
    name: 'upgradeByETH',
    outputs: [],
  },
  {
    stateMutability: 'payable',
    type: 'function',
    inputs: [{ name: 'to', internalType: 'address', type: 'address' }],
    name: 'upgradeByETHTo',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'to', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'upgradeTo',
    outputs: [],
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'oldAdmin',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'newAdmin',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'AdminChanged',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'agreementClass',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'id', internalType: 'bytes32', type: 'bytes32', indexed: false },
      {
        name: 'data',
        internalType: 'bytes32[]',
        type: 'bytes32[]',
        indexed: false,
      },
    ],
    name: 'AgreementCreated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'agreementClass',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'id', internalType: 'bytes32', type: 'bytes32', indexed: false },
      {
        name: 'penaltyAccount',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'rewardAccount',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'rewardAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'AgreementLiquidated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'liquidatorAccount',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'agreementClass',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'id', internalType: 'bytes32', type: 'bytes32', indexed: false },
      {
        name: 'penaltyAccount',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'bondAccount',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'rewardAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'bailoutAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'AgreementLiquidatedBy',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'agreementClass',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'id', internalType: 'bytes32', type: 'bytes32', indexed: false },
      {
        name: 'liquidatorAccount',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'targetAccount',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'rewardAmountReceiver',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'rewardAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'targetAccountBalanceDelta',
        internalType: 'int256',
        type: 'int256',
        indexed: false,
      },
      {
        name: 'liquidationTypeData',
        internalType: 'bytes',
        type: 'bytes',
        indexed: false,
      },
    ],
    name: 'AgreementLiquidatedV2',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'agreementClass',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'account',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'slotId',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'AgreementStateUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'agreementClass',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'id', internalType: 'bytes32', type: 'bytes32', indexed: false },
    ],
    name: 'AgreementTerminated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'agreementClass',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'id', internalType: 'bytes32', type: 'bytes32', indexed: false },
      {
        name: 'data',
        internalType: 'bytes32[]',
        type: 'bytes32[]',
        indexed: false,
      },
    ],
    name: 'AgreementUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'owner',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'spender',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'value',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Approval',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'operator',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'tokenHolder',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'AuthorizedOperator',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'bailoutAccount',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'bailoutAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Bailout',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'operator',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'from', internalType: 'address', type: 'address', indexed: true },
      {
        name: 'amount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      { name: 'data', internalType: 'bytes', type: 'bytes', indexed: false },
      {
        name: 'operatorData',
        internalType: 'bytes',
        type: 'bytes',
        indexed: false,
      },
    ],
    name: 'Burned',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'operator',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'to', internalType: 'address', type: 'address', indexed: true },
      {
        name: 'amount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      { name: 'data', internalType: 'bytes', type: 'bytes', indexed: false },
      {
        name: 'operatorData',
        internalType: 'bytes',
        type: 'bytes',
        indexed: false,
      },
    ],
    name: 'Minted',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'poolAdminNFT',
        internalType: 'contract IPoolAdminNFT',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'PoolAdminNFTCreated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'poolMemberNFT',
        internalType: 'contract IPoolMemberNFT',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'PoolMemberNFTCreated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'operator',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'tokenHolder',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'RevokedOperator',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'operator',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'from', internalType: 'address', type: 'address', indexed: true },
      { name: 'to', internalType: 'address', type: 'address', indexed: true },
      {
        name: 'amount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      { name: 'data', internalType: 'bytes', type: 'bytes', indexed: false },
      {
        name: 'operatorData',
        internalType: 'bytes',
        type: 'bytes',
        indexed: false,
      },
    ],
    name: 'Sent',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'account',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'amount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'TokenDowngraded',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'account',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'amount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'TokenUpgraded',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      { name: 'from', internalType: 'address', type: 'address', indexed: true },
      { name: 'to', internalType: 'address', type: 'address', indexed: true },
      {
        name: 'value',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Transfer',
  },
  { type: 'error', inputs: [], name: 'SF_TOKEN_AGREEMENT_ALREADY_EXISTS' },
  { type: 'error', inputs: [], name: 'SF_TOKEN_AGREEMENT_DOES_NOT_EXIST' },
  { type: 'error', inputs: [], name: 'SF_TOKEN_BURN_INSUFFICIENT_BALANCE' },
  { type: 'error', inputs: [], name: 'SF_TOKEN_MOVE_INSUFFICIENT_BALANCE' },
  { type: 'error', inputs: [], name: 'SF_TOKEN_ONLY_HOST' },
  { type: 'error', inputs: [], name: 'SF_TOKEN_ONLY_LISTED_AGREEMENT' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_APPROVE_FROM_ZERO_ADDRESS' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_APPROVE_TO_ZERO_ADDRESS' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_BURN_FROM_ZERO_ADDRESS' },
  {
    type: 'error',
    inputs: [],
    name: 'SUPER_TOKEN_CALLER_IS_NOT_OPERATOR_FOR_HOLDER',
  },
  {
    type: 'error',
    inputs: [],
    name: 'SUPER_TOKEN_INFLATIONARY_DEFLATIONARY_NOT_SUPPORTED',
  },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_MINT_TO_ZERO_ADDRESS' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_NFT_PROXY_ADDRESS_CHANGED' },
  {
    type: 'error',
    inputs: [],
    name: 'SUPER_TOKEN_NOT_ERC777_TOKENS_RECIPIENT',
  },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_NO_UNDERLYING_TOKEN' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_ONLY_ADMIN' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_ONLY_GOV_OWNER' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_ONLY_SELF' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_TRANSFER_FROM_ZERO_ADDRESS' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_TRANSFER_TO_ZERO_ADDRESS' },
] as const

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ISuperToken
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xd9bfb8a24c8e1889787ea0f99d77c952a82bfe50)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x2112b92a4f6496b7b2f10850857ffa270464d054)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x6c210f071c7246c452cac7f8baa6da53907bbae1)
 */
export const iSuperTokenABI = [
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'POOL_ADMIN_NFT',
    outputs: [
      { name: '', internalType: 'contract IPoolAdminNFT', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'POOL_MEMBER_NFT',
    outputs: [
      { name: '', internalType: 'contract IPoolMemberNFT', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'owner', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
    ],
    name: 'allowance',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'approve',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'operator', internalType: 'address', type: 'address' }],
    name: 'authorizeOperator',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'account', internalType: 'address', type: 'address' }],
    name: 'balanceOf',
    outputs: [{ name: 'balance', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'burn',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'newAdmin', internalType: 'address', type: 'address' }],
    name: 'changeAdmin',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'id', internalType: 'bytes32', type: 'bytes32' },
      { name: 'data', internalType: 'bytes32[]', type: 'bytes32[]' },
    ],
    name: 'createAgreement',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'decimals',
    outputs: [{ name: '', internalType: 'uint8', type: 'uint8' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'subtractedValue', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'decreaseAllowance',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'defaultOperators',
    outputs: [{ name: '', internalType: 'address[]', type: 'address[]' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'amount', internalType: 'uint256', type: 'uint256' }],
    name: 'downgrade',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'to', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'downgradeTo',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'account', internalType: 'address', type: 'address' }],
    name: 'getAccountActiveAgreements',
    outputs: [
      {
        name: 'activeAgreements',
        internalType: 'contract ISuperAgreement[]',
        type: 'address[]',
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getAdmin',
    outputs: [{ name: 'admin', internalType: 'address', type: 'address' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'agreementClass', internalType: 'address', type: 'address' },
      { name: 'id', internalType: 'bytes32', type: 'bytes32' },
      { name: 'dataLength', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'getAgreementData',
    outputs: [{ name: 'data', internalType: 'bytes32[]', type: 'bytes32[]' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'agreementClass', internalType: 'address', type: 'address' },
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'slotId', internalType: 'uint256', type: 'uint256' },
      { name: 'dataLength', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'getAgreementStateSlot',
    outputs: [
      { name: 'slotData', internalType: 'bytes32[]', type: 'bytes32[]' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getHost',
    outputs: [{ name: 'host', internalType: 'address', type: 'address' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getUnderlyingDecimals',
    outputs: [
      { name: 'underlyingDecimals', internalType: 'uint8', type: 'uint8' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getUnderlyingToken',
    outputs: [{ name: 'tokenAddr', internalType: 'address', type: 'address' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'granularity',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'addedValue', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'increaseAllowance',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'underlyingToken',
        internalType: 'contract IERC20',
        type: 'address',
      },
      { name: 'underlyingDecimals', internalType: 'uint8', type: 'uint8' },
      { name: 'n', internalType: 'string', type: 'string' },
      { name: 's', internalType: 'string', type: 'string' },
    ],
    name: 'initialize',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'underlyingToken',
        internalType: 'contract IERC20',
        type: 'address',
      },
      { name: 'underlyingDecimals', internalType: 'uint8', type: 'uint8' },
      { name: 'n', internalType: 'string', type: 'string' },
      { name: 's', internalType: 'string', type: 'string' },
      { name: 'admin', internalType: 'address', type: 'address' },
    ],
    name: 'initializeWithAdmin',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'isAccountCritical',
    outputs: [{ name: 'isCritical', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'account', internalType: 'address', type: 'address' }],
    name: 'isAccountCriticalNow',
    outputs: [{ name: 'isCritical', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'isAccountSolvent',
    outputs: [{ name: 'isSolvent', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'account', internalType: 'address', type: 'address' }],
    name: 'isAccountSolventNow',
    outputs: [{ name: 'isSolvent', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'operator', internalType: 'address', type: 'address' },
      { name: 'tokenHolder', internalType: 'address', type: 'address' },
    ],
    name: 'isOperatorFor',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'id', internalType: 'bytes32', type: 'bytes32' },
      { name: 'liquidationTypeData', internalType: 'bytes', type: 'bytes' },
      { name: 'liquidatorAccount', internalType: 'address', type: 'address' },
      { name: 'useDefaultRewardAccount', internalType: 'bool', type: 'bool' },
      { name: 'targetAccount', internalType: 'address', type: 'address' },
      { name: 'rewardAmount', internalType: 'uint256', type: 'uint256' },
      {
        name: 'targetAccountBalanceDelta',
        internalType: 'int256',
        type: 'int256',
      },
    ],
    name: 'makeLiquidationPayoutsV2',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'name',
    outputs: [{ name: '', internalType: 'string', type: 'string' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationApprove',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'subtractedValue', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationDecreaseAllowance',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationDowngrade',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'to', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationDowngradeTo',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'addedValue', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationIncreaseAllowance',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'recipient', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'operationSend',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'recipient', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationTransferFrom',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationUpgrade',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'to', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'operationUpgradeTo',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
      { name: 'operatorData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'operatorBurn',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'recipient', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
      { name: 'operatorData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'operatorSend',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'realtimeBalanceOf',
    outputs: [
      { name: 'availableBalance', internalType: 'int256', type: 'int256' },
      { name: 'deposit', internalType: 'uint256', type: 'uint256' },
      { name: 'owedDeposit', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'account', internalType: 'address', type: 'address' }],
    name: 'realtimeBalanceOfNow',
    outputs: [
      { name: 'availableBalance', internalType: 'int256', type: 'int256' },
      { name: 'deposit', internalType: 'uint256', type: 'uint256' },
      { name: 'owedDeposit', internalType: 'uint256', type: 'uint256' },
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'operator', internalType: 'address', type: 'address' }],
    name: 'revokeOperator',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'selfApproveFor',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'selfBurn',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'selfMint',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'recipient', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'selfTransferFrom',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'recipient', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'send',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'delta', internalType: 'int256', type: 'int256' },
    ],
    name: 'settleBalance',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'symbol',
    outputs: [{ name: '', internalType: 'string', type: 'string' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'id', internalType: 'bytes32', type: 'bytes32' },
      { name: 'dataLength', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'terminateAgreement',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'amount', internalType: 'uint256', type: 'uint256' }],
    name: 'toUnderlyingAmount',
    outputs: [
      { name: 'underlyingAmount', internalType: 'uint256', type: 'uint256' },
      { name: 'adjustedAmount', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'totalSupply',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'recipient', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'transfer',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'recipient', internalType: 'address', type: 'address' }],
    name: 'transferAll',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'sender', internalType: 'address', type: 'address' },
      { name: 'recipient', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'transferFrom',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'id', internalType: 'bytes32', type: 'bytes32' },
      { name: 'data', internalType: 'bytes32[]', type: 'bytes32[]' },
    ],
    name: 'updateAgreementData',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'account', internalType: 'address', type: 'address' },
      { name: 'slotId', internalType: 'uint256', type: 'uint256' },
      { name: 'slotData', internalType: 'bytes32[]', type: 'bytes32[]' },
    ],
    name: 'updateAgreementStateSlot',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'amount', internalType: 'uint256', type: 'uint256' }],
    name: 'upgrade',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'to', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'upgradeTo',
    outputs: [],
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'oldAdmin',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'newAdmin',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'AdminChanged',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'agreementClass',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'id', internalType: 'bytes32', type: 'bytes32', indexed: false },
      {
        name: 'data',
        internalType: 'bytes32[]',
        type: 'bytes32[]',
        indexed: false,
      },
    ],
    name: 'AgreementCreated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'agreementClass',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'id', internalType: 'bytes32', type: 'bytes32', indexed: false },
      {
        name: 'penaltyAccount',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'rewardAccount',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'rewardAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'AgreementLiquidated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'liquidatorAccount',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'agreementClass',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'id', internalType: 'bytes32', type: 'bytes32', indexed: false },
      {
        name: 'penaltyAccount',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'bondAccount',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'rewardAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'bailoutAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'AgreementLiquidatedBy',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'agreementClass',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'id', internalType: 'bytes32', type: 'bytes32', indexed: false },
      {
        name: 'liquidatorAccount',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'targetAccount',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'rewardAmountReceiver',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'rewardAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'targetAccountBalanceDelta',
        internalType: 'int256',
        type: 'int256',
        indexed: false,
      },
      {
        name: 'liquidationTypeData',
        internalType: 'bytes',
        type: 'bytes',
        indexed: false,
      },
    ],
    name: 'AgreementLiquidatedV2',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'agreementClass',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'account',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'slotId',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'AgreementStateUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'agreementClass',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'id', internalType: 'bytes32', type: 'bytes32', indexed: false },
    ],
    name: 'AgreementTerminated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'agreementClass',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'id', internalType: 'bytes32', type: 'bytes32', indexed: false },
      {
        name: 'data',
        internalType: 'bytes32[]',
        type: 'bytes32[]',
        indexed: false,
      },
    ],
    name: 'AgreementUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'owner',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'spender',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'value',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Approval',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'operator',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'tokenHolder',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'AuthorizedOperator',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'bailoutAccount',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'bailoutAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Bailout',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'operator',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'from', internalType: 'address', type: 'address', indexed: true },
      {
        name: 'amount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      { name: 'data', internalType: 'bytes', type: 'bytes', indexed: false },
      {
        name: 'operatorData',
        internalType: 'bytes',
        type: 'bytes',
        indexed: false,
      },
    ],
    name: 'Burned',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'operator',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'to', internalType: 'address', type: 'address', indexed: true },
      {
        name: 'amount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      { name: 'data', internalType: 'bytes', type: 'bytes', indexed: false },
      {
        name: 'operatorData',
        internalType: 'bytes',
        type: 'bytes',
        indexed: false,
      },
    ],
    name: 'Minted',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'poolAdminNFT',
        internalType: 'contract IPoolAdminNFT',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'PoolAdminNFTCreated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'poolMemberNFT',
        internalType: 'contract IPoolMemberNFT',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'PoolMemberNFTCreated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'operator',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'tokenHolder',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'RevokedOperator',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'operator',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'from', internalType: 'address', type: 'address', indexed: true },
      { name: 'to', internalType: 'address', type: 'address', indexed: true },
      {
        name: 'amount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      { name: 'data', internalType: 'bytes', type: 'bytes', indexed: false },
      {
        name: 'operatorData',
        internalType: 'bytes',
        type: 'bytes',
        indexed: false,
      },
    ],
    name: 'Sent',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'account',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'amount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'TokenDowngraded',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'account',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'amount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'TokenUpgraded',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      { name: 'from', internalType: 'address', type: 'address', indexed: true },
      { name: 'to', internalType: 'address', type: 'address', indexed: true },
      {
        name: 'value',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Transfer',
  },
  { type: 'error', inputs: [], name: 'SF_TOKEN_AGREEMENT_ALREADY_EXISTS' },
  { type: 'error', inputs: [], name: 'SF_TOKEN_AGREEMENT_DOES_NOT_EXIST' },
  { type: 'error', inputs: [], name: 'SF_TOKEN_BURN_INSUFFICIENT_BALANCE' },
  { type: 'error', inputs: [], name: 'SF_TOKEN_MOVE_INSUFFICIENT_BALANCE' },
  { type: 'error', inputs: [], name: 'SF_TOKEN_ONLY_HOST' },
  { type: 'error', inputs: [], name: 'SF_TOKEN_ONLY_LISTED_AGREEMENT' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_APPROVE_FROM_ZERO_ADDRESS' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_APPROVE_TO_ZERO_ADDRESS' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_BURN_FROM_ZERO_ADDRESS' },
  {
    type: 'error',
    inputs: [],
    name: 'SUPER_TOKEN_CALLER_IS_NOT_OPERATOR_FOR_HOLDER',
  },
  {
    type: 'error',
    inputs: [],
    name: 'SUPER_TOKEN_INFLATIONARY_DEFLATIONARY_NOT_SUPPORTED',
  },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_MINT_TO_ZERO_ADDRESS' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_NFT_PROXY_ADDRESS_CHANGED' },
  {
    type: 'error',
    inputs: [],
    name: 'SUPER_TOKEN_NOT_ERC777_TOKENS_RECIPIENT',
  },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_NO_UNDERLYING_TOKEN' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_ONLY_ADMIN' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_ONLY_GOV_OWNER' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_ONLY_SELF' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_TRANSFER_FROM_ZERO_ADDRESS' },
  { type: 'error', inputs: [], name: 'SUPER_TOKEN_TRANSFER_TO_ZERO_ADDRESS' },
] as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xd9bfb8a24c8e1889787ea0f99d77c952a82bfe50)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x2112b92a4f6496b7b2f10850857ffa270464d054)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x6c210f071c7246c452cac7f8baa6da53907bbae1)
 */
export const iSuperTokenAddress = {
  10: '0xd9bfb8A24c8E1889787Ea0f99D77C952a82Bfe50',
  8453: '0x2112b92A4f6496B7b2f10850857FfA270464d054',
  42220: '0x6C210F071c7246C452CAC7F8BaA6dA53907BbaE1',
} as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xd9bfb8a24c8e1889787ea0f99d77c952a82bfe50)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x2112b92a4f6496b7b2f10850857ffa270464d054)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0x6c210f071c7246c452cac7f8baa6da53907bbae1)
 */
export const iSuperTokenConfig = {
  address: iSuperTokenAddress,
  abi: iSuperTokenABI,
} as const

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ISuperfluid
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0x567c4B141ED61923967cA25Ef4906C8781069a10)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x4C073B3baB6d8826b8C5b229f3cfdC1eC6E47E74)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0xA4Ff07cF81C02CFD356184879D953970cA957585)
 */
export const iSuperfluidABI = [
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'bitmap', internalType: 'uint256', type: 'uint256' },
      { name: 'agreementType', internalType: 'bytes32', type: 'bytes32' },
    ],
    name: 'addToAgreementClassesBitmap',
    outputs: [{ name: 'newBitmap', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'targetApp',
        internalType: 'contract ISuperApp',
        type: 'address',
      },
    ],
    name: 'allowCompositeApp',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
      { name: 'appCreditUsedDelta', internalType: 'int256', type: 'int256' },
    ],
    name: 'appCallbackPop',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
      { name: 'app', internalType: 'contract ISuperApp', type: 'address' },
      { name: 'appCreditGranted', internalType: 'uint256', type: 'uint256' },
      { name: 'appCreditUsed', internalType: 'int256', type: 'int256' },
      {
        name: 'appCreditToken',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
      },
    ],
    name: 'appCallbackPush',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'payable',
    type: 'function',
    inputs: [
      {
        name: 'operations',
        internalType: 'struct ISuperfluid.Operation[]',
        type: 'tuple[]',
        components: [
          { name: 'operationType', internalType: 'uint32', type: 'uint32' },
          { name: 'target', internalType: 'address', type: 'address' },
          { name: 'data', internalType: 'bytes', type: 'bytes' },
        ],
      },
    ],
    name: 'batchCall',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'agreementClass',
        internalType: 'contract ISuperAgreement',
        type: 'address',
      },
      { name: 'callData', internalType: 'bytes', type: 'bytes' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'callAgreement',
    outputs: [{ name: 'returnedData', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'agreementClass',
        internalType: 'contract ISuperAgreement',
        type: 'address',
      },
      { name: 'callData', internalType: 'bytes', type: 'bytes' },
      { name: 'userData', internalType: 'bytes', type: 'bytes' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'callAgreementWithContext',
    outputs: [
      { name: 'newCtx', internalType: 'bytes', type: 'bytes' },
      { name: 'returnedData', internalType: 'bytes', type: 'bytes' },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'app', internalType: 'contract ISuperApp', type: 'address' },
      { name: 'callData', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'callAppAction',
    outputs: [{ name: 'returnedData', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'app', internalType: 'contract ISuperApp', type: 'address' },
      { name: 'callData', internalType: 'bytes', type: 'bytes' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'callAppActionWithContext',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'app', internalType: 'contract ISuperApp', type: 'address' },
      { name: 'callData', internalType: 'bytes', type: 'bytes' },
      { name: 'isTermination', internalType: 'bool', type: 'bool' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'callAppAfterCallback',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'app', internalType: 'contract ISuperApp', type: 'address' },
      { name: 'callData', internalType: 'bytes', type: 'bytes' },
      { name: 'isTermination', internalType: 'bool', type: 'bool' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'callAppBeforeCallback',
    outputs: [{ name: 'cbdata', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'newAdmin', internalType: 'address', type: 'address' },
    ],
    name: 'changeSuperTokenAdmin',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
      { name: 'appCreditUsedMore', internalType: 'int256', type: 'int256' },
    ],
    name: 'ctxUseCredit',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'pure',
    type: 'function',
    inputs: [{ name: 'ctx', internalType: 'bytes', type: 'bytes' }],
    name: 'decodeCtx',
    outputs: [
      {
        name: 'context',
        internalType: 'struct ISuperfluid.Context',
        type: 'tuple',
        components: [
          { name: 'appCallbackLevel', internalType: 'uint8', type: 'uint8' },
          { name: 'callType', internalType: 'uint8', type: 'uint8' },
          { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
          { name: 'msgSender', internalType: 'address', type: 'address' },
          { name: 'agreementSelector', internalType: 'bytes4', type: 'bytes4' },
          { name: 'userData', internalType: 'bytes', type: 'bytes' },
          {
            name: 'appCreditGranted',
            internalType: 'uint256',
            type: 'uint256',
          },
          {
            name: 'appCreditWantedDeprecated',
            internalType: 'uint256',
            type: 'uint256',
          },
          { name: 'appCreditUsed', internalType: 'int256', type: 'int256' },
          { name: 'appAddress', internalType: 'address', type: 'address' },
          {
            name: 'appCreditToken',
            internalType: 'contract ISuperfluidToken',
            type: 'address',
          },
        ],
      },
    ],
  },
  {
    stateMutability: 'payable',
    type: 'function',
    inputs: [
      {
        name: 'operations',
        internalType: 'struct ISuperfluid.Operation[]',
        type: 'tuple[]',
        components: [
          { name: 'operationType', internalType: 'uint32', type: 'uint32' },
          { name: 'target', internalType: 'address', type: 'address' },
          { name: 'data', internalType: 'bytes', type: 'bytes' },
        ],
      },
    ],
    name: 'forwardBatchCall',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'agreementType', internalType: 'bytes32', type: 'bytes32' },
    ],
    name: 'getAgreementClass',
    outputs: [
      {
        name: 'agreementClass',
        internalType: 'contract ISuperAgreement',
        type: 'address',
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'app', internalType: 'contract ISuperApp', type: 'address' },
    ],
    name: 'getAppCallbackLevel',
    outputs: [
      { name: 'appCallbackLevel', internalType: 'uint8', type: 'uint8' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'app', internalType: 'contract ISuperApp', type: 'address' },
    ],
    name: 'getAppManifest',
    outputs: [
      { name: 'isSuperApp', internalType: 'bool', type: 'bool' },
      { name: 'isJailed', internalType: 'bool', type: 'bool' },
      { name: 'noopMask', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getGovernance',
    outputs: [
      {
        name: 'governance',
        internalType: 'contract ISuperfluidGovernance',
        type: 'address',
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getNow',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getSuperTokenFactory',
    outputs: [
      {
        name: 'factory',
        internalType: 'contract ISuperTokenFactory',
        type: 'address',
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getSuperTokenFactoryLogic',
    outputs: [{ name: 'logic', internalType: 'address', type: 'address' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'agreementClass',
        internalType: 'contract ISuperAgreement',
        type: 'address',
      },
    ],
    name: 'isAgreementClassListed',
    outputs: [{ name: 'yes', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'agreementType', internalType: 'bytes32', type: 'bytes32' },
    ],
    name: 'isAgreementTypeListed',
    outputs: [{ name: 'yes', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'app', internalType: 'contract ISuperApp', type: 'address' },
    ],
    name: 'isApp',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'app', internalType: 'contract ISuperApp', type: 'address' },
    ],
    name: 'isAppJailed',
    outputs: [{ name: 'isJail', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'app', internalType: 'contract ISuperApp', type: 'address' },
      {
        name: 'targetApp',
        internalType: 'contract ISuperApp',
        type: 'address',
      },
    ],
    name: 'isCompositeAppAllowed',
    outputs: [{ name: 'isAppAllowed', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'ctx', internalType: 'bytes', type: 'bytes' }],
    name: 'isCtxValid',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
      { name: 'app', internalType: 'contract ISuperApp', type: 'address' },
      { name: 'reason', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'jailApp',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'bitmap', internalType: 'uint256', type: 'uint256' }],
    name: 'mapAgreementClasses',
    outputs: [
      {
        name: 'agreementClasses',
        internalType: 'contract ISuperAgreement[]',
        type: 'address[]',
      },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'agreementClassLogic',
        internalType: 'contract ISuperAgreement',
        type: 'address',
      },
    ],
    name: 'registerAgreementClass',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'configWord', internalType: 'uint256', type: 'uint256' }],
    name: 'registerApp',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'app', internalType: 'contract ISuperApp', type: 'address' },
      { name: 'configWord', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'registerApp',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'app', internalType: 'contract ISuperApp', type: 'address' },
      { name: 'configWord', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'registerAppByFactory',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'configWord', internalType: 'uint256', type: 'uint256' },
      { name: 'registrationKey', internalType: 'string', type: 'string' },
    ],
    name: 'registerAppWithKey',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'bitmap', internalType: 'uint256', type: 'uint256' },
      { name: 'agreementType', internalType: 'bytes32', type: 'bytes32' },
    ],
    name: 'removeFromAgreementClassesBitmap',
    outputs: [{ name: 'newBitmap', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'newGov',
        internalType: 'contract ISuperfluidGovernance',
        type: 'address',
      },
    ],
    name: 'replaceGovernance',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'agreementClassLogic',
        internalType: 'contract ISuperAgreement',
        type: 'address',
      },
    ],
    name: 'updateAgreementClass',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'newBeaconLogic', internalType: 'address', type: 'address' },
    ],
    name: 'updatePoolBeaconLogic',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'newFactory',
        internalType: 'contract ISuperTokenFactory',
        type: 'address',
      },
    ],
    name: 'updateSuperTokenFactory',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'token', internalType: 'contract ISuperToken', type: 'address' },
      { name: 'newLogicOverride', internalType: 'address', type: 'address' },
    ],
    name: 'updateSuperTokenLogic',
    outputs: [],
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'agreementType',
        internalType: 'bytes32',
        type: 'bytes32',
        indexed: false,
      },
      {
        name: 'code',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
    ],
    name: 'AgreementClassRegistered',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'agreementType',
        internalType: 'bytes32',
        type: 'bytes32',
        indexed: false,
      },
      {
        name: 'code',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
    ],
    name: 'AgreementClassUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'app',
        internalType: 'contract ISuperApp',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'AppRegistered',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'oldGov',
        internalType: 'contract ISuperfluidGovernance',
        type: 'address',
        indexed: false,
      },
      {
        name: 'newGov',
        internalType: 'contract ISuperfluidGovernance',
        type: 'address',
        indexed: false,
      },
    ],
    name: 'GovernanceReplaced',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'app',
        internalType: 'contract ISuperApp',
        type: 'address',
        indexed: true,
      },
      {
        name: 'reason',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Jail',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'beaconProxy',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'newBeaconLogic',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
    ],
    name: 'PoolBeaconLogicUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'newFactory',
        internalType: 'contract ISuperTokenFactory',
        type: 'address',
        indexed: false,
      },
    ],
    name: 'SuperTokenFactoryUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperToken',
        type: 'address',
        indexed: true,
      },
      {
        name: 'code',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
    ],
    name: 'SuperTokenLogicUpdated',
  },
  {
    type: 'error',
    inputs: [{ name: '_code', internalType: 'uint256', type: 'uint256' }],
    name: 'APP_RULE',
  },
  { type: 'error', inputs: [], name: 'HOST_AGREEMENT_ALREADY_REGISTERED' },
  { type: 'error', inputs: [], name: 'HOST_AGREEMENT_CALLBACK_IS_NOT_ACTION' },
  { type: 'error', inputs: [], name: 'HOST_AGREEMENT_IS_NOT_REGISTERED' },
  {
    type: 'error',
    inputs: [],
    name: 'HOST_CALL_AGREEMENT_WITH_CTX_FROM_WRONG_ADDRESS',
  },
  {
    type: 'error',
    inputs: [],
    name: 'HOST_CALL_APP_ACTION_WITH_CTX_FROM_WRONG_ADDRESS',
  },
  {
    type: 'error',
    inputs: [],
    name: 'HOST_CANNOT_DOWNGRADE_TO_NON_UPGRADEABLE',
  },
  { type: 'error', inputs: [], name: 'HOST_INVALID_CONFIG_WORD' },
  { type: 'error', inputs: [], name: 'HOST_MAX_256_AGREEMENTS' },
  { type: 'error', inputs: [], name: 'HOST_MUST_BE_CONTRACT' },
  { type: 'error', inputs: [], name: 'HOST_NEED_MORE_GAS' },
  { type: 'error', inputs: [], name: 'HOST_NON_UPGRADEABLE' },
  { type: 'error', inputs: [], name: 'HOST_NON_ZERO_LENGTH_PLACEHOLDER_CTX' },
  { type: 'error', inputs: [], name: 'HOST_NOT_A_SUPER_APP' },
  { type: 'error', inputs: [], name: 'HOST_NO_APP_REGISTRATION_PERMISSION' },
  { type: 'error', inputs: [], name: 'HOST_ONLY_GOVERNANCE' },
  { type: 'error', inputs: [], name: 'HOST_ONLY_LISTED_AGREEMENT' },
  { type: 'error', inputs: [], name: 'HOST_RECEIVER_IS_NOT_SUPER_APP' },
  { type: 'error', inputs: [], name: 'HOST_SENDER_IS_NOT_SUPER_APP' },
  { type: 'error', inputs: [], name: 'HOST_SOURCE_APP_NEEDS_HIGHER_APP_LEVEL' },
  { type: 'error', inputs: [], name: 'HOST_SUPER_APP_ALREADY_REGISTERED' },
  { type: 'error', inputs: [], name: 'HOST_SUPER_APP_IS_JAILED' },
  { type: 'error', inputs: [], name: 'HOST_UNKNOWN_BATCH_CALL_OPERATION_TYPE' },
] as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0x567c4B141ED61923967cA25Ef4906C8781069a10)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x4C073B3baB6d8826b8C5b229f3cfdC1eC6E47E74)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0xA4Ff07cF81C02CFD356184879D953970cA957585)
 */
export const iSuperfluidAddress = {
  10: '0x567c4B141ED61923967cA25Ef4906C8781069a10',
  8453: '0x4C073B3baB6d8826b8C5b229f3cfdC1eC6E47E74',
  42220: '0xA4Ff07cF81C02CFD356184879D953970cA957585',
} as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0x567c4B141ED61923967cA25Ef4906C8781069a10)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x4C073B3baB6d8826b8C5b229f3cfdC1eC6E47E74)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0xA4Ff07cF81C02CFD356184879D953970cA957585)
 */
export const iSuperfluidConfig = {
  address: iSuperfluidAddress,
  abi: iSuperfluidABI,
} as const

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ISuperfluidPool
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

export const iSuperfluidPoolABI = [
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'admin',
    outputs: [{ name: '', internalType: 'address', type: 'address' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'owner', internalType: 'address', type: 'address' },
      { name: 'spender', internalType: 'address', type: 'address' },
    ],
    name: 'allowance',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'approve',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'account', internalType: 'address', type: 'address' }],
    name: 'balanceOf',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'memberAddr', internalType: 'address', type: 'address' }],
    name: 'claimAll',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [],
    name: 'claimAll',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'subtractedValue', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'decreaseAllowance',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'distributionFromAnyAddress',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'memberAddr', internalType: 'address', type: 'address' },
      { name: 'time', internalType: 'uint32', type: 'uint32' },
    ],
    name: 'getClaimable',
    outputs: [{ name: '', internalType: 'int256', type: 'int256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'memberAddr', internalType: 'address', type: 'address' }],
    name: 'getClaimableNow',
    outputs: [
      { name: 'claimableBalance', internalType: 'int256', type: 'int256' },
      { name: 'timestamp', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'time', internalType: 'uint32', type: 'uint32' }],
    name: 'getDisconnectedBalance',
    outputs: [{ name: 'balance', internalType: 'int256', type: 'int256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'memberAddr', internalType: 'address', type: 'address' }],
    name: 'getMemberFlowRate',
    outputs: [{ name: '', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'memberAddr', internalType: 'address', type: 'address' }],
    name: 'getTotalAmountReceivedByMember',
    outputs: [
      { name: 'totalAmountReceived', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getTotalConnectedFlowRate',
    outputs: [{ name: '', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getTotalConnectedUnits',
    outputs: [{ name: '', internalType: 'uint128', type: 'uint128' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getTotalDisconnectedFlowRate',
    outputs: [{ name: '', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getTotalDisconnectedUnits',
    outputs: [{ name: '', internalType: 'uint128', type: 'uint128' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getTotalFlowRate',
    outputs: [{ name: '', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getTotalUnits',
    outputs: [{ name: '', internalType: 'uint128', type: 'uint128' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'memberAddr', internalType: 'address', type: 'address' }],
    name: 'getUnits',
    outputs: [{ name: '', internalType: 'uint128', type: 'uint128' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'spender', internalType: 'address', type: 'address' },
      { name: 'addedValue', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'increaseAllowance',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'superToken',
    outputs: [
      { name: '', internalType: 'contract ISuperfluidToken', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'totalSupply',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'to', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'transfer',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'from', internalType: 'address', type: 'address' },
      { name: 'to', internalType: 'address', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'transferFrom',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'transferabilityForUnitsOwner',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'memberAddr', internalType: 'address', type: 'address' },
      { name: 'newUnits', internalType: 'uint128', type: 'uint128' },
    ],
    name: 'updateMemberUnits',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'owner',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'spender',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'value',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Approval',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
        indexed: true,
      },
      {
        name: 'member',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'claimedAmount',
        internalType: 'int256',
        type: 'int256',
        indexed: false,
      },
      {
        name: 'totalClaimed',
        internalType: 'int256',
        type: 'int256',
        indexed: false,
      },
    ],
    name: 'DistributionClaimed',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'token',
        internalType: 'contract ISuperfluidToken',
        type: 'address',
        indexed: true,
      },
      {
        name: 'member',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'oldUnits',
        internalType: 'uint128',
        type: 'uint128',
        indexed: false,
      },
      {
        name: 'newUnits',
        internalType: 'uint128',
        type: 'uint128',
        indexed: false,
      },
    ],
    name: 'MemberUnitsUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      { name: 'from', internalType: 'address', type: 'address', indexed: true },
      { name: 'to', internalType: 'address', type: 'address', indexed: true },
      {
        name: 'value',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Transfer',
  },
  { type: 'error', inputs: [], name: 'SUPERFLUID_POOL_INVALID_TIME' },
  { type: 'error', inputs: [], name: 'SUPERFLUID_POOL_NOT_GDA' },
  { type: 'error', inputs: [], name: 'SUPERFLUID_POOL_NOT_POOL_ADMIN_OR_GDA' },
  { type: 'error', inputs: [], name: 'SUPERFLUID_POOL_NO_POOL_MEMBERS' },
  { type: 'error', inputs: [], name: 'SUPERFLUID_POOL_NO_ZERO_ADDRESS' },
  {
    type: 'error',
    inputs: [],
    name: 'SUPERFLUID_POOL_SELF_TRANSFER_NOT_ALLOWED',
  },
  {
    type: 'error',
    inputs: [],
    name: 'SUPERFLUID_POOL_TRANSFER_UNITS_NOT_ALLOWED',
  },
] as const

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MacroForwarder
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xfD01285b9435bc45C243E5e7F978E288B2912de6)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0xfD01285b9435bc45C243E5e7F978E288B2912de6)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0xfD01285b9435bc45C243E5e7F978E288B2912de6)
 */
export const macroForwarderABI = [
  {
    stateMutability: 'nonpayable',
    type: 'constructor',
    inputs: [
      { name: 'host', internalType: 'contract ISuperfluid', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'm',
        internalType: 'contract IUserDefinedMacro',
        type: 'address',
      },
      { name: 'params', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'buildBatchOperations',
    outputs: [
      {
        name: 'operations',
        internalType: 'struct ISuperfluid.Operation[]',
        type: 'tuple[]',
        components: [
          { name: 'operationType', internalType: 'uint32', type: 'uint32' },
          { name: 'target', internalType: 'address', type: 'address' },
          { name: 'data', internalType: 'bytes', type: 'bytes' },
        ],
      },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'm',
        internalType: 'contract IUserDefinedMacro',
        type: 'address',
      },
      { name: 'params', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'runMacro',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
] as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xfD01285b9435bc45C243E5e7F978E288B2912de6)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0xfD01285b9435bc45C243E5e7F978E288B2912de6)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0xfD01285b9435bc45C243E5e7F978E288B2912de6)
 */
export const macroForwarderAddress = {
  10: '0xfD01285b9435bc45C243E5e7F978E288B2912de6',
  8453: '0xfD01285b9435bc45C243E5e7F978E288B2912de6',
  42220: '0xfD01285b9435bc45C243E5e7F978E288B2912de6',
} as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xfD01285b9435bc45C243E5e7F978E288B2912de6)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0xfD01285b9435bc45C243E5e7F978E288B2912de6)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0xfD01285b9435bc45C243E5e7F978E288B2912de6)
 */
export const macroForwarderConfig = {
  address: macroForwarderAddress,
  abi: macroForwarderABI,
} as const

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SB712Macro
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xd26b36ef4c811b1830341736235d92e6cfd9eb8f)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x353890b5ec7e97a514f749e2d5778d901e4d9c5f)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0xce106a7e8c0488d8e06b05d73810d1883ea5411d)
 */
export const sb712MacroABI = [
  { stateMutability: 'nonpayable', type: 'constructor', inputs: [] },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'ACTION_SET_DCA_POSITION_CODE',
    outputs: [{ name: '', internalType: 'uint8', type: 'uint8' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'ACTION_SET_DCA_POSITION_NAME',
    outputs: [{ name: '', internalType: 'string', type: 'string' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'TYPEHASH_SET_DCA_POSITION',
    outputs: [{ name: '', internalType: 'bytes32', type: 'bytes32' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'host', internalType: 'contract ISuperfluid', type: 'address' },
      { name: 'params', internalType: 'bytes', type: 'bytes' },
      { name: 'msgSender', internalType: 'address', type: 'address' },
    ],
    name: 'buildBatchOperations',
    outputs: [
      {
        name: 'operations',
        internalType: 'struct ISuperfluid.Operation[]',
        type: 'tuple[]',
        components: [
          { name: 'operationType', internalType: 'uint32', type: 'uint32' },
          { name: 'target', internalType: 'address', type: 'address' },
          { name: 'data', internalType: 'bytes', type: 'bytes' },
        ],
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'eip712Domain',
    outputs: [
      { name: 'fields', internalType: 'bytes1', type: 'bytes1' },
      { name: 'name', internalType: 'string', type: 'string' },
      { name: 'version', internalType: 'string', type: 'string' },
      { name: 'chainId', internalType: 'uint256', type: 'uint256' },
      { name: 'verifyingContract', internalType: 'address', type: 'address' },
      { name: 'salt', internalType: 'bytes32', type: 'bytes32' },
      { name: 'extensions', internalType: 'uint256[]', type: 'uint256[]' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'lang', internalType: 'bytes32', type: 'bytes32' },
      {
        name: 'params',
        internalType: 'struct SB712Macro.SetDCAPositionParams',
        type: 'tuple',
        components: [
          { name: 'torex', internalType: 'contract ITorex', type: 'address' },
          { name: 'flowRate', internalType: 'int96', type: 'int96' },
          { name: 'distributor', internalType: 'address', type: 'address' },
          { name: 'referrer', internalType: 'address', type: 'address' },
          { name: 'upgradeAmount', internalType: 'uint256', type: 'uint256' },
        ],
      },
    ],
    name: 'encode712SetDCAPosition',
    outputs: [
      { name: 'actionCode', internalType: 'uint8', type: 'uint8' },
      { name: 'message', internalType: 'string', type: 'string' },
      { name: 'actionParams', internalType: 'bytes', type: 'bytes' },
      { name: 'digest', internalType: 'bytes32', type: 'bytes32' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'host', internalType: 'contract ISuperfluid', type: 'address' },
      { name: 'params', internalType: 'bytes', type: 'bytes' },
      { name: 'msgSender', internalType: 'address', type: 'address' },
    ],
    name: 'postCheck',
    outputs: [],
  },
  { type: 'event', anonymous: false, inputs: [], name: 'EIP712DomainChanged' },
  { type: 'error', inputs: [], name: 'InvalidPeriod' },
  { type: 'error', inputs: [], name: 'InvalidShortString' },
  { type: 'error', inputs: [], name: 'InvalidSignature' },
  { type: 'error', inputs: [], name: 'NoOutTokenPoolUnits' },
  {
    type: 'error',
    inputs: [{ name: 'str', internalType: 'string', type: 'string' }],
    name: 'StringTooLong',
  },
  {
    type: 'error',
    inputs: [{ name: 'actionCode', internalType: 'uint8', type: 'uint8' }],
    name: 'UnknownActionCode',
  },
  { type: 'error', inputs: [], name: 'UnsupportedLanguage' },
] as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xd26b36ef4c811b1830341736235d92e6cfd9eb8f)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x353890b5ec7e97a514f749e2d5778d901e4d9c5f)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0xce106a7e8c0488d8e06b05d73810d1883ea5411d)
 */
export const sb712MacroAddress = {
  10: '0xd26B36ef4c811B1830341736235D92e6CFd9EB8F',
  8453: '0x353890b5Ec7e97a514F749E2d5778d901e4D9C5f',
  42220: '0xce106A7E8c0488D8E06B05d73810d1883eA5411D',
} as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0xd26b36ef4c811b1830341736235d92e6cfd9eb8f)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x353890b5ec7e97a514f749e2d5778d901e4d9c5f)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0xce106a7e8c0488d8e06b05d73810d1883ea5411d)
 */
export const sb712MacroConfig = {
  address: sb712MacroAddress,
  abi: sb712MacroABI,
} as const

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SuperBoring
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0x8eee2a69423509b6ca2eeb11c78936fbf1b89824)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x37d607bd9dfff80acf37184c1f27e88388914262)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0xaca744453c178f3d651e06a3459e2f242aa01789)
 */
export const superBoringABI = [
  {
    stateMutability: 'nonpayable',
    type: 'constructor',
    inputs: [
      {
        name: 'boringToken_',
        internalType: 'contract ISuperToken',
        type: 'address',
      },
      {
        name: 'tokenFactory_',
        internalType: 'contract TorexFactory',
        type: 'address',
      },
      {
        name: 'emissionTreasury_',
        internalType: 'contract EmissionTreasury',
        type: 'address',
      },
      {
        name: 'distributionFeeManager_',
        internalType: 'contract DistributionFeeManager',
        type: 'address',
      },
      {
        name: 'sleepPodBeacon_',
        internalType: 'contract UpgradeableBeacon',
        type: 'address',
      },
      {
        name: 'config',
        internalType: 'struct SuperBoring.Config',
        type: 'tuple',
        components: [
          { name: 'inTokenFeePM', internalType: 'uint256', type: 'uint256' },
          {
            name: 'minimumStakingAmount',
            internalType: 'uint256',
            type: 'uint256',
          },
        ],
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'DISTRIBUTION_TAX_RATE_PM',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'IN_TOKEN_FEE_PM',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'MINIMUM_STAKING_AMOUNT',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'QE_REFERRAL_BONUS',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'boringToken',
    outputs: [
      { name: '', internalType: 'contract ISuperToken', type: 'address' },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [],
    name: 'castrate',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'torexConfig',
        internalType: 'struct Torex.Config',
        type: 'tuple',
        components: [
          {
            name: 'inToken',
            internalType: 'contract ISuperToken',
            type: 'address',
          },
          {
            name: 'outToken',
            internalType: 'contract ISuperToken',
            type: 'address',
          },
          {
            name: 'observer',
            internalType: 'contract ITwapObserver',
            type: 'address',
          },
          {
            name: 'discountFactor',
            internalType: 'DiscountFactor',
            type: 'uint256',
          },
          { name: 'twapScaler', internalType: 'Scaler', type: 'int256' },
          {
            name: 'outTokenDistributionPoolScaler',
            internalType: 'Scaler',
            type: 'int256',
          },
          {
            name: 'controller',
            internalType: 'contract ITorexController',
            type: 'address',
          },
          {
            name: 'controllerSafeCallbackGasLimit',
            internalType: 'uint256',
            type: 'uint256',
          },
          { name: 'maxAllowedFeePM', internalType: 'uint256', type: 'uint256' },
        ],
      },
      { name: 'feePoolScalerN10Pow', internalType: 'int8', type: 'int8' },
      { name: 'boringPoolScalerN10Pow', internalType: 'int8', type: 'int8' },
      {
        name: 'hops',
        internalType: 'struct UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[]',
        type: 'tuple[]',
        components: [
          {
            name: 'pool',
            internalType: 'contract IUniswapV3Pool',
            type: 'address',
          },
          { name: 'inverseOrder', internalType: 'bool', type: 'bool' },
        ],
      },
    ],
    name: 'createUniV3PoolTwapObserverAndTorex',
    outputs: [
      { name: 'torex', internalType: 'contract Torex', type: 'address' },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'decreaseStake',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'distributionFeeManager',
    outputs: [
      {
        name: '',
        internalType: 'contract DistributionFeeManager',
        type: 'address',
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'emissionTreasury',
    outputs: [
      { name: '', internalType: 'contract EmissionTreasury', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getAllTorexesMetadata',
    outputs: [
      {
        name: 'metadataList',
        internalType: 'struct TorexMetadata[]',
        type: 'tuple[]',
        components: [
          { name: 'torexAddr', internalType: 'address', type: 'address' },
          {
            name: 'inToken',
            internalType: 'contract ISuperToken',
            type: 'address',
          },
          {
            name: 'outToken',
            internalType: 'contract ISuperToken',
            type: 'address',
          },
        ],
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'skip', internalType: 'uint256', type: 'uint256' },
      { name: 'first', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'getAllTorexesMetadata',
    outputs: [
      {
        name: 'metadataList',
        internalType: 'struct TorexMetadata[]',
        type: 'tuple[]',
        components: [
          { name: 'torexAddr', internalType: 'address', type: 'address' },
          {
            name: 'inToken',
            internalType: 'contract ISuperToken',
            type: 'address',
          },
          {
            name: 'outToken',
            internalType: 'contract ISuperToken',
            type: 'address',
          },
        ],
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
    ],
    name: 'getBoringPoolScaler',
    outputs: [{ name: 'scaler', internalType: 'Scaler', type: 'int256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getCodeAddress',
    outputs: [
      { name: 'codeAddress', internalType: 'address', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
      { name: 'trader', internalType: 'address', type: 'address' },
    ],
    name: 'getCurrentDistributor',
    outputs: [
      { name: 'distributor', internalType: 'address', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
      { name: 'trader', internalType: 'address', type: 'address' },
    ],
    name: 'getCurrentReferrerPod',
    outputs: [{ name: 'referrer', internalType: 'address', type: 'address' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
      { name: 'distributor', internalType: 'address', type: 'address' },
    ],
    name: 'getDistributorStats',
    outputs: [
      { name: 'distributedVolume', internalType: 'int256', type: 'int256' },
      { name: 'totalFlowRate', internalType: 'int96', type: 'int96' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
    ],
    name: 'getFeePoolScaler',
    outputs: [{ name: 'scaler', internalType: 'Scaler', type: 'int256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
      { name: 'me', internalType: 'address', type: 'address' },
    ],
    name: 'getMyBoringRewardInfo',
    outputs: [
      { name: 'totalRewardRate', internalType: 'int96', type: 'int96' },
      { name: 'tradingRewardRate', internalType: 'int96', type: 'int96' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getQETargetTotalEmissionRate',
    outputs: [{ name: '', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'staker', internalType: 'address', type: 'address' }],
    name: 'getSleepPod',
    outputs: [
      { name: 'sleepPod', internalType: 'contract SleepPod', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'staker', internalType: 'address', type: 'address' }],
    name: 'getStakeableAmount',
    outputs: [{ name: 'amount', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
      { name: 'staker', internalType: 'address', type: 'address' },
    ],
    name: 'getStakedAmountOf',
    outputs: [
      { name: 'stakedAmount', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
    ],
    name: 'getTotalStakedAmount',
    outputs: [
      { name: 'stakedAmount', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
    ],
    name: 'getTotalityStats',
    outputs: [
      { name: 'distributedVolume', internalType: 'int256', type: 'int256' },
      { name: 'totalFlowRate', internalType: 'int96', type: 'int96' },
    ],
  },
  {
    stateMutability: 'pure',
    type: 'function',
    inputs: [],
    name: 'getTypeId',
    outputs: [{ name: '', internalType: 'bytes32', type: 'bytes32' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
    ],
    name: 'govQEEnableForTorex',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'r', internalType: 'int96', type: 'int96' }],
    name: 'govQEUpdateTargetTotalEmissionRate',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
      { name: 'f', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'govQEUpdateTorexEmissionBoostFactor',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'newSuperBoringLogic',
        internalType: 'contract SuperBoring',
        type: 'address',
      },
      {
        name: 'newSleepPodLogic',
        internalType: 'contract SleepPod',
        type: 'address',
      },
      {
        name: 'newEmissionTreasuryLogic',
        internalType: 'contract EmissionTreasury',
        type: 'address',
      },
      {
        name: 'newDistributionFeeManagerLogic',
        internalType: 'contract DistributionFeeManager',
        type: 'address',
      },
    ],
    name: 'govUpdateLogic',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'increaseStake',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'owner', internalType: 'address', type: 'address' }],
    name: 'initialize',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
    ],
    name: 'isQEEnabledForTorex',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'trader', internalType: 'address', type: 'address' },
      { name: 'prevFlowRate', internalType: 'int96', type: 'int96' },
      { name: '', internalType: 'int96', type: 'int96' },
      { name: '', internalType: 'uint256', type: 'uint256' },
      { name: 'newFlowRate', internalType: 'int96', type: 'int96' },
      { name: '', internalType: 'uint256', type: 'uint256' },
      { name: 'userDataRaw', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'onInFlowChanged',
    outputs: [{ name: 'newFeeFlowRate', internalType: 'int96', type: 'int96' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: '',
        internalType: 'struct LiquidityMoveResult',
        type: 'tuple',
        components: [
          {
            name: 'durationSinceLastLME',
            internalType: 'uint256',
            type: 'uint256',
          },
          {
            name: 'twapSinceLastLME',
            internalType: 'uint256',
            type: 'uint256',
          },
          { name: 'inAmount', internalType: 'uint256', type: 'uint256' },
          { name: 'minOutAmount', internalType: 'uint256', type: 'uint256' },
          { name: 'outAmount', internalType: 'uint256', type: 'uint256' },
          { name: 'actualOutAmount', internalType: 'uint256', type: 'uint256' },
        ],
      },
    ],
    name: 'onLiquidityMoved',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'owner',
    outputs: [{ name: '', internalType: 'address', type: 'address' }],
  },
  {
    stateMutability: 'pure',
    type: 'function',
    inputs: [],
    name: 'proxiableUUID',
    outputs: [{ name: '', internalType: 'bytes32', type: 'bytes32' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [],
    name: 'renounceOwnership',
    outputs: [],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'sleepPodBeacon',
    outputs: [
      { name: '', internalType: 'contract UpgradeableBeacon', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'torexFactory',
    outputs: [
      { name: '', internalType: 'contract TorexFactory', type: 'address' },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'newOwner', internalType: 'address', type: 'address' }],
    name: 'transferOwnership',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'newAddress', internalType: 'address', type: 'address' }],
    name: 'updateCode',
    outputs: [],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'torex', internalType: 'contract ITorex', type: 'address' },
      { name: 'newStakedAmount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'updateStake',
    outputs: [],
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'uuid',
        internalType: 'bytes32',
        type: 'bytes32',
        indexed: false,
      },
      {
        name: 'codeAddress',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
    ],
    name: 'CodeUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'torex',
        internalType: 'contract ITorex',
        type: 'address',
        indexed: true,
      },
      {
        name: 'trader',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'prevDistributor',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'newDistributor',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'DistributorUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'torex',
        internalType: 'contract ITorex',
        type: 'address',
        indexed: true,
      },
      {
        name: 'emissionRate',
        internalType: 'int96',
        type: 'int96',
        indexed: false,
      },
      { name: 'q', internalType: 'uint256', type: 'uint256', indexed: false },
      {
        name: 'qqSum',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'EmissionUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      { name: 'version', internalType: 'uint8', type: 'uint8', indexed: false },
    ],
    name: 'Initialized',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'previousOwner',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'newOwner',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'OwnershipTransferred',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'torex',
        internalType: 'contract ITorex',
        type: 'address',
        indexed: true,
      },
      {
        name: 'traderPod',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'newTraderUnits',
        internalType: 'uint128',
        type: 'uint128',
        indexed: false,
      },
      {
        name: 'referrerPod',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'newReferralUnits',
        internalType: 'uint128',
        type: 'uint128',
        indexed: false,
      },
    ],
    name: 'ReferrerUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'staker',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'pod',
        internalType: 'contract SleepPod',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'SleepPodCreated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'torex',
        internalType: 'contract ITorex',
        type: 'address',
        indexed: true,
      },
      {
        name: 'staker',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'newStakedAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'StakeUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'targetTotalEmissionRate',
        internalType: 'int96',
        type: 'int96',
        indexed: false,
      },
    ],
    name: 'TargetTotalEmissionRateUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'torex',
        internalType: 'contract ITorex',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'TorexCreated',
  },
  { type: 'error', inputs: [], name: 'MINIMUM_STAKING_AMOUNT_REQUIRED' },
  { type: 'error', inputs: [], name: 'NO_SELF_REFERRAL' },
  { type: 'error', inputs: [], name: 'ONLY_REGISTERED_TOREX_ALLOWED' },
] as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0x8eee2a69423509b6ca2eeb11c78936fbf1b89824)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x37d607bd9dfff80acf37184c1f27e88388914262)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0xaca744453c178f3d651e06a3459e2f242aa01789)
 */
export const superBoringAddress = {
  10: '0x8EeE2a69423509B6cA2EEB11C78936Fbf1B89824',
  8453: '0x37D607BD9dfFf80acf37184c1F27E88388914262',
  42220: '0xAcA744453C178F3D651e06A3459E2F242aa01789',
} as const

/**
 * - [__View Contract on Op Mainnet Optimism Explorer__](https://explorer.optimism.io/address/0x8eee2a69423509b6ca2eeb11c78936fbf1b89824)
 * - [__View Contract on Base Basescan__](https://basescan.org/address/0x37d607bd9dfff80acf37184c1f27e88388914262)
 * - [__View Contract on Celo Celo Explorer__](https://explorer.celo.org/mainnet/address/0xaca744453c178f3d651e06a3459e2f242aa01789)
 */
export const superBoringConfig = {
  address: superBoringAddress,
  abi: superBoringABI,
} as const

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Torex
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

export const torexABI = [
  {
    stateMutability: 'nonpayable',
    type: 'constructor',
    inputs: [
      {
        name: 'config',
        internalType: 'struct Torex.Config',
        type: 'tuple',
        components: [
          {
            name: 'inToken',
            internalType: 'contract ISuperToken',
            type: 'address',
          },
          {
            name: 'outToken',
            internalType: 'contract ISuperToken',
            type: 'address',
          },
          {
            name: 'observer',
            internalType: 'contract ITwapObserver',
            type: 'address',
          },
          {
            name: 'discountFactor',
            internalType: 'DiscountFactor',
            type: 'uint256',
          },
          { name: 'twapScaler', internalType: 'Scaler', type: 'int256' },
          {
            name: 'outTokenDistributionPoolScaler',
            internalType: 'Scaler',
            type: 'int256',
          },
          {
            name: 'controller',
            internalType: 'contract ITorexController',
            type: 'address',
          },
          {
            name: 'controllerSafeCallbackGasLimit',
            internalType: 'uint256',
            type: 'uint256',
          },
          { name: 'maxAllowedFeePM', internalType: 'uint256', type: 'uint256' },
        ],
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'CFAV1_TYPE',
    outputs: [{ name: '', internalType: 'bytes32', type: 'bytes32' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'CONTROLLER_SAFE_CALLBACK_GAS_LIMIT',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'HOST',
    outputs: [
      { name: '', internalType: 'contract ISuperfluid', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'MAX_ALLOWED_FEE_PM',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'VERSION',
    outputs: [{ name: '', internalType: 'string', type: 'string' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'superToken',
        internalType: 'contract ISuperToken',
        type: 'address',
      },
      { name: 'agreementClass', internalType: 'address', type: 'address' },
      { name: '', internalType: 'bytes32', type: 'bytes32' },
      { name: 'agreementData', internalType: 'bytes', type: 'bytes' },
      { name: '', internalType: 'bytes', type: 'bytes' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'afterAgreementCreated',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'superToken',
        internalType: 'contract ISuperToken',
        type: 'address',
      },
      { name: 'agreementClass', internalType: 'address', type: 'address' },
      { name: '', internalType: 'bytes32', type: 'bytes32' },
      { name: 'agreementData', internalType: 'bytes', type: 'bytes' },
      { name: 'cbdata', internalType: 'bytes', type: 'bytes' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'afterAgreementTerminated',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      {
        name: 'superToken',
        internalType: 'contract ISuperToken',
        type: 'address',
      },
      { name: 'agreementClass', internalType: 'address', type: 'address' },
      { name: '', internalType: 'bytes32', type: 'bytes32' },
      { name: 'agreementData', internalType: 'bytes', type: 'bytes' },
      { name: 'cbdata', internalType: 'bytes', type: 'bytes' },
      { name: 'ctx', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'afterAgreementUpdated',
    outputs: [{ name: 'newCtx', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'pure',
    type: 'function',
    inputs: [
      { name: '', internalType: 'contract ISuperToken', type: 'address' },
      { name: '', internalType: 'address', type: 'address' },
      { name: '', internalType: 'bytes32', type: 'bytes32' },
      { name: '', internalType: 'bytes', type: 'bytes' },
      { name: '', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'beforeAgreementCreated',
    outputs: [{ name: '', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'superToken',
        internalType: 'contract ISuperToken',
        type: 'address',
      },
      { name: 'agreementClass', internalType: 'address', type: 'address' },
      { name: '', internalType: 'bytes32', type: 'bytes32' },
      { name: 'agreementData', internalType: 'bytes', type: 'bytes' },
      { name: '', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'beforeAgreementTerminated',
    outputs: [{ name: '', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'superToken',
        internalType: 'contract ISuperToken',
        type: 'address',
      },
      { name: 'agreementClass', internalType: 'address', type: 'address' },
      { name: '', internalType: 'bytes32', type: 'bytes32' },
      { name: 'agreementData', internalType: 'bytes', type: 'bytes' },
      { name: '', internalType: 'bytes', type: 'bytes' },
    ],
    name: 'beforeAgreementUpdated',
    outputs: [{ name: '', internalType: 'bytes', type: 'bytes' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'controller',
    outputs: [
      { name: '', internalType: 'contract ITorexController', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'controllerInternalErrorCounter',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'debugCurrentDetails',
    outputs: [
      {
        name: 'requestedFeeDistFlowRate',
        internalType: 'int96',
        type: 'int96',
      },
      { name: 'actualFeeDistFlowRate', internalType: 'int96', type: 'int96' },
      { name: 'feeDistBuffer', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'flowRate', internalType: 'int96', type: 'int96' }],
    name: 'estimateApprovalRequired',
    outputs: [
      { name: 'requiredApproval', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'feeDistributionPool',
    outputs: [
      { name: '', internalType: 'contract ISuperfluidPool', type: 'address' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'inAmount', internalType: 'uint256', type: 'uint256' }],
    name: 'getBenchmarkQuote',
    outputs: [
      { name: 'minOutAmount', internalType: 'uint256', type: 'uint256' },
      {
        name: 'durationSinceLastLME',
        internalType: 'uint256',
        type: 'uint256',
      },
      { name: 'twapSinceLastLME', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getConfig',
    outputs: [
      {
        name: '',
        internalType: 'struct Torex.Config',
        type: 'tuple',
        components: [
          {
            name: 'inToken',
            internalType: 'contract ISuperToken',
            type: 'address',
          },
          {
            name: 'outToken',
            internalType: 'contract ISuperToken',
            type: 'address',
          },
          {
            name: 'observer',
            internalType: 'contract ITwapObserver',
            type: 'address',
          },
          {
            name: 'discountFactor',
            internalType: 'DiscountFactor',
            type: 'uint256',
          },
          { name: 'twapScaler', internalType: 'Scaler', type: 'int256' },
          {
            name: 'outTokenDistributionPoolScaler',
            internalType: 'Scaler',
            type: 'int256',
          },
          {
            name: 'controller',
            internalType: 'contract ITorexController',
            type: 'address',
          },
          {
            name: 'controllerSafeCallbackGasLimit',
            internalType: 'uint256',
            type: 'uint256',
          },
          { name: 'maxAllowedFeePM', internalType: 'uint256', type: 'uint256' },
        ],
      },
    ],
  },
  {
    stateMutability: 'pure',
    type: 'function',
    inputs: [
      { name: 'activateOnCreated', internalType: 'bool', type: 'bool' },
      { name: 'activateOnUpdated', internalType: 'bool', type: 'bool' },
      { name: 'activateOnDeleted', internalType: 'bool', type: 'bool' },
    ],
    name: 'getConfigWord',
    outputs: [{ name: 'configWord', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getDurationSinceLastLME',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getLiquidityEstimations',
    outputs: [
      { name: 'inAmount', internalType: 'uint256', type: 'uint256' },
      { name: 'minOutAmount', internalType: 'uint256', type: 'uint256' },
      {
        name: 'durationSinceLastLME',
        internalType: 'uint256',
        type: 'uint256',
      },
      { name: 'twapSinceLastLME', internalType: 'uint256', type: 'uint256' },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'getPairedTokens',
    outputs: [
      {
        name: 'inToken',
        internalType: 'contract ISuperToken',
        type: 'address',
      },
      {
        name: 'outToken',
        internalType: 'contract ISuperToken',
        type: 'address',
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [{ name: 'a', internalType: 'address', type: 'address' }],
    name: 'getTraderState',
    outputs: [
      {
        name: '',
        internalType: 'struct Torex.TraderState',
        type: 'tuple',
        components: [
          { name: 'contribFlowRate', internalType: 'int96', type: 'int96' },
          { name: 'feeFlowRate', internalType: 'int96', type: 'int96' },
        ],
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [
      {
        name: 'superToken',
        internalType: 'contract ISuperToken',
        type: 'address',
      },
    ],
    name: 'isAcceptedSuperToken',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [{ name: 'moverData', internalType: 'bytes', type: 'bytes' }],
    name: 'moveLiquidity',
    outputs: [
      {
        name: 'result',
        internalType: 'struct LiquidityMoveResult',
        type: 'tuple',
        components: [
          {
            name: 'durationSinceLastLME',
            internalType: 'uint256',
            type: 'uint256',
          },
          {
            name: 'twapSinceLastLME',
            internalType: 'uint256',
            type: 'uint256',
          },
          { name: 'inAmount', internalType: 'uint256', type: 'uint256' },
          { name: 'minOutAmount', internalType: 'uint256', type: 'uint256' },
          { name: 'outAmount', internalType: 'uint256', type: 'uint256' },
          { name: 'actualOutAmount', internalType: 'uint256', type: 'uint256' },
        ],
      },
    ],
  },
  {
    stateMutability: 'view',
    type: 'function',
    inputs: [],
    name: 'outTokenDistributionPool',
    outputs: [
      { name: '', internalType: 'contract ISuperfluidPool', type: 'address' },
    ],
  },
  {
    stateMutability: 'nonpayable',
    type: 'function',
    inputs: [
      { name: 'activateOnCreated', internalType: 'bool', type: 'bool' },
      { name: 'activateOnUpdated', internalType: 'bool', type: 'bool' },
      { name: 'activateOnDeleted', internalType: 'bool', type: 'bool' },
    ],
    name: 'selfRegister',
    outputs: [],
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      { name: 'reason', internalType: 'bytes', type: 'bytes', indexed: false },
    ],
    name: 'ControllerError',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'liquidityMover',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'durationSinceLastLME',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'twapSinceLastLME',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'inAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'minOutAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'outAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'actualOutAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'LiquidityMoved',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'sender',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'newFlowRate',
        internalType: 'int96',
        type: 'int96',
        indexed: false,
      },
      {
        name: 'newContribFlowRate',
        internalType: 'int96',
        type: 'int96',
        indexed: false,
      },
      {
        name: 'backAdjustment',
        internalType: 'int256',
        type: 'int256',
        indexed: false,
      },
      {
        name: 'requestedFeeDistFlowRate',
        internalType: 'int96',
        type: 'int96',
        indexed: false,
      },
      {
        name: 'actualFeeDistFlowRate',
        internalType: 'int96',
        type: 'int96',
        indexed: false,
      },
    ],
    name: 'TorexFlowUpdated',
  },
  { type: 'error', inputs: [], name: 'LIQUIDITY_MOVER_NO_SAME_BLOCK' },
  {
    type: 'error',
    inputs: [],
    name: 'LIQUIDITY_MOVER_SENT_INSUFFICIENT_OUT_TOKENS',
  },
  { type: 'error', inputs: [], name: 'NotAcceptedSuperToken' },
  { type: 'error', inputs: [], name: 'NotImplemented' },
  { type: 'error', inputs: [], name: 'UnauthorizedHost' },
] as const
