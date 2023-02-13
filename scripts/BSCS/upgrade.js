const hre = require("hardhat");

//npx hardhat run scripts/LFW721/upgrade.js --network bsc-testnet
//npx hardhat verify --network bsc-testnet 0xc83bdd3F97100Af7C1c091F3A5613549DabDA975
async function main() {
    const BaseMStationNFT = await hre.ethers.getContractFactory("BaseMStationNFT");
    // const lfw721Address = "0x92F5c075961b85e7dB7e8C0417f0189e59b8E3ee";
    // const lfw721Address = "0x61519b4B1516e99F779E0BC568C063B60a530DFf";
    const lfw721AddressProduction = "0xD37c14EADaB78Fb98a802324bD8dAd1f4d95504e";

    console.log("Upgrading BaseMStationNFT...");
    const lfw721 = await upgrades.upgradeProxy(lfw721AddressProduction, BaseMStationNFT);
    await lfw721.deployed();

    console.log("LFW721 upgrade");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/LFW721/upgrade.js --network mainnet
//npx hardhat verify --network mainnet 0x379a837a589DE7Ac8d5c81289C230234f77FDe89