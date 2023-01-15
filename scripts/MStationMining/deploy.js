const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");

async function main() {
    // We get the contract to deploy
    //npx hardhat run scripts/LFWGameFiNFT/deploy.js --network bsc-testnet
    //npx hardhat verify --network bsc-testnet 0x31FA1b99B93E4635f685c0014c94fC8DFF0D6399
    const LFWGameFiNFT = await hre.ethers.getContractFactory("LFWGameFiNFT");
    const lfwGameFiNFT = await upgrades.deployProxy(LFWGameFiNFT);
    await lfwGameFiNFT.deployed();

    console.log("LFWGameFiNFT deployed to:", lfwGameFiNFT.address);
    console.log("proxy deployed to:", LFWGameFiNFT.address);

    const nftImplAddress = await getImplementationAddress(
        lfwGameFiNFT.provider,
        lfwGameFiNFT.address
    );
    await hre.run("verify:verify", { address: nftImplAddress });

    console.log("verified contract:", nftImplAddress);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/LFWGameFiNFT/deploy.js --network mainnet