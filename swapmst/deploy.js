const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");

async function main() {
    const mst = "0x7eC4cea34221A7Fc0FAFd0298d7ae15d5E31130A";
    const bscs = "0x49a766F4f29F8c512858B245C618F6B0d185c048";
    const rateSwap = 10

    const swapToken = await hre.ethers.getContractFactory("SwapMST");
    const SwapToken = await swapToken.deploy(mst, bscs, rateSwap);
    

   
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
