// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// contract ResonanceMint is ERC721, Ownable {
//     address public originalNftContract;
//     uint256 public mintPrice;
//     uint256 public nextTokenId;

//     event PlayableCharacterMinted(
//         address indexed minter,
//         uint256 newCharacterTokenId,
//         uint256 originalTokenId
//     );

//     constructor(
//         address initialOwner,
//         address _originalNftContract,
//         uint256 _mintPrice,
//         uint256 _startTokenId
//     ) ERC721("Playable Character NFT", "PCNFT") Ownable(initialOwner) {
//         require(
//             _originalNftContract != address(0),
//             "Original NFT contract cannot be zero address"
//         );
//         originalNftContract = _originalNftContract;
//         mintPrice = _mintPrice;
//         nextTokenId = _startTokenId;
//     }

//     function _transferOriginalNft(
//         address from,
//         uint256 originalTokenId
//     ) private {
//         IERC721 originalNft = IERC721(originalNftContract);

//         require(
//             originalNft.ownerOf(originalTokenId) == from,
//             "ResonanceMint: Caller does not own the Original NFT"
//         );

//         originalNft.safeTransferFrom(from, address(this), originalTokenId);
//     }

//     function resonanceMint(uint256 originalTokenId) public payable {
//         require(
//             msg.value >= mintPrice,
//             "ResonanceMint: Insufficient payment for minting"
//         );

//         _transferOriginalNft(msg.sender, originalTokenId);

//         uint256 newCharacterTokenId = nextTokenId;
//         nextTokenId++;

//         _safeMint(msg.sender, newCharacterTokenId);

//         emit PlayableCharacterMinted(
//             msg.sender,
//             newCharacterTokenId,
//             originalTokenId
//         );
//     }

//     function withdraw() public onlyOwner {
//         (bool success, ) = payable(owner()).call{value: address(this).balance}(
//             ""
//         );
//         require(success, "Withdrawal failed");
//     }

//     function supportsInterface(
//         bytes4 interfaceId
//     ) public view override(ERC721, Ownable) returns (bool) {
//         return super.supportsInterface(interfaceId);
//     }
// }
