const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");
const Web3 = require("web3")

async function main() {

    const tokenOKC = await hre.ethers.getContractFactory("tokenOKC");
    const TokenOKC = await tokenOKC.attach("0xd715EF702eA8e0708bC469277f0aB5d2f1d5ea39");//test
    var add = "0x10505818AFDB5fA60862e1D771a84E8164Dd9D49";
    const amount  = Web3.utils.toWei('5000', 'ether');

    await TokenOKC.mintToken(amount, add);
    // var bl = await TokenOKC.balanceOf(add);
    // console.log(TokenOKC);



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