import { defineConfig } from "@wagmi/cli";
import type { Config } from "@wagmi/cli";
import { foundry } from "@wagmi/cli/plugins";
import metadata from "@superfluid-finance/metadata";
import * as chains from "viem/chains";
import { zeroAddress } from "viem";

const config = defineConfig({
    out: "index.ts",

    plugins: [
        foundry({
            deployments: {
                SuperBoring: {
                    [chains.base.id]: "0x37d607bd9dfff80acf37184c1f27e88388914262",
                    [chains.celo.id]: "0xaca744453c178f3d651e06a3459e2f242aa01789",
                },
                EmissionTreasury: {
                    [chains.base.id]: "0x14a201a50b3ffc7ca9851dd137aa47ff33924025",
                    [chains.celo.id]: "0x89795bb9aed5fa4c5c91815bb28db790ea7933c9",
                },
                DistributionFeeManager: {
                    [chains.base.id]: "0xfdad7082c6d2e07dd232be252bfd65841ea1c83c",
                    [chains.celo.id]: "0x750c3e12f26a998244ca9c95d300cc20f4dfb485",
                },
                ISuperfluid: {
                    ...metadata.networks.reduce(
                        (acc, curr) => ({
                            ...acc,
                            [curr.chainId]:
                                curr.contractsV1.host ?? zeroAddress,
                        }),
                        {}
                    ),
                },
                ISuperToken: {
                    // Reward Token
                    [chains.base.id]: "0x2112b92a4f6496b7b2f10850857ffa270464d054",
                    [chains.celo.id]: "0x6c210f071c7246c452cac7f8baa6da53907bbae1",
                },
                IConstantFlowAgreementV1: {
                    ...metadata.networks.reduce(
                        (acc, curr) => ({
                            ...acc,
                            [curr.chainId]:
                                curr.contractsV1.cfaV1 ?? zeroAddress,
                        }),
                        {}
                    ),
                },
                CFAv1Forwarder: {
                    ...metadata.networks.reduce(
                        (acc, curr) => ({
                            ...acc,
                            [curr.chainId]:
                                curr.contractsV1.cfaV1Forwarder ?? zeroAddress,
                        }),
                        {}
                    ),
                },
                IGeneralDistributionAgreementV1: {
                    ...metadata.networks.reduce(
                        (acc, curr) => ({
                            ...acc,
                            [curr.chainId]:
                                curr.contractsV1.gdaV1 ?? zeroAddress,
                        }),
                        {}
                    ),
                },
                GDAv1Forwarder: {
                    ...metadata.networks.reduce(
                        (acc, curr) => ({
                            ...acc,
                            [curr.chainId]:
                                curr.contractsV1.gdaV1Forwarder ?? zeroAddress,
                        }),
                        {}
                    ),
                },
            },
            forge: {
                clean: true,
                build: true,
                rebuild: true,
            },
            artifacts: "./out",
            include: [
                "SuperBoring.sol/SuperBoring.json",
                "EmissionTreasury.sol/EmissionTreasury.json",
                "DistributionFeeManager.sol/DistributionFeeManager.json",
                "IConstantFlowAgreementV1.sol/IConstantFlowAgreementV1.json",
                "CFAv1Forwarder.sol/CFAv1Forwarder.json",
                "IGeneralDistributionAgreementV1.sol/IGeneralDistributionAgreementV1.json",
                "GDAv1Forwarder.sol/GDAv1Forwarder.json",
                "ISuperfluid.sol/ISuperfluid.json",
                "ISuperToken.sol/ISuperToken.json",
                "IERC20.sol/IERC20.json",
                "ISETH.sol/ISETH.json",
                "ISuperfluidPool.sol/ISuperfluidPool.json",
                "Torex.sol/Torex.json",
            ],
        }),
    ],
}) as Config;

export default config;
