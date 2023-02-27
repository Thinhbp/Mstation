const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");
const Web3 = require("web3")

async function main() {
    //npx hardhat run scripts/MstationNFT/init_data.js --network bsc-testnet
    const MstationNFT = await hre.ethers.getContractFactory("MstationNFT");
    const factory = "0x93B78f9f184413af78793aBc5DCcAD19c3711519"; //testnet
    // const factory = "0x875f67f4142E1c97184cE4fb6706c355381c2323"; //mainnet

    // const stonemason = "0xb0A3889032785c1c88Fe77A99097D7D7e888c951"
    // const gemCutter = "0xe227A8C9C7aEF57040B7dc1148307FF12fE55D7C"
    // const Roboticist = "0xcB7f6d8FBe800944CA86DA835583a8ee9F170f1a"
    // const BioEngineer = "0x9a892D215919C0df053683f09b1C60C1237155dC"
    // const Spacecraft = "0x7D2642F56A11c373e0aB06638E2fD654e67B7f47"
    // const Geologist = "0x41f959dD5c141DE219940Cc4330D6025c081d9C9"
    // const Hunter = "0x29e26a1e54EAA03d7C3Ce141b18b6202C37eDD75"
    // const Builder = "0xE0aAC680EA45Aeb016CbDac139aF19F00551361A"
    // const Gunsmith = "0x01384049A38F94B8c4B6eFE32f3fAD1f3F8BEaeB"
    // const Miner = "0x8A95513019B5C6c2f41962DC718e185a744871e4"
    // const Foundryman = "0xb31b3dCff13D6ccab9E1544C421cDaAfE59C571E"
    // const Chef = "0xE067fadc285b952cB3B1f56B72663C5500850d78"

    // const NFTAddress = [stonemason, gemCutter, Roboticist, BioEngineer, Spacecraft, Geologist, Hunter, Builder,
    //     Gunsmith, Miner, Foundryman, Chef]

    const mstationNFT = await MstationNFT.attach(factory);
    // // await mstationNFT.updateRarity(NFTAddress, [2500, 2500, 6500, 6500, 6500, 6500, 11500, 11500, 11500, 11500, 11500, 11500]);
    const _initalSupply = 1000
    const _BSCDAddress = "0xb45D692dFB6513f7Dc8C013a951b0ae57A8Fb996"
    const _BSCSAddress = "0xBa748C1B44BaB28bFaacAF814A9f2fA3612572DC"
    const _burnWallet = "0x187D9dE4bcb90246E50650Fc5A591E2B35D19AC1"
    const treasuryAddress = "0x187D9dE4bcb90246E50650Fc5A591E2B35D19AC1"
    const _baseMintFee = "1000000000000000000";
    const _baseMintLimitedFee = "100000000000";
    const _tokenMintLimitedFee = 0;

    // await mstationNFT.initData(
    //     treasuryAddress,
    //     _burnWallet,
    //     _BSCSAddress,
    //     _BSCDAddress,
    //     _initalSupply,
    //     _baseMintFee,
    //     _baseMintLimitedFee,
    //     _tokenMintLimitedFee);
    // var referralAddress = "0xd384276648be43bac7749e56b75ff01a7fdd2a50";
    // var walletAddress = '0xe1c42eafcdea422dfc159cb748080ccdf41f0323';

    // var mstnew = "0x271F9561a5B496F775a0D008816D691592F18dBf";
    // await mstationNFT.updateToken(mstnew);


    // mstnew = await mstationNFT.bscsAddress();
    // console.log(mstnew);

    // // await mstationNFT.updateReferralAddress(referralAddress);
    // await mstationNFT.updateWalletAddress(walletAddress);

    // // await mstationNFT.Breed();
    // var bscdAddress = await mstationNFT.bscdAddress();
    // console.log("bscdAddress");
    // console.log(bscdAddress);

    // var bscsAddress = await mstationNFT.bscsAddress();
    // console.log("bscsAddress");
    // console.log(bscsAddress);

    // var busdAddress = await mstationNFT.busdAddress();
    // console.log("busdAddress");
    // console.log(busdAddress);

    var walletAddress = await mstationNFT.walletAddress();
    // console.log("walletAddress");
    // console.log(walletAddress);

    // var burnWallet = await mstationNFT.burnWallet();
    // console.log("burnWallet");
    // console.log(burnWallet);

    // var referralAddress = await mstationNFT.referralAddress();
    // console.log("referralAddress");
    // console.log(referralAddress);
    // var burnWallet = "0x43F99D650A53bb59f988756cadb2838843a5d7F3"
    // var referralAddress = "0xd384276648be43bac7749e56b75ff01a7fdd2a50"
    // var walletAddress =   "0xE1C42EaFCdeA422dfC159cB748080ccdf41F0323"
    // var bscs = ""
    const amount  = Web3.utils.toWei('0.001', 'ether');

    // await mstationNFT.BreedPack(1, { value:amount} );
    await mstationNFT.Claim(165719677276551);

    // var mstn;
    // mstn = await mstationNFT.bscsAddress();
    // console.log(mstn);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/MStationNFT/init_data.js --network bsc-testnet