const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");

async function main() {

    const mst = await hre.ethers.getContractFactory("tokenMst");
    const Mst = await mst.deploy();
    

   
    await Mst.deployed();

    console.log("swapToken deployed to:", Mst.address);



}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/swap/deploy.js --network bsc-mainnet
