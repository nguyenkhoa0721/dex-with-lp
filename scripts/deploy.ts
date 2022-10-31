import { ethers } from "hardhat";
async function main() {
    // const Gold = await ethers.getContractFactory("Gold");
    // const gold = await Gold.deploy();
    // await gold.deployed();

    // console.log(gold.address);

    const Dex = await ethers.getContractFactory("Exchange");
    const dex = await Dex.deploy("0x667e5550210b2b8ac314c400744ac1980c4daeb5");
    await dex.deployed();

    console.log(dex.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
