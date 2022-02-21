
const hre = require("hardhat");

async function main() {

  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  
  const Eggs = await hre.ethers.getContractFactory("Eggs");
  const eggs = await Eggs.deploy();

  try {
    await eggs.deployed();
  } catch (error) {
    console.log(error)
  }
  console.log("Eggs contract address: ", eggs.address);
  const eggsaddress = eggs.address;

  const Metadata = await hre.ethers.getContractFactory("Metadata");
  const metadata = await Metadata.deploy();

  await metadata.deployed();
  console.log("Metadata contract address: ", metadata.address);
  const metadataaddress = metadata.address;

  const Random = await hre.ethers.getContractFactory("Random");
  const random = await Random.deploy();

  await random.deployed();
  console.log("random contract address: ", random.address);
  const randaddress = random.address;

  const FoxHen = await hre.ethers.getContractFactory("FoxHen");
  const foxhen = await FoxHen.deploy(eggsaddress, randaddress, metadataaddress);

  await foxhen.deployed();

  console.log("FoxHen contract address: ", foxhen.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
