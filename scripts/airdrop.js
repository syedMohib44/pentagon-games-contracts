const fs = require("fs");

const hre = require("hardhat");

async function main() {
    const users = [
        "0xefea641b0caf7673ae440f3da0eac7839115f6ff",
        "0xc45bfedc1eec63a32566673d63b83a7cbfd7d3e4",
        "0xa6eb732645a0ff24956a2106c18e95c3040826a4",
        "0x29b4f89cb481f570f38f70599e400a38566720ed",
        "0x99df7c89512c72ef13bd22d031e045c3389a36bf",
        "0xa9294a934d7cbdaf228a57e1b9cbfb3d10274240",
        "0x63e6e51f173f1bc9268b96a981a8b5dd8cbc682c",
        "0x6e6986a4d12c30ed61c934f3b46d804152cccade",
        "0xcd1f8dc2d7f53157ede982f380197234016bc0d8",
        "0xb62aec7ee4f46a4e8e6928c37d50e8e1830fb382",
        "0x9a8f23391892cc9c2ef4fc4d40df16cad9feeca9",
        "0xcb8281d9a078fe877012fe3fceeb7e083060316d",
        "0xecb94ccf498abd6ca3ee766599c0301feff41b3f",
        "0x64de364955ebd09208c57a6a349eca88c087167a",
        "0x21391ab4b084611bcc8a45d6e9ca15c48ed2c202",
        "0xd276991f324b943ae4d0c5f2bfb8e1542c9916b5",
        "0x0921fcf6c2871b603797dd8fac562389b5128548",
        "0xbcdf8e152744b9f4a90420e5247ab6a075c9645f",
        "0xb678fe317b6806721ac06ab0c7c3b5d08e3fe214",
        "0x17c86a053be74d9ea149111f2320798843b42512",
        "0x12491a3eb61297128a47fe00cd94536ca1a0a520",
        "0x2e1995d41acd3ce5d7e3edd2943592d152f6561c",
        "0x7b0452bc2acb4742c606d3adef39756a3104e16a",
        "0x3511c66bf84ebcb01b57e6fd514ae4c86442e9ac",
        "0xf86e283fc5f1c4fe59e26f61a83a84039ac8d99d",
        "0xcc9c43d4b5224b1a207bbcac70d29b49369bba6e",
        "0xd92ab865224cb9bb8d434dfb7ed2ebf09f6905a1",
        "0xfa6e1f50adb5ab8f89b1a1e1afe1fdc99a6e936f",
        "0x238e0fda86c410eb828d5492244d0ececf914c1e",
        "0xf30892deb3a4edb2aa3e7df3df64bf26d6a70d98",
        "0x2a7e9c38ffcd5da32b60c837ff849b3189c6fcd4",
        "0x72ffccda5b57b0827f52a3d93e57f44dcbc8d36d",
        "0x8c811d63fbc39674810fccf56cdd6524cb3d6b58",
        "0x740f92b0d92a40408b494b39cd0870d476f34c78",
        "0x47cab10c1634d5645ca28f8a65098ffcccee854e",
        "0x85d2fd0bd49bb86f03cdd8bbeaa76581b9d05120",
        "0x6aaa2ad3b71e03c622febf63770adb705e25bfda",
        "0x217c4c1b054c93a67ad205f59a3204d1568e100e",
        "0x5c86bae943450e9359e43435b958823c3116aa42",
        "0x4e17c0d19b1fd0ac921c26c45038e28c8361d6e5",
        "0x7a4077d3ea65873c92db2d0b2ea0e4d59fe0b41c",
        "0x29019a3011b4e2e4a49f19bc318ec5011c71777a",
        "0x9d9523e6b7efb624d6176778eeec0901c2519db2",
        "0x37707451d7255b32e650886fc71dff5f3b39999b",
        "0x64630c57614a0dcd45aa686642c7ab4343462ec5",
        "0xc4957c37500345198c7e932bf37f5969d73cd449",
        "0x25fbea05b03bd33ece1f4488d7e9583a1c1ad521",
        "0xc1f360b40c1a614b6e61d19ead99cf1695dfa27e",
        "0xbec7c60d54873dcc19ee371ddf7bc46015ac95d0",
        "0xd7f9d8978e2543b93be88928de794a61db80864c",
        "0x9522b3ebf21dbcb2e2b6aedb4fd8ddfe84843fba",
        "0x5e4d4c4113e6d3a240402a172893eda5e00341c9",
        "0xc22f8bfb38e57e773d6058e33e676445a91c85fa",
        "0xd44c1280b64dad377cd66b189356f3d16cf79ab0",
        "0x109acbee08c02875aaed86bb25f5d0b6a3e3f88e",
        "0xa95b9210205faaa4323f234aef7a6f463f03ab40",
        "0xa2b5ab3536ae2c3aa715c2841fefd4233648c013",
        "0xfd3439a2006c3ca909d432c126c03710535b5557",
        "0xcdf5e36a7e64fa0e6d090bb3294358e9d5aa6544",
        "0x0662f3ef1c20a3e5edb24516e582a546d34f4a0b",
        "0x23a4b125d6db32f60906333f8977ebe84dabf415",
        "0x3c8df19f13617c54a722099ad917940b6d7b1590",
        "0xf71b7af8000a32f0194914cbc850f33662d75a25",
        "0x8fa99e84d80038c19efba420a5aae1641215d5a7",
        "0x3f33eb0905619efa58f317b50561121dc774b8a3",
        "0xab6b873cba8f47eed36834e3ac414b1b8b136f26",
        "0xf356d9ea444bad8f690956e70a0787208e82c365",
        "0x0a9f744429be2a7dec31c7a751ed08195adfd458",
        "0xf2d19a5108928cb763dac280e90fcec9c0a26ee3",
        "0x1010aec5774155166e43c71d182b8b535da1b05e",
        "0xc4f73b9c0f2ee69b71c43318f255a398561e25f3",
        "0xf066728d5052629287e5c2e753f853be15e3c80f",
        "0xc9683f2a9e50404d81c765c0242a7cca22174ac6",
        "0x42d1daed8792429c3bc33f4eea6636ee4500b38e",
        "0xd45788a7ebd1baa14da4d0059f9320a3a77dfcdb",
        "0x856e44158bd01978f9d661c40ae5cd9edde5cd24",
        "0x08bfc599d7a186124fea98da0b1c2f59819423f4",
        "0xcd5554587ed7b6b1a2451c33998f24538aca5dd1",
        "0x398856a04faa00cf067100e2cd92d5cf31a12855",
        "0xfb264ce1d67fd2f9c80c6034149685e7c1f718d1",
        "0xdc18b363101c5833ec5c529d1de8c9824c706836",
        "0x07beb4afa0c313025bc5b63587fdca3d057163cd",
        "0x3664a96cba23bcabb65d70af9263c74ce6546605",
        "0x5eba77e16b28cf16b24caff3ed21631ee09c7d13",
        "0xdfddb4de776cd9c660832f33d60bd18ec4ee6216",
        "0xbcf9c570343f263a8d5b8cdbce29fca35a9ccfe2",
        "0xb3f4b4038c8b6b0168b46b92f43b5f94d4708b45",
        "0x2771fb3ab80150a8724bbe5860370b28f6cdad10",
        "0xe7f2fe6d9098151db4a9e3329e8b06027e4c7b15",
        "0x2a7e9c38ffcd5da32b60c837ff849b3189c6fcd4",
        "0x14f63b6fba375dd451fc3f08731ed121e95ad783",
        "0x9e904ed99b9a6a012da51055f92382ed25a11da9",
        "0x5a5128850f6f7a2806e45d0702aa76936d3dc09d",
        "0xf0e85616300396e32e4a3a8b35443d863439e654",
        "0x6f292aa87c1fa78bc25bc4b8a46c72ea1cd24a96",
        "0xb77072b21da1523654efba7e590ea24c93583e87",
        "0xe8442bd922dc2b4a03218dafaf27d9b6cada7ee0",
        "0x9c11bffa42c59cf31e98a214d276bcb51e16e859",
        "0xe8442bd922dc2b4a03218dafaf27d9b6cada7ee0",
        "0xe8442bd922dc2b4a03218dafaf27d9b6cada7ee0",
        "0xe8442bd922dc2b4a03218dafaf27d9b6cada7ee0",
        "0xe8442bd922dc2b4a03218dafaf27d9b6cada7ee0",
        "0xe8442bd922dc2b4a03218dafaf27d9b6cada7ee0",
        "0xe8442bd922dc2b4a03218dafaf27d9b6cada7ee0",
        "0xe8442bd922dc2b4a03218dafaf27d9b6cada7ee0",
        "0xe8442bd922dc2b4a03218dafaf27d9b6cada7ee0",
        "0xe8442bd922dc2b4a03218dafaf27d9b6cada7ee0",
        "0xb2e3e82a95f5c4c47e30a5b420ac4f99d32ef61f",
        "0x01b23f8cc7fbf107b0f39aa0ba7c17ebafb5d618"
    ]

    let current = users[0];
    // Replace with your contract's name and deployed address
    const contractName = "BCSH_Distributor"; // Your contract name
    const deployedAddress = "0x546855fb8a886f26f1357d08dab2c7ad2a521e1c"; // Replace with your deployed address

    // Get the signer (account) to interact with the contract
    const [signer] = await hre.ethers.getSigners();

    // Attach to the deployed contract
    const contract = await hre.ethers.getContractAt(contractName, deployedAddress, signer);

    for (const user of users) {
        try {
            console.log('------------\n');
            const tx = await contract.mintTo(user);
            console.log(tx.hash);
            current = user;
            // await tx.wait();
            // console.log("mined ", receipt);
            fs.appendFileSync('output.txt', `https://polygonscan.com/tx/${tx.hash} \n`);
            await waitFor(5);
        } catch (err) {
            console.log(`failed for ${current}, \n ------- \n ${err}`)
        }
    }
}

async function waitFor(seconds) {
    return new Promise(resolve => setTimeout(resolve, seconds * 1000));
}

main().catch((error) => {
    console.error("Error:", error);
    process.exitCode = 1;
});
