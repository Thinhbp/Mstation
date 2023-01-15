const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");

async function main() {

    const swapToken = await hre.ethers.getContractFactory("SwapMST");
    const SwapToken = await swapToken.deploy();

   
    await SwapToken.deployed();

    console.log("swapToken deployed to:", SwapToken.address);



}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/swap/deploy.js --network bsc-mainnet
