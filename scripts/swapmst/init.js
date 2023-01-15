const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");

async function main() {

    const SwapMST = await hre.ethers.getContractFactory("SwapMST");
    const swapMST = await SwapMST.attach("0xed29d8787646dDd615B02Fc408c3F38521107357");//main  
    // var add = "0x10505818AFDB5fA60862e1D771a84E8164Dd9D49"
    // var addtoken = "0x4171Bccc0DB94976DCeE9875e8a6754fDc7E1A8F"
    // await swapMST.eWToken(addtoken, add);
    var ow = await swapMST.owner();
    console.log(ow)

    // await swapMST.swap();




}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/swapmst/init.js --network bsc
// staging: 0x53379FcdA9CBb5735E6D80756F04414246ecD0aa
// prod: 