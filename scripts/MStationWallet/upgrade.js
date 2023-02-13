const hre = require("hardhat");

//npx hardhat run scripts/LFW721/upgrade.js --network bsc-testnet
//npx hardhat verify --network bsc-testnet 0xc83bdd3F97100Af7C1c091F3A5613549DabDA975
async function main() {
    const Wallet = await hre.ethers.getContractFactory("MStationWallet");
    // const lfw721Address = "0x92F5c075961b85e7dB7e8C0417f0189e59b8E3ee";
    // const lfw721Address = "0x61519b4B1516e99F779E0BC568C063B60a530DFf";
    // const Walletaddress = "0x94DBE090aC95d629d0c8E9272662fF2635f79206"; //testnet
    // const Walletaddress = "0xE729157B9FE5ED63d3C2D00617F60eF05456e430"; //staging
    const Walletaddress = "0xB90CD6e33DA89FB7d5E3B027d97A27254E762c1A"; //prod
    // const imp = "0x7cFf450829900e2E87E66ed9c5629C2765dF40e8"
    // await upgrades.forceImport(imp, Wallet, { kind: 'transparent' });

    console.log("Upgrading Wallet...");
    const lfw721 = await upgrades.upgradeProxy(Walletaddress, Wallet);
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