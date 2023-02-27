const hre = require("hardhat");

//npx hardhat run scripts/ReferralBonus/upgrade_testnet.js --network bsc-testnet
async function main() {
    const ReferralBonus = await hre.ethers.getContractFactory("ReferralBonus");
    const address = "0xd384276648bE43BAC7749E56b75ff01A7fdd2A50";

    console.log("Upgrading ReferralBonus... " + address);
    const mstationNFT = await upgrades.upgradeProxy(address, ReferralBonus);
    await mstationNFT.deployed();

    console.log("ReferralBonus upgrade");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/ReferralBonus/upgrade.js --network mainnet
//npx hardhat verify --network bsc-testnet 0x2ca895eb79b38d830624ef26f0c33b4489c92a70