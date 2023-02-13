const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");

async function main() {

    const bscs = await hre.ethers.getContractFactory("tokenBSCS");
    const BSCS = await bscs.deploy();
    

   
    await BSCS.deployed();

    console.log("swapToken deployed to:", BSCS.address);



}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/swap/deploy.js --network bsc-mainnet
