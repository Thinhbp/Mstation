const hre = require("hardhat");
const { getImplementationAddress } = require("@openzeppelin/upgrades-core");

async function main() {
    //npx hardhat run scripts/MStation721/deploy.js --network bsc-testnet
    const factory = "0x93B78f9f184413af78793aBc5DCcAD19c3711519"

    const Stonemason = await hre.ethers.getContractFactory("Stonemason");
    const stonemason = await upgrades.deployProxy(Stonemason, [factory, "Stonemason", 2500, [30, 1, 45, 30, 30, 30], [80, 70, 100, 75, 85, 70]]);
    await stonemason.deployed();
    console.log("mstation721 deployed to:", stonemason.address);

    const gemCutter = await upgrades.deployProxy(Stonemason, [factory, "Gem Cutter", 2500, [30, 1, 45, 30, 30, 30], [80, 70, 100, 75, 85, 70]]);
    await gemCutter.deployed();
    console.log("gemCutter deployed to:", gemCutter.address);

    const Roboticist = await upgrades.deployProxy(Stonemason, [factory, "Roboticist", 6500, [30, 30, 30, 30, 1, 45], [80, 80, 80, 75, 70, 100]]);
    await Roboticist.deployed();
    console.log("Roboticist deployed to:", Roboticist.address);


    const BioEngineer = await upgrades.deployProxy(Stonemason, [factory, "Bio-Engineer", 6500, [1, 30, 30, 30, 30, 45], [70, 80, 80, 75, 80, 100]]);
    await BioEngineer.deployed();
    console.log("BioEngineer deployed to:", BioEngineer.address);

    const Spacecraft = await upgrades.deployProxy(Stonemason, [factory, "Spacecraft Engineer", 6500, [45, 1, 30, 30, 30, 30], [100, 70, 80, 75, 80, 80]]);
    await Spacecraft.deployed();
    console.log("Spacecraft deployed to:", Spacecraft.address);

    const Geologist = await upgrades.deployProxy(Stonemason, [factory, "Geologist", 6500, [20, 30, 1, 30, 45, 30], [80, 70, 70, 75, 100, 80]]);
    await Geologist.deployed();
    console.log("Geologist deployed to:", Geologist.address);

    const Hunter = await upgrades.deployProxy(Stonemason, [factory, "Hunter", 11500, [20, 30, 1, 30, 45, 30], [80, 70, 70, 75, 100, 80]]);
    await Hunter.deployed();
    console.log("Hunter deployed to:", Hunter.address);


    const Builder = await upgrades.deployProxy(Stonemason, [factory, "Builder", 11500, [45, 30, 30, 1, 45, 30], [100, 70, 70, 70, 80, 80]]);
    await Builder.deployed();
    console.log("Builder deployed to:", Builder.address);


    const Gunsmith = await upgrades.deployProxy(Stonemason, [factory, "Gunsmith", 11500, [20, 20, 1, 45, 30, 30], [80, 70, 70, 100, 75, 70]]);
    await Gunsmith.deployed();
    console.log("Gunsmith deployed to:", Gunsmith.address);

    const Miner = await upgrades.deployProxy(Stonemason, [factory, "Miner", 11500, [20, 20, 1, 45, 30, 40], [80, 70, 70, 100, 75, 100]]);
    await Miner.deployed();
    console.log("Miner deployed to:", Miner.address);


    const Foundryman = await upgrades.deployProxy(Stonemason, [factory, "Foundryman", 11500, [45, 20, 30, 45, 1, 20], [100, 70, 80, 100, 70, 70]]);
    await Foundryman.deployed();
    console.log("Foundryman deployed to:", Foundryman.address);


    const Chef = await upgrades.deployProxy(Stonemason, [factory, "Chef", 11500, [1, 45, 30, 45, 30, 20], [70, 70, 100, 70, 70, 70]]);
    await Chef.deployed();
    console.log("Chef deployed to:", Chef.address);



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
//npx hardhat run scripts/MStation721/deploy.js --network mainnet