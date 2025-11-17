// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import {BasicAccessControl} from "../shared/BasicAccessControl.sol";
// import {Freezable} from "../shared/Freezable.sol";

// abstract contract IERC677Receiver {
//     function onTokenTransfer(
//         address _sender,
//         uint256 _value,
//         bytes memory _data
//     ) public virtual;
// }

// contract EtherFantasy is ERC721, BasicAccessControl, Freezable {
//     uint256 public mintCount = 0;
//     uint256 public mintMaxCount = 100;

//     uint256 constant START_TOKEN = 1;

//     bool public isTransferable = false;

//     constructor(
//         string memory _name,
//         string memory _symbol
//     ) ERC721(_name, _symbol) {}

//     // Struct to hold character stats
//     struct Stats {
//         uint16 atk;
//         uint16 def;
//         uint16 hp;
//     }

//     // Mapping from token ID to its stats
//     mapping(uint256 => Stats) public characterStats;
//     // Mapping to track if a token has received its one-time PVE boost
//     mapping(uint256 => bool) public isPveBoosted;

//     // --- Roles and Authorizations ---
//     address public moderatorAddress;
//     address public packSalesContract;
//     address public soulForgeContract;

//     uint256 private _nextTokenId;

//     // --- Events ---
//     event PveBoostApplied(
//         uint256 indexed tokenId,
//         uint16 newAtk,
//         uint16 newDef,
//         uint16 newHp
//     );

//     modifier onlyAuthorized() {
//         require(
//             msg.sender == packSalesContract || msg.sender == soulForgeContract,
//             "Caller is not an authorized contract"
//         );
//         _;
//     }

//     // /**
//     //  * @notice Mints a new character NFT to a specified address.
//     //  * @dev Only callable by the PackSales contract. Assigns pseudo-random base stats.
//     //  * @param to The address to mint the NFT to.
//     //  * @return The ID of the newly minted token.
//     //  */
//     // function mint(address to) external returns (uint256) {
//     //     require(msg.sender == packSalesContract, "Only PackSales can mint");
//     //     uint256 tokenId = _nextTokenId++;
//     //     _safeMint(to, tokenId);

//     //     // Assign pseudo-random base stats
//     //     uint256 randomSeed = uint256(
//     //         keccak256(abi.encodePacked(block.timestamp, to, tokenId))
//     //     );
//     //     characterStats[tokenId] = Stats({
//     //         atk: uint16((randomSeed % 50) + 50), // 50-99
//     //         def: uint16(((randomSeed >> 8) % 50) + 50), // 50-99
//     //         hp: uint16(((randomSeed >> 16) % 100) + 100) // 100-199
//     //     });

//     //     return tokenId;
//     // }

//     /**
//      * @notice Burns a character NFT.
//      * @dev Overrides the default burn to restrict it to the SoulForge contract.
//      * The owner must first approve the SoulForge contract.
//      * @param tokenId The ID of the token to burn.
//      */
//     function burn(uint256 tokenId) public override {
//         require(
//             _isApprovedOrOwner(msg.sender, tokenId),
//             "Caller not owner or approved"
//         );
//         require(msg.sender == soulForgeContract, "Only SoulForge can burn");
//         _burn(tokenId);
//     }

//     /**
//      * @notice Applies a one-time stat boost from PVE game progression.
//      * @dev Only callable by the MODERATOR wallet. Re-rolls stats upward by ~10%.
//      * @param tokenId The ID of the token to boost.
//      */
//     function applyPveBoost(uint256 tokenId) external onlyModerator {
//         require(_exists(tokenId), "Token does not exist");
//         require(!isPveBoosted[tokenId], "PVE boost already applied");

//         Stats storage stats = characterStats[tokenId];

//         // Pseudo-random boost factor (~10-15%)
//         uint256 randomSeed = uint256(
//             keccak256(abi.encodePacked(block.difficulty, tokenId))
//         );

//         stats.atk += uint16((stats.atk * ((randomSeed % 6) + 10)) / 100); // +10% to 15%
//         stats.def += uint16(stats.def * ((randomSeed >> 8) % 6) + 10 / 100);
//         stats.hp += uint16(stats.hp * ((randomSeed >> 16) % 6) + 10 / 100);

//         isPveBoosted[tokenId] = true;

//         emit PveBoostApplied(tokenId, stats.atk, stats.def, stats.hp);
//     }

//     /**
//      * @notice Retrieves the stats for a given character.
//      * @param tokenId The ID of the token.
//      * @return The stats (atk, def, hp).
//      */
//     function getStats(uint256 tokenId) external view returns (Stats memory) {
//         require(_exists(tokenId), "Token does not exist");
//         return characterStats[tokenId];
//     }

//     // --- Admin Functions ---
//     function setModerator(address _moderator) external onlyOwner {
//         moderatorAddress = _moderator;
//     }

//     function setAuthorizedContracts(
//         address _packSales,
//         address _soulForge
//     ) external onlyOwner {
//         packSalesContract = _packSales;
//         soulForgeContract = _soulForge;
//     }

//     function mintTo(
//         address _owner,
//         uint256 _tokenId
//     ) external onlyModerators returns (bool) {
//         return mint(_owner, _tokenId);
//     }

//     function mint(
//         address _owner,
//         uint256 _tokenId
//     ) internal onlyModerators returns (bool) {
//         require(_owner != address(0), "ERC721: mint to the zero address");
//         require(!_exists(_tokenId), "ERC721: token already minted");
//         require(
//             _tokenId >= START_TOKEN && _tokenId <= mintMaxCount,
//             "Token ID is out of range"
//         );

//         require(msg.sender == packSalesContract, "Only PackSales can mint");
//         uint256 tokenId = _nextTokenId++;
//         _safeMint(to, tokenId);

//         // Assign pseudo-random base stats
//         uint256 randomSeed = uint256(
//             keccak256(abi.encodePacked(block.timestamp, to, tokenId))
//         );
//         characterStats[tokenId] = Stats({
//             atk: uint16((randomSeed % 50) + 50), // 50-99
//             def: uint16(((randomSeed >> 8) % 50) + 50), // 50-99
//             hp: uint16(((randomSeed >> 16) % 100) + 100) // 100-199
//         });

//         _safeMint(_owner, _tokenId);

//         return true;
//     }

//     function setMax(uint256 _mintMaxCount) external onlyOwner {
//         mintMaxCount = _mintMaxCount;
//     }

//     function toggleIsTransferable() public onlyOwner {
//         isTransferable = !isTransferable;
//     }

//     function _beforeTokenTransfer(
//         address from,
//         address to,
//         uint256 amount,
//         uint256 batchSize
//     ) internal virtual override {
//         require(
//             moderators[_msgSender()] || isTransferable,
//             "Cannot transfer to the provided address"
//         );
//         require(!isFrozen(from), "ERC20Freezable: from account is frozen");
//         require(!isFrozen(to), "ERC20Freezable: to account is frozen");
//         super._beforeTokenTransfer(from, to, amount, batchSize);
//     }

//     function freeze(address _account) public onlyOwner {
//         freezes[_account] = true;
//         emit Frozen(_account);
//     }

//     function unfreeze(address _account) public onlyOwner {
//         freezes[_account] = false;
//         emit Unfrozen(_account);
//     }

//     function isContract(address _addr) private view returns (bool hasCode) {
//         uint256 length;
//         assembly {
//             length := extcodesize(_addr)
//         }
//         return length > 0;
//     }
// }
