const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");
const Web3 = require("web3")


async function main() {
    //npx hardhat run scripts/MstationNFT/init_data.js --network bsc-testnet
    const BSCD = await hre.ethers.getContractFactory("BSCD");
    const factory = "0x54abfa09e61f7eBaCAD204DEF8647c0d29002e12"; //testnet
    // const factory = "0xD37c14EADaB78Fb98a802324bD8dAd1f4d95504e"; //mainnet
    const bscd = await BSCD.attach(factory);
    // const amount  = Web3.utils.toWei('5000000', 'ether');
    // var ad1 = "0x681a42397935802578aD8D2E1bc4a4EB9A96a9cA"
    // await bscd.claimReward(ad1,amount)

    // var owner = "0xf8D6cBd7c3bee733C0AF70171DBFf21d932c99c2";
    // await bscd.gra
    console.log(bscd)


}
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
    //npx hardhat run scripts/MStation721/init_data.js --network  bsc