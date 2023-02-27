const hre = require('hardhat');

async function main() {
    const LFW1155 = await hre.ethers.getContractFactory('LFW1155');
    const lfw1155AddressDev = "0x8427f72822e78c8be338DD0576803B760b686Dc2";
    // const lfw1155AddressDev = "0xb0a581ba9E044a3B63A708cDB7c3a1C7A57623F6";//Hoang dev local
    console.log('Upgrading LFW1155...');
    const lfw1155 = await upgrades.upgradeProxy(
        lfw1155AddressDev,
        LFW1155
    );
    await lfw1155.deployed();

    console.log('lfw1155 upgrade');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
