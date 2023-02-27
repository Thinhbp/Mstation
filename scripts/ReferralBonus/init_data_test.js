const hre = require("hardhat");


async function main() {
    //npx hardhat run scripts/ReferralBonus/init_data_test.js --network bsc-testnet
    const ReferralBonus = await hre.ethers.getContractFactory("ReferralBonus");
    const mstationNFT = await ReferralBonus.attach("0xd384276648bE43BAC7749E56b75ff01A7fdd2A50");

    for (let i = 0; i < 1; i++) {
        await mstationNFT.claimBonusReward("20000000000000000000", 1, "0xf0678ba52131a5d431907737c29b640cb8be6df0be3c112dc66c2d1a045ea57d348c5d068cc27d83954fe10f605519c3daeed57e86a2c37c3b19df8b55eba2b11c");
    }
    // await mstationNFT.setRewardTokenAddress("0xb63ba924bdef8d6b4a60bc272ee3af3dc5d08511");
    // await mstationNFT.setWhitelistOperator(["0x766d0466cb3Dca2D53C9aF264222c35d7C8601e5"], true);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
//npx hardhat run scripts/ReferralBonus/deploy.js --network mainnet