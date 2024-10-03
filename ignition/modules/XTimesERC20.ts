import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const XTimesERC20Module = buildModule("XTimesERC20Module", (builder) => {
    const xtimes = builder.contract("XTimesERC20")

    return { xtimes };
})

export default XTimesERC20Module;
