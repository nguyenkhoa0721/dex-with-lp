import { ethers } from "hardhat";
async function main() {
    const Gold = await ethers.getContractFactory("Gold");
    const gold = await Gold.attach("0x667E5550210B2b8AC314c400744aC1980C4dAeB5");
    await gold.approve("0xe00EF38E56717bF5b74B32E18a69e3Eb3C39E7A9", 1000);

    const Dex = await ethers.getContractFactory("Exchange");
    const dex = await Dex.attach("0xe00EF38E56717bF5b74B32E18a69e3Eb3C39E7A9");
    await dex.addLiquidity(100, {
        value: ethers.utils.parseEther("0.0001"),
    });

    await dex.tokenSwapToEth(150, 0);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
