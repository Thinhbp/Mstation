const { getProxyAdminFactory } = require("@openzeppelin/hardhat-upgrades/dist/utils");
const hre = require("hardhat");
const Web3 = require("web3")


async function main() {
    //npx hardhat run scripts/MstationNFT/init_data.js --network bsc-testnet
    const MStationWallet = await hre.ethers.getContractFactory("MStationWallet");
    // await mstationNFT.setWhitelistOperator(["0x766d0466cb3Dca2D53C9aF264222c35d7C8601e5"], true);//staging
    const mstationNFT = await MStationWallet.attach("0xB90CD6e33DA89FB7d5E3B027d97A27254E762c1A");//prod
    // const mstationNFT = await ReferralBonus.attach("0x53379FcdA9CBb5735E6D80756F04414246ecD0aa");//stag
    // const mstationNFT = await ReferralBonus.attach("0xd384276648be43bac7749e56b75ff01a7fdd2a50");//test
    // await mstationNFT.setRewardTokenAddress("0xe7Af3fcC9cB79243f76947402117D98918Bd88Ea");//prod
    // await mstationNFT.setWhitelistOperator(["0x0db924B7E8D6cfe82E7fD1cE8fF54d75008Ac7f9"], true);//prod
    // await mstationNFT.setWhitelistOperator(["0x766d0466cb3Dca2D53C9aF264222c35d7C8601e5"], true);//test
    // await mstationNFT.setRewardTokenWalletAddress("0x31c56234ddb209ea13519396F71301859c98E5D3");//prod
    const amount  = Web3.utils.toWei('2000', 'ether');

    // const ow  = await mstationNFT.owner();
    // console.log(ow);
    // console.log(mstationNFT);

    // await mstationNFT.setLimitClaim(amount);

    // var check = await mstationNFT.whitelistOperator("0x3668D98F1DB7311b667593D5A276A73F6fc68923");
    // console.log(check)

    // var sig = "0xd948bbc307354f7e5d9c5982e4df5b88b894caf2bdbf807601d58db13dc7fefa670e8e2daf14cf4c7aae7ef62efda961bd21a092286fbbfa51fd85284e8b5f3b1c"
    // var claimID = 622852
    // var _tokenAddress = "0x193b54A74aF245B4fB624e72f12d4deCdd242004"
    // var _createTime = 1671431448
    //  await mstationNFT.withdrawTokenOffchainNewest(_tokenAddress,amount,claimID,  _createTime, sig)
    // console.log(add)
    // console.log("bscs")
    // var mst = await mstationNFT.mstTokenAddress()
    // console.log(mst)

    // console.log("bscd")
    // var bscd = await mstationNFT.bscsTokenAddress()
    // console.log(bscd)
    // var maxamount = Web3.utils.toWei('50000', 'ether');

    // var maxbscd = Web3.utils.toWei('1000000', 'ether');
    // await mstationNFT.setmaxAmount(maxamount, maxbscd);

    var maxbscs = await mstationNFT.maxAmount();
    var maxbscd = await mstationNFT.maxBSCD();

    console.log(maxbscs  );
    console.log(maxbscd  );



    // var limit  = await mstationNFT.limitAmount();
    // console.log(limit);
    // const feeWallet = "0xEDc7fd964385eE96b8E2447e2D0e9Fd8DECAd300";
    // await mstationNFT.setFeeAddress(feeWallet)



    // var MSTnew = "0x4171Bccc0DB94976DCeE9875e8a6754fDc7E1A8F";
    // await mstationNFT.setRewardTokenAddress(MSTnew);

    // var check= await mstationNFT.whitelistOperator("0x0db924B7E8D6cfe82E7fD1cE8fF54d75008Ac7f9");
    // console.log(check)
    // var rewardWallet = await mstationNFT.rewardWallet();
    // console.log(rewardWallet);

    // var mstnew = "0x271F9561a5B496F775a0D008816D691592F18dBf";
    // await mstationNFT.setRewardTokenAddress(mstnew)

 
   
    // await mstationNFT.setLimitClaim(BigInt(5000))

    // console.log(mstationNFT)
    // var a  = Web3.utils.toWei('35', 'ether');
    // console.log(amount - a);
    // var bscs = "0x49a766F4f29F8c512858B245C618F6B0d185c048" //Test
    // var bscd = "0x193b54A74aF245B4fB624e72f12d4deCdd242004"; //Test

    // var bscs = "0xbcb24AFb019BE7E93EA9C43B7E22Bb55D5B7f45D" //Prod
    // var bscd = "0xe0387845F8289fD5875e7193064392e061f46E58"; //Prod
    // await mstationNFT.setTokenAddress(bscs,bscd)
   

    // await mstationNFT.claimBonusRewardNewest(a, 999,"0x206056a578c68235425b40e4bf98b72293371eefae979d4a2b162bce6d98e9493ebff429ee754aab7b1fad9ec6aec844a5351941ad3dc49890734809afd8391d1b");


    

    // await mstationNFT.setPause(false);//prod
    // // let rewardTokenAddress = await mstationNFT.rewardTokenAddress();//prod
    // // console.log("rewardTokenAddress " + rewardTokenAddress)

    // // let rewardWallet = await mstationNFT.rewardWallet();//prod
    // // console.log("rewardWallet " + rewardWallet)
    // await mstationNFT.updateAddressConfigs([0, 1], ["0xC86A9C449cb87E19675629681b8DC69d011bDc42", "0xC86A9C449cb87E19675629681b8DC69d011bDc42"]); // test PvE Utils
    // await mstationNFT.updateAddressConfigs([0, 1], ["0xE110f603D6468d02085b73a8E8995195c521E8eC", "0xf086642A6f854bcd53773E8E91F2D611Ad1888e8"]); // prod PvE Utils
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/ReferralBonus/init_data.js --network bsc-mainnet