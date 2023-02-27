const hre = require("hardhat")

const getMstationNFT = exports.getMstationNFT = async function () {
    const MstationNFT = await ethers.getContractFactory("MstationNFT");
    const contract = await upgrades.deployProxy(MstationNFT, []);
    await contract.deployed();
    return contract
}

const MstationMining = exports.MstationMining = async function () {
    const MstationNFT = await ethers.getContractFactory("MstationMining");
    const contract = await upgrades.deployProxy(MstationNFT, []);
    await contract.deployed();
    return contract
}

const getERC20Token = exports.getERC20Token = async function () {
    const BSCD = await ethers.getContractFactory("BSCS");
    const token = await upgrades.deployProxy(BSCD, []);
    await token.deployed();
    return token
}

const getBSCDToken = exports.getBSCDToken = async function () {
    const BSCD = await ethers.getContractFactory("BSCD");
    const token = await upgrades.deployProxy(BSCD, []);
    await token.deployed();
    return token
}

const getNFTContract = exports.getNFTContract = async function (factory, name, rarity, minValues, maxValues) {
    const Stonemason = await ethers.getContractFactory("Stonemason");
    const token = await upgrades.deployProxy(Stonemason, [factory.address, name, rarity, minValues, maxValues]);
    await token.deployed();
    return token
}

// const getNFTContractGemCutter = exports.getNFTContractGemCutter = async function (factory) {
//     const Stonemason = await ethers.getContractFactory("GemCutter");
//     const token = await upgrades.deployProxy(Stonemason, [factory.address]);
//     await token.deployed();
//     return token
// }


// const getNFTContractRoboticist = exports.getNFTContractRoboticist = async function (factory) {
//     const Stonemason = await ethers.getContractFactory("Roboticist");
//     const token = await upgrades.deployProxy(Stonemason, [factory.address]);
//     await token.deployed();
//     return token
// }
