const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");

async function main() {
    //npx hardhat run scripts/MstationNFT/deploy.js --network bsc-testnet
    const Stonemason = await hre.ethers.getContractFactory("MstationNFT");
    const mstation721 = await upgrades.deployProxy(Stonemason);
    await mstation721.deployed();

    console.log("MstationNFT deployed to:", mstation721.address);
    console.log("MstationNFT proxy deployed to:", Stonemason.address);

    try {
        const nftImplAddress = await getImplementationAddress(
            mstation721.provider,
            mstation721.address
        );
        await hre.run("verify:verify", { address: nftImplAddress });
        console.log("Stonemason verified to:", nftImplAddress);
    } catch (e) {

    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/MStation721/deploy.js --network mainnet