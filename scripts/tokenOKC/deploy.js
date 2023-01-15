const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");

async function main() {

    const tokenOKC = await hre.ethers.getContractFactory("tokenOKC");
    const TokenOKC = await tokenOKC.deploy();

   
    await TokenOKC.deployed();

    console.log("swapToken deployed to:", TokenOKC.address);



}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/swap/deploy.js --network bsc-mainnet
