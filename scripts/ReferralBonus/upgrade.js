const hre = require("hardhat");

//npx hardhat run scripts/ReferralBonus/upgrade.js --network bsc-testnet
//npx hardhat verify --network bsc-testnet 0xc83bdd3F97100Af7C1c091F3A5613549DabDA975
async function main() {
    const ReferralBonus_upgrade = await hre.ethers.getContractFactory("ReferralBonus");
    const addressProduction = "0x50d7c2Cc0fc686C1F9434Bd9Af78A1fB9293B211"; //prod
    // const addressProduction = "0x53379FcdA9CBb5735E6D80756F04414246ecD0aa"; //stag
    // const addressProduction = "0xd384276648be43bac7749e56b75ff01a7fdd2a50" // test
    const imp = "0x1b5e404d22B37Fe34306A8498d024e5a9f37EaA8"
    


    console.log("Upgrading ReferralBonus: " + addressProduction);
    // await upgrades.forceImport(imp, ReferralBonus_upgrade, { kind: 'transparent' });
    const mstationNFT = await upgrades.upgradeProxy(addressProduction, ReferralBonus_upgrade);
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
//npx hardhat run scripts/ReferralBonus/upgrade.js --network bsc-mainnet