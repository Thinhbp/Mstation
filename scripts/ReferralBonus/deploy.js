const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");

async function main() {
    //npx hardhat run scripts/ReferralBonus/deploy.js --network bsc-testnet
    // function initialize(uint256 _rewardPerInvitation, address _rewardTokenAddress, address _rewardWallet)
    const ReferralBonus = await hre.ethers.getContractFactory("ReferralBonus");
    // testnet
    const mstation721 = await upgrades.deployProxy(ReferralBonus, ["20000000000000000000", "0xb63ba924bdef8d6b4a60bc272ee3af3dc5d08511", "0x2a7872FD9ed13B04E766079647491dfD63db7F51"]);
    // staging-mainnet
    // const mstation721 = await upgrades.deployProxy(ReferralBonus, ["3500000000000000000", "0x7D58919383349D631D2Da93A01CcB570EB80dB8d", "0xa419535152b86E06DDa178790De28Fb4e4a76642", "0xe57466Fe09a8E198bCB73Db885d116a81c2775E7"]);
    await mstation721.deployed();

    console.log("ReferralBonus deployed to:", mstation721.address);
    console.log("ReferralBonus proxy deployed to:", ReferralBonus.address);

    // try {
    //     const nftImplAddress = await getImplementationAddress(
    //         mstation721.provider,
    //         mstation721.address
    //     );
    //     await hre.run("verify:verify", { address: nftImplAddress });
    //     console.log("Stonemason verified to:", nftImplAddress);
    // } catch (e) {

    // }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/ReferralBonus/deploy.js --network bsc-mainnet
// staging: 0x53379FcdA9CBb5735E6D80756F04414246ecD0aa
// prod: 