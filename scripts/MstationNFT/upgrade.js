const hre = require("hardhat");

//npx hardhat run scripts/MstationNFT/upgrade.js --network bsc-testnet
//npx hardhat verify --network bsc-testnet 0xc83bdd3F97100Af7C1c091F3A5613549DabDA975
async function main() {
    const BaseMStationNFT = await hre.ethers.getContractFactory("MstationNFT");
    const lfw721AddressProduction = "0x93B78f9f184413af78793aBc5DCcAD19c3711519"; //Testnet

    console.log("Upgrading MstationNFT...");
    const mstationNFT = await upgrades.upgradeProxy(lfw721AddressProduction, BaseMStationNFT);
    await mstationNFT.deployed();

    console.log("MstationNFT upgrade");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/MstationNFT/upgrade.js --network mainnet
//npx hardhat verify --network mainnet 0x379a837a589DE7Ac8d5c81289C230234f77FDe89