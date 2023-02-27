const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");

async function main() {

    const tokenOKC = await hre.ethers.getContractFactory("tokenOKC");
    const TokenOKC = await upgrades.deployProxy(tokenOKC);
    await TokenOKC.deployed();

    console.log("TokenOKC deployed to:", TokenOKC.address);
    console.log("TokenOKC proxy deployed to:", TokenOKC.address);

    try {
        const Tokenaddress = await getImplementationAddress(
            TokenOKC.provider,
            TokenOKC.address
        );
        await hre.run("verify:verify", { address: Tokenaddress  });
        console.log("Stonemason verified to:", Tokenaddress );
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