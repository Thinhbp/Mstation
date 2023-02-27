const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");

async function main() {
    //npx hardhat run scripts/MstationNFT/init_data.js --network bsc-testnet
    const MstationNFT = await hre.ethers.getContractFactory("MStation721");
    // const factory = "0x93B78f9f184413af78793aBc5DCcAD19c3711519"; //testnet
    const factory = "0xD37c14EADaB78Fb98a802324bD8dAd1f4d95504e"; //mainnet
    const mstationNFT = await MstationNFT.attach(factory);

    var fac = await mstationNFT.factory();
    console.log(fac)

}
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
    //npx hardhat run scripts/MStation721/init_data.js --network  bsc