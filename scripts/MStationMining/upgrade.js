const hre = require('hardhat');

async function main() {
    //npx hardhat run scripts/LFWGameFiNFT/upgrade.js --network bsc-testnet
    //npx hardhat verify --network bsc-testnet 0x18b664d475cf3d15aE205517CEC05eb39d927C29 // testnet with gamefi
    // const marketplaceProxyAddressDev = "0x5642136510cd74788A4493f8b30A72F3d088b9db";// Testnet for self
    const marketplaceProxyAddressDev = "0x040475909ff35Be502B888722268dE2bD558d60C";// Testnet gamefi
    const LFWGameFiNFT = await hre.ethers.getContractFactory('LFWGameFiNFT');
    console.log('Upgrading LFWGameFiNFT...');
    const factory = await upgrades.upgradeProxy(
        marketplaceProxyAddressDev,
        LFWGameFiNFT
    );
    await factory.deployed();

    console.log('LFWGameFiNFT upgraded');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
