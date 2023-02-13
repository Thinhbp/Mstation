const hre = require("hardhat");
const Web3 = require("web3")
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");

async function main() {

    const SwapMST = await hre.ethers.getContractFactory("SwapMST");
    const swapMST = await SwapMST.attach("0xDB45b3Fe522f106Aa2dBDB2Bc26ea8e34ed6dd25");//main  
    // var add = "0x10505818AFDB5fA60862e1D771a84E8164Dd9D49"
    // var addtoken = "0x4171Bccc0DB94976DCeE9875e8a6754fDc7E1A8F"
    // const amount  = Web3.utils.toWei('500', 'ether');
    // await swapMST.swap(amount);
    // var ow = await swapMST.owner();
    // console.log(ow)

    // await swapMST.swap();

    const token = "0x49a766F4f29F8c512858B245C618F6B0d185c048";
    const vaut = "0xf8D6cBd7c3bee733C0AF70171DBFf21d932c99c2"
    await swapMST.eWToken(token, vaut)




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