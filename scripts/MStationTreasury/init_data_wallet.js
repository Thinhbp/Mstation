const { getProxyAdminFactory } = require("@openzeppelin/hardhat-upgrades/dist/utils");
const hre = require("hardhat");
const Web3 = require("web3")


async function main() {
    //npx hardhat run scripts/MstationNFT/init_data.js --network bsc-testnet
    const MStationWallet = await hre.ethers.getContractFactory("MStationWallet");

    const mstationNFT = await MStationWallet.attach("0xB90CD6e33DA89FB7d5E3B027d97A27254E762c1A");//prod

    var mst = await mstationNFT.mstTokenAddress();
    console.log(mst)


  
    // console.log(mstationNFT);



    // await mstationNFT.claimBonusRewardNewest(a, 999,"0x206056a578c68235425b40e4bf98b72293371eefae979d4a2b162bce6d98e9493ebff429ee754aab7b1fad9ec6aec844a5351941ad3dc49890734809afd8391d1b");


    

    // await mstationNFT.setPause(false);//prod
    // // let rewardTokenAddress = await mstationNFT.rewardTokenAddress();//prod
    // // console.log("rewardTokenAddress " + rewardTokenAddress)

    // // let rewardWallet = await mstationNFT.rewardWallet();//prod
    // // console.log("rewardWallet " + rewardWallet)
    // await mstationNFT.updateAddressConfigs([0, 1], ["0xC86A9C449cb87E19675629681b8DC69d011bDc42", "0xC86A9C449cb87E19675629681b8DC69d011bDc42"]); // prod PvE Utils
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//
