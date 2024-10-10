const hre = require("hardhat");

async function main() {
    NFT_NAME = "BlockChainSuperHeros"
    NFT_SYMBOL = "BCSH"
    Min_GasToTransfer = 260000
    LZ_ENDPOINT = "0x6EDCE65403992e310A62460808c4b910D972f10f"
    const [addr1] = await hre.ethers.getSigners();

    const bcshContract = await (await ethers.getContractFactory("Blockchain_Superheroes_Mint")).attach('0x616A5BDb2Be3b01B73FD60FEad901BB040ee7dFA');

    let trustedRemote = hre.ethers.utils.solidityPack(
        ['address', 'address'],
        ['0xA99994920e3dEc1A7CDF98D0120aa3fa58335d32', '0x616A5BDb2Be3b01B73FD60FEad901BB040ee7dFA'],
    );

    // await bcshContract.setTrustedRemote(40267, trustedRemote);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
