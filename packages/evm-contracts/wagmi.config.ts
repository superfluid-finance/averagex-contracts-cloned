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
                    [chains.celo.id]:
                        "0xe900226acd75ec9eb0b5b7504692486d7d23b9d3",
                },
                EmissionTreasury: {
                    [chains.celo.id]:
                        "0x1785d12f7aba1134552c136886814f6c5aac2b97",
                },
                DistributionFeeManager: {
                    [chains.celo.id]: "0xc19e31c910737C3A0F72b0526e491dDfB359fD7A",
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
                    [chains.celo.id]:
                        "0x6c210f071c7246c452cac7f8baa6da53907bbae1",
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
