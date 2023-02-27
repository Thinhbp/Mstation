const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");

async function main() {
    //npx hardhat run scripts/BSCS/deploy.js --network bsc-testnet
    const BSCS = await hre.ethers.getContractFactory("BSCS");
    const stonemason = await upgrades.deployProxy(BSCS);
    await stonemason.deployed();
    console.log("BSCS deployed to:", stonemason.address);

    try {
        const nftImplAddress = await getImplementationAddress(
            stonemason.provider,
            stonemason.address
        );
        await hre.run("verify:verify", { address: nftImplAddress });
        console.log("BSCS verified to:", nftImplAddress);
    } catch (e) {

    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/BSCS/deploy.js --network mainnet