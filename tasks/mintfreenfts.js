const ethers = require("ethers");
require("dotenv").config();

const ABI = require("../artifacts/contracts/FoxHen.sol/FoxHen.json");

async function main() {

    let signer = new ethers.Wallet(`0x${process.env.AURORA_PRIVATE_KEY}`)
    const _provider = new ethers.providers.JsonRpcProvider("https://testnet.aurora.dev");
    const _signer = await signer.connect(_provider);

    const contract = new ethers.Contract(
        "0x3D4022B7dD2CdE02d78907af72F3f761A05e5489",
        ABI.abi,
        _signer
    );
    // await contract.toggleMainSale();
    // let txn = await contract.freeMint(2);
    // let receipt = await txn.wait();
    // console.log(receipt);

    let nfts = await contract.allTokensOfOwner("0xdada02a3d4cC4468F230c06FEF6C92eF182CF048");
    console.log(nfts);
}

function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}
main();