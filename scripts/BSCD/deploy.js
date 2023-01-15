const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");

async function main() {
    //npx hardhat run scripts/BSCD/deploy.js --network bsc-testnet
    const BSCD = await hre.ethers.getContractFactory("BSCD");
    const stonemason = await upgrades.deployProxy(BSCD);
    await stonemason.deployed();
    console.log("BSCD deployed to:", stonemason.address);

    try {
        const nftImplAddress = await getImplementationAddress(
            stonemason.provider,
            stonemason.address
        );
        await hre.run("verify:verify", { address: nftImplAddress });
        console.log("BSCD verified to:", nftImplAddress);
    } catch (e) {

    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/BSCD/deploy.js --network mainnet