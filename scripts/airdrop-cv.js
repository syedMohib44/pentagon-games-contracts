const fs = require("fs");

const ethers = require('ethers')

async function main() {
    const users = [
        "0x03ae56d44437f55db0847e57a13637a0e8659294",
        "0x842c0e3b89accfba0acf8328cfd34b26002ebeba",
        "0x5478e1cf9f8bc1159533069a7bafd5c5acebde0d",
        "0x01b23f8cc7fbf107b0f39aa0ba7c17ebafb5d618",
        "0xa8a1c00b1710b78c9b159204397cc4c919a6a6ae",
        "0xad1710272ce064dcd809b9dd0c8c41cc1d5a8834",
        "0x0921fcf6c2871b603797dd8fac562389b5128548",
        "0x17c86a053be74d9ea149111f2320798843b42512",
        "0x1b47a52ea3fd55f72ae025983d49379015dfba50",
        "0x21391ab4b084611bcc8a45d6e9ca15c48ed2c202",
        "0x217c4c1b054c93a67ad205f59a3204d1568e100e",
        "0x238e0fda86c410eb828d5492244d0ececf914c1e",
        "0x29019a3011b4e2e4a49f19bc318ec5011c71777a",
        "0x2a83dbd2ee0e3dbd32dc76edffb3a7808a2cd382",
        "0x2e1995d41acd3ce5d7e3edd2943592d152f6561c",
        "0x345540e2217c075b0f6c52f223cdad6b21aabb6a",
        "0x4e17c0d19b1fd0ac921c26c45038e28c8361d6e5",
        "0x5c86bae943450e9359e43435b958823c3116aa42",
        "0x6e28399aa9dd598caa49df9fa46d0ae87c0e7d57",
        "0x6e31094806a56531fea706eb9e18c7eba937f2a8",
        "0x72ffccda5b57b0827f52a3d93e57f44dcbc8d36d",
        "0x7a4077d3ea65873c92db2d0b2ea0e4d59fe0b41c",
        "0x85d2fd0bd49bb86f03cdd8bbeaa76581b9d05120",
        "0x87ff135235ee9d715beb0644e7f93cb5281a9963",
        "0x9a8f23391892cc9c2ef4fc4d40df16cad9feeca9",
        "0xa591c303e5b77f8d40c5d07914b38e21143344fc",
        "0xadfa946de4c29824cd28d75bf62c758984672991",
        "0xecb94ccf498abd6ca3ee766599c0301feff41b3f",
        "0x0aea2a1f84498c039fe727b5512728c933bed940",
        "0x1abddd9cad89bc1ae84963b85900ce67f5b942d5",
        "0x235fe016fb52b9f5df6a2f596d1e2ec86d15395d",
        "0x25f9d377bb0b04a8fa207805146cd4e448e8237c",
        "0x2771fb3ab80150a8724bbe5860370b28f6cdad10",
        "0x3664a96cba23bcabb65d70af9263c74ce6546605",
        "0x398856a04faa00cf067100e2cd92d5cf31a12855",
        "0x3f8d1b6247e434fa68adc516790f1923133974f5",
        "0x42d1daed8792429c3bc33f4eea6636ee4500b38e",
        "0x5351531dd5b93261113e7aea996be885ab283476",
        "0x587297c1eabd2cf89305595571eaf894b9f09964",
        "0x5eba77e16b28cf16b24caff3ed21631ee09c7d13",
        "0x6269515592433069b34799307ac57c9fed4ccec3",
        "0x64de364955ebd09208c57a6a349eca88c087167a",
        "0x6d0934ca4f374f386811161e79b6ff646d969097",
        "0x7019fdb327225a43c92f08ba55730164e0c42326",
        "0x7023378e9dd4ab0b1670bba2d008f74ce1b3ec39",
        "0x7361c08e005a0d29d9e774564c2418f3a5424008",
        "0x79c47eb036d903513aa20ecea516eb432cec6bc2",
        "0x8c811d63fbc39674810fccf56cdd6524cb3d6b58",
        "0x916deed04ebf981ad6878008a04e183913993a10",
        "0x98cbab753bd54017a9f7634dce389dc6a8e78780",
        "0xa2b5ab3536ae2c3aa715c2841fefd4233648c013",
        "0xa5c1bf37678199a6fcda44028b2bd2b4a2638605",
        "0xa66be0eae10d2b247167168c7e6f9e40a63047b1",
        "0xad60066a35d25a1eab0eadf7d4e8dc20159e8611",
        "0xb3f4b4038c8b6b0168b46b92f43b5f94d4708b45",
        "0xb9104f92418609b74cbbc063a1cc403321f95b33",
        "0xbe2739d0b4d2278edd4d0f3fd3caa48603a1119d",
        "0xc45bfedc1eec63a32566673d63b83a7cbfd7d3e4",
        "0xc4e5377b674b9ca91ec0c45c62749ee8eab431e2",
        "0xc4f73b9c0f2ee69b71c43318f255a398561e25f3",
        "0xc9683f2a9e50404d81c765c0242a7cca22174ac6",
        "0xcb3d9ebba84903ab98a58eb19dd92eba256aa2aa",
        "0xcd5554587ed7b6b1a2451c33998f24538aca5dd1",
        "0xd1fbfb554c2863a05f945faf35208ccdf7f1a47d",
        "0xd29f98e63900aa9117c990254e9c1ef2dd0f7c97",
        "0xd31f3c10a9f57850776b956016585fde4ee7f785",
        "0xd3880faade925643995f7000a4cfa54ffa651997",
        "0xdc18b363101c5833ec5c529d1de8c9824c706836",
        "0xdfddb4de776cd9c660832f33d60bd18ec4ee6216",
        "0xe6dc6fc3dd1e78dbd52cf774b3ddf99d6d6aba3f",
        "0xe7f2fe6d9098151db4a9e3329e8b06027e4c7b15",
        "0xf0c4edc40025bac2b2216840c9f447772fc4fa7d",
        "0xf30892deb3a4edb2aa3e7df3df64bf26d6a70d98",
        "0xf344633c0ff4d12aa24552ffe1b4474d0209a45e",
        "0xfb264ce1d67fd2f9c80c6034149685e7c1f718d1",
        "0xfd3439a2006c3ca909d432c126c03710535b5557",
        "0x109acbee08c02875aaed86bb25f5d0b6a3e3f88e",
        "0x47cab10c1634d5645ca28f8a65098ffcccee854e",
        "0x9522b3ebf21dbcb2e2b6aedb4fd8ddfe84843fba",
        "0xa95b9210205faaa4323f234aef7a6f463f03ab40",
        "0xbec7c60d54873dcc19ee371ddf7bc46015ac95d0",
        "0xc1f360b40c1a614b6e61d19ead99cf1695dfa27e",
        "0xc22f8bfb38e57e773d6058e33e676445a91c85fa",
        "0xcc9c43d4b5224b1a207bbcac70d29b49369bba6e",
        "0xd44c1280b64dad377cd66b189356f3d16cf79ab0",
        "0xd7f9d8978e2543b93be88928de794a61db80864c",
        "0x3cde038a1cbe34d0e85bcf09c6e3ed315f0fb7ea",
        "0xc77b4edc2c1f41d83b18a21637b2d6bb12504016",
        "0xaaae4ce2bc69520ae4d8826ff87be4ddc57a0987",
        "0xd112b87b4311b8f9a90c40154c9f7569e7cec1e2",
        "0xecadba74fb92d80720ede3ea3a41bb7e9d89716b",
        "0x59b20deacc8739999bd4a34bfa54b8b602577361",
        "0x1ac1c3f58379e92f4b3d752285966ade6c3a7858",
        "0x5e3be962576e8f47a07e9583b358802877f21c82",
        "0x82ccc4ae4d6298469cf3e4e4b825d2ce164088e0",
        "0x862420247cbc0aa630740d9cab832e7755062ca7",
        "0xc7dfe21245e10ced59874cd215de195eeb371cea",
        "0xd45788a7ebd1baa14da4d0059f9320a3a77dfcdb",
        "0xec496d888b7953157d5535b55abc86920d147a3c",
        "0xfa6e1f50adb5ab8f89b1a1e1afe1fdc99a6e936f",
        "0xd493f3b2c20029957d3dbd7ee83419819ce87dce",
        "0x0264540eb9e198dac6fb205171bcb2738aaed8db",
        "0x0298100e463a9330fad55108dcce1763cb2fc48f",
        "0x06874fb15ff2012a4a3740c1cbeeac93c24417a8",
        "0x07beb4afa0c313025bc5b63587fdca3d057163cd",
        "0x0a9f744429be2a7dec31c7a751ed08195adfd458",
        "0x0f9e9b314fc7b47bf9fe830f29a9571aabc11cff",
        "0x1247eb9db03e858043b6f813b5dcedf06a3666a5",
        "0x14200888c9b85b4f1e589de4be12e46916b7af31",
        "0x22dc0bd84e865280d221625418b102e10b690058",
        "0x29b4f89cb481f570f38f70599e400a38566720ed",
        "0x2a7e9c38ffcd5da32b60c837ff849b3189c6fcd4",
        "0x322268318985bb520f8b95486c75d74d321bf65d",
        "0x38f83a5a9ebc013256b3672759f647ba4998bfb6",
        "0x3e10553fff3a5ac28b9a7e7f4afafb4c1d6efc0b",
        "0x410b92c9e3f622e78ad222d667f01a95e0f60657",
        "0x436e6d2827e4331e87763469994e9b1acdf7a9e1",
        "0x49df227fb8d892a54d467806f341795ee3c563df",
        "0x5bef45489a03462d199612c5cd992f114f398ea8",
        "0x6e6986a4d12c30ed61c934f3b46d804152cccade",
        "0x740f92b0d92a40408b494b39cd0870d476f34c78",
        "0x75b25780aea907da4b9a849dde80ab37a9098a45",
        "0x771add5860f776dc6f1330585548f1bd5494f6ed",
        "0x861cb93bb097edd33e2d86c7088894aa100775db",
        "0x883feba76a64ddc002ed7994cf077a7834c32c77",
        "0x94b95685fadb551177ae45688d8aa0108769a0e4",
        "0x99559af00d2f43ce773b84316cce6f47c908f076",
        "0x99df7c89512c72ef13bd22d031e045c3389a36bf",
        "0x9c44d61d0eb36d734290ae21aa2ba71551d5906d",
        "0x9d9523e6b7efb624d6176778eeec0901c2519db2",
        "0xb1fe569478506aefec2bcc84321e8d2053fe3fbb",
        "0xbcf9c570343f263a8d5b8cdbce29fca35a9ccfe2",
        "0xc02388962e7425d19281cfe1572fd8df93a5acf2",
        "0xc4427b050286564ad63b85506f75941dc72b6dec",
        "0xcd17587e1d7089a07af941d2169db1cfdbb820c9",
        "0xd197d4fb841d5da0a30f37e78810a6cd199b49e0",
        "0xd38bf6e9f12f9d0d298a45e2f77626dc23ca27df",
        "0xd6a19b9c8ae7cc06687df5c3b8b024d1b52e7fd1",
        "0xd9fe94c8a0a9159d52683074a63acbf5fff1e379",
        "0xdc42f272a3bb0e10d3d2fba2f750694d6ff25bbf",
        "0xdd5730a33719083470e641cf0e4154dd04d5738d",
        "0xe5cf488f5ab168da372151cd37b442248f0b61da",
        "0xea9463232485f8deeb3dafab384a6d15c751e16e",
        "0xef03d5303484dbded196bc0e3cd7e88d7e72557e",
        "0xef07ca77b36fca9ebe055f230ef3f6271e409ea0",
        "0xf2048d821d663cfa7f8e9e18b98834cd94b4ad0e",
        "0xf2f6dbdb681026544b74c430f381b68a750bfb04",
        "0xf41f56e206bc63f7cc2d6ccd04a3b892ce33b69d",
    ]

    let current = users[0];
    // Replace with your contract's name and deployed address
    const contractName = "BCSH_Distributor"; // Your contract name
    const contractAddress = "0xBDf459b77d44Ef271d8Df7afd55B968FDF1dA645"; // Replace with your deployed address
    const contractABI = [{ "type": "constructor", "stateMutability": "nonpayable", "inputs": [{ "type": "address", "name": "_blockchainSuperheroes", "internalType": "address" }, { "type": "address", "name": "_cggToken", "internalType": "contract IERC20" }] }, { "type": "event", "name": "Mint", "inputs": [{ "type": "address", "name": "_owner", "internalType": "address", "indexed": false }, { "type": "uint256", "name": "token", "internalType": "uint256", "indexed": false }], "anonymous": false }, { "type": "event", "name": "OwnershipTransferred", "inputs": [{ "type": "address", "name": "previousOwner", "internalType": "address", "indexed": true }, { "type": "address", "name": "newOwner", "internalType": "address", "indexed": true }], "anonymous": false }, { "type": "fallback", "stateMutability": "payable" }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "AddModerator", "inputs": [{ "type": "address", "name": "_newModerator", "internalType": "address" }] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "UpdateMaintaining", "inputs": [{ "type": "bool", "name": "_isMaintaining", "internalType": "bool" }] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "bool", "name": "", "internalType": "bool" }], "name": "_mintingPaused", "inputs": [] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "bool", "name": "", "internalType": "bool" }], "name": "_mintingPausedCGG", "inputs": [] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "adminWithdrawERC20", "inputs": [{ "type": "address", "name": "_token", "internalType": "contract IERC20" }, { "type": "uint256", "name": "_amount", "internalType": "uint256" }] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "address", "name": "", "internalType": "address" }], "name": "blockchainSuperheroes", "inputs": [] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [{ "type": "bool", "name": "", "internalType": "bool" }], "name": "cggMint", "inputs": [{ "type": "uint256", "name": "_amount", "internalType": "uint256" }] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "uint256", "name": "", "internalType": "uint256" }], "name": "cggPriceNFT", "inputs": [] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "address", "name": "", "internalType": "contract IERC20" }], "name": "cggToken", "inputs": [] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "uint256", "name": "", "internalType": "uint256" }], "name": "getBalance", "inputs": [{ "type": "address", "name": "_owner", "internalType": "address" }] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "bool", "name": "", "internalType": "bool" }], "name": "isMaintaining", "inputs": [] }, { "type": "function", "stateMutability": "payable", "outputs": [{ "type": "bool", "name": "", "internalType": "bool" }], "name": "mint", "inputs": [] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [{ "type": "bool", "name": "", "internalType": "bool" }], "name": "mintTo", "inputs": [{ "type": "address", "name": "_owner", "internalType": "address" }] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "uint256", "name": "", "internalType": "uint256" }], "name": "mintingCap", "inputs": [] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "uint256", "name": "", "internalType": "uint256" }], "name": "mintingCount", "inputs": [] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "bool", "name": "", "internalType": "bool" }], "name": "moderators", "inputs": [{ "type": "address", "name": "", "internalType": "address" }] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "address", "name": "", "internalType": "address" }], "name": "owner", "inputs": [] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "renounceOwnership", "inputs": [] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "setContract", "inputs": [{ "type": "address", "name": "_blockchainSuperheroes", "internalType": "address" }, { "type": "address", "name": "_cggToken", "internalType": "contract IERC20" }] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "setMintingCap", "inputs": [{ "type": "uint256", "name": "_mintingCap", "internalType": "uint256" }] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "togglePause", "inputs": [] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "togglePauseCGG", "inputs": [] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "uint256", "name": "", "internalType": "uint256" }], "name": "tokenPrice", "inputs": [] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "uint16", "name": "", "internalType": "uint16" }], "name": "totalModerators", "inputs": [] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "transferOwnership", "inputs": [{ "type": "address", "name": "newOwner", "internalType": "address" }] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "updatePrice", "inputs": [{ "type": "uint256", "name": "_tokenPrice", "internalType": "uint256" }] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "updatePriceCGG", "inputs": [{ "type": "uint256", "name": "_cggPriceNFT", "internalType": "uint256" }] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "withdraw", "inputs": [] }, { "type": "receive", "stateMutability": "payable" }];

    // Get the signer (account) to interact with the contract
    try {

        const provider = new ethers.JsonRpcProvider("https://rpc.chainverse.info/");

        // Set up the contract ABI and address

        // Create a contract instance
        const privateKey = "b4e0936141cd4b29ebefa7144839fb01efb3763688057175bb150114c81dd678";  // Replace with your wallet's private key
        const wallet = new ethers.Wallet(privateKey, provider);
        const contract = new ethers.Contract(contractAddress, contractABI, wallet);

        // Attach to the deployed contract

        for (const user of users) {
            console.log('------------\n');
            const tx = await contract.mintTo(user);
            console.log(tx.hash);
            current = user;
            // const receipt = await tx.wait();
            // console.log("mined ", receipt);
            fs.appendFileSync('output.txt', `https://explorer.chainverse.info/tx/${tx.hash} \n`);
            await wait(1.5);
        }
    } catch (err) {
        console.log(`failed for ${current}, \n ------- \n ${err}`)
    }
}

async function wait(seconds) {
    return new Promise(resolve => setTimeout(resolve, seconds * 1000));
}

main().catch((error) => {
    console.error("Error:", error);
    process.exitCode = 1;
});
