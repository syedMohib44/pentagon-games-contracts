// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

/**
 * @title CharacterNFT
 * @notice Core ERC-721 contract for game characters.
 * Manages base stats, PVE boosts, and randomly generated items upon minting.
 */
contract CharacterNFT is ERC721, ERC721Burnable, BasicAccessControl {
    // ----------------------------------
    // ENUMS
    // ----------------------------------
    enum Slot {
        WEAPON,
        HEAD,
        BODY,
        BOOTS
    }

    enum Rarity {
        NORMAL,
        HIGH,
        RARE,
        HEROIC,
        LEGENDARY,
        MYTHIC
    }

    // ----------------------------------
    // STRUCTS
    // ----------------------------------

    struct Stats {
        uint16 perf;
        uint16 atk;
        uint16 def;
        uint16 hp;
    }

    // struct

    /**
     * @dev Represents a single equipped item for getter functions.
     */
    struct EquippedItem {
        Slot slot;
        uint256 itemId;
    }

    /**
     * @dev A struct to hold all character data for easy lookup.
     */
    struct CharacterData {
        Stats currentStats;
        EquippedItem[] items;
        uint256 templateId;
        bool isPveBoosted;
    }

    // ----------------------------------
    // STATE VARIABLES
    // ----------------------------------

    // --- Template & Stats Data ---
    uint256[] public templateIds; // List of all available template IDs

    // --- Item Database ---
    // characterId (templateId) => slot => rarity => itemIds[]
    mapping(uint256 => mapping(Slot => mapping(Rarity => uint256[])))
        public characterItems;

    // --- Token-Specific Data ---
    mapping(uint256 => Stats) public characterStats; // tokenId => current stats
    mapping(uint256 => bool) public isPveBoosted; // tokenId => boost status
    mapping(uint256 => uint256) public tokenIdToTemplateId; // tokenId => templateId

    // Stores the randomly generated items for each NFT
    // tokenId => Slot => itemId
    mapping(uint256 => mapping(Slot => uint256)) public equippedItems;

    // --- Roles & Counters ---
    address public moderatorAddress;
    address public packSalesContract;
    address public soulForgeContract;
    uint256 private _nextTokenId;

    // ----------------------------------
    // EVENTS
    // ----------------------------------
    event TemplateAdded(uint256 indexed templateId, Stats stats);
    event CharacterMinted(
        uint256 indexed tokenId,
        uint256 indexed templateId,
        uint256 weaponId,
        uint256 headId,
        uint256 bodyId,
        uint256 bootsId
    );
    event PveBoostApplied(
        uint256 indexed tokenId,
        uint16 newAtk,
        uint16 newLuck,
        uint16 newHp,
        uint16 newDef
    );

    // ----------------------------------
    // CONSTRUCTOR
    // ----------------------------------

    constructor() ERC721("Ether Fantasy Character", "EFC") {
        // Initialize base character item sets
        _initKei();
        _initIrene();
        _initLeah();

        // !!! IMPORTANT DEPLOYMENT STEP !!!
        // You must manually call addTemplate() for your characters (1, 101, 201)
        // after deployment for minting to work.
        // Example: addTemplate(1, Stats(10, 5, 100, 8));
    }

    // ----------------------------------
    // INTERNAL HELPERS
    // ----------------------------------

    function _setCharacterItems(
        uint256 characterId,
        Slot slot,
        Rarity rarity,
        uint256[] memory ids
    ) internal {
        for (uint256 i = 0; i < ids.length; i++) {
            characterItems[characterId][slot][rarity].push(ids[i]);
        }
    }

    /**
     * @dev Generates a pseudo-random number for RNG.
     * @notice For production, replace with Chainlink VRF.
     */
    function _getRandomNumber(uint256 salt) private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        msg.sender,
                        _nextTokenId, // Use nextTokenId for more variance
                        salt
                    )
                )
            );
    }

    // ----------------------------------
    // CHARACTER ITEM INITIALIZATION
    // ----------------------------------

    function _initKei() internal {
        uint256 id = 1;
        uint256[] memory tmp;

        // --- WEAPON ---
        tmp = new uint256[](4);
        tmp[0] = 100001;
        tmp[1] = 100101;
        tmp[2] = 100201;
        tmp[3] = 100301;
        _setCharacterItems(id, Slot.WEAPON, Rarity.NORMAL, tmp);
        tmp[0] = 100002;
        tmp[1] = 100102;
        tmp[2] = 100202;
        tmp[3] = 100302;
        _setCharacterItems(id, Slot.WEAPON, Rarity.HIGH, tmp);
        tmp[0] = 100003;
        tmp[1] = 100103;
        tmp[2] = 100203;
        tmp[3] = 100303;
        _setCharacterItems(id, Slot.WEAPON, Rarity.RARE, tmp);
        tmp[0] = 100004;
        tmp[1] = 100104;
        tmp[2] = 100204;
        tmp[3] = 100304;
        _setCharacterItems(id, Slot.WEAPON, Rarity.HEROIC, tmp);
        tmp[0] = 100005;
        tmp[1] = 100105;
        tmp[2] = 100205;
        tmp[3] = 100305;
        _setCharacterItems(id, Slot.WEAPON, Rarity.LEGENDARY, tmp);
        tmp[0] = 100006;
        tmp[1] = 100106;
        tmp[2] = 100206;
        tmp[3] = 100306;
        _setCharacterItems(id, Slot.WEAPON, Rarity.MYTHIC, tmp);

        // --- HEAD ---
        tmp[0] = 110001;
        tmp[1] = 110101;
        tmp[2] = 110201;
        tmp[3] = 110301;
        _setCharacterItems(id, Slot.HEAD, Rarity.NORMAL, tmp);
        tmp[0] = 110002;
        tmp[1] = 110102;
        tmp[2] = 110202;
        tmp[3] = 110302;
        _setCharacterItems(id, Slot.HEAD, Rarity.HIGH, tmp);
        tmp[0] = 110003;
        tmp[1] = 110103;
        tmp[2] = 110203;
        tmp[3] = 110303;
        _setCharacterItems(id, Slot.HEAD, Rarity.RARE, tmp);
        tmp[0] = 110004;
        tmp[1] = 110104;
        tmp[2] = 110204;
        tmp[3] = 110304;
        _setCharacterItems(id, Slot.HEAD, Rarity.HEROIC, tmp);
        tmp[0] = 110005;
        tmp[1] = 110105;
        tmp[2] = 110205;
        tmp[3] = 110305;
        _setCharacterItems(id, Slot.HEAD, Rarity.LEGENDARY, tmp);
        tmp[0] = 110006;
        tmp[1] = 110106;
        tmp[2] = 110206;
        tmp[3] = 110306;
        _setCharacterItems(id, Slot.HEAD, Rarity.MYTHIC, tmp);

        // --- BODY ---
        tmp[0] = 120001;
        tmp[1] = 120101;
        tmp[2] = 120201;
        tmp[3] = 120301;
        _setCharacterItems(id, Slot.BODY, Rarity.NORMAL, tmp);
        tmp[0] = 120002;
        tmp[1] = 120102;
        tmp[2] = 120202;
        tmp[3] = 120302;
        _setCharacterItems(id, Slot.BODY, Rarity.HIGH, tmp);
        tmp[0] = 120003;
        tmp[1] = 120103;
        tmp[2] = 120203;
        tmp[3] = 120303;
        _setCharacterItems(id, Slot.BODY, Rarity.RARE, tmp);
        tmp[0] = 120004;
        tmp[1] = 120104;
        tmp[2] = 120204;
        tmp[3] = 120304;
        _setCharacterItems(id, Slot.BODY, Rarity.HEROIC, tmp);
        tmp[0] = 120005;
        tmp[1] = 120105;
        tmp[2] = 120205;
        tmp[3] = 120305;
        _setCharacterItems(id, Slot.BODY, Rarity.LEGENDARY, tmp);
        tmp[0] = 120006;
        tmp[1] = 120106;
        tmp[2] = 120206;
        tmp[3] = 120306;
        _setCharacterItems(id, Slot.BODY, Rarity.MYTHIC, tmp);

        // --- BOOTS ---
        tmp[0] = 130001;
        tmp[1] = 130101;
        tmp[2] = 130201;
        tmp[3] = 130301;
        _setCharacterItems(id, Slot.BOOTS, Rarity.NORMAL, tmp);
        tmp[0] = 130002;
        tmp[1] = 130102;
        tmp[2] = 130202;
        tmp[3] = 130302;
        _setCharacterItems(id, Slot.BOOTS, Rarity.HIGH, tmp);
        tmp[0] = 130003;
        tmp[1] = 130103;
        tmp[2] = 130203;
        tmp[3] = 130303;
        _setCharacterItems(id, Slot.BOOTS, Rarity.RARE, tmp);
        tmp[0] = 130004;
        tmp[1] = 130104;
        tmp[2] = 130204;
        tmp[3] = 130304;
        _setCharacterItems(id, Slot.BOOTS, Rarity.HEROIC, tmp);
        tmp[0] = 130005;
        tmp[1] = 130105;
        tmp[2] = 130205;
        tmp[3] = 130305;
        _setCharacterItems(id, Slot.BOOTS, Rarity.LEGENDARY, tmp);
        tmp[0] = 130006;
        tmp[1] = 130106;
        tmp[2] = 130206;
        tmp[3] = 130306;
        _setCharacterItems(id, Slot.BOOTS, Rarity.MYTHIC, tmp);
    }

    function _initIrene() internal {
        uint256 id = 101;
        uint256[] memory tmp;

        // --- WEAPON ---
        tmp = new uint256[](4);
        tmp[0] = 200001;
        tmp[1] = 200101;
        tmp[2] = 200201;
        tmp[3] = 200301;
        _setCharacterItems(id, Slot.WEAPON, Rarity.NORMAL, tmp);
        tmp[0] = 200002;
        tmp[1] = 200102;
        tmp[2] = 200202;
        tmp[3] = 200302;
        _setCharacterItems(id, Slot.WEAPON, Rarity.HIGH, tmp);
        // ... (truncated for brevity, logic follows _initKei)
    }

    function _initLeah() internal {
        uint256 id = 201;
        uint256[] memory tmp;

        // --- WEAPON ---
        tmp = new uint256[](4);
        tmp[0] = 300001;
        tmp[1] = 300101;
        tmp[2] = 300201;
        tmp[3] = 300301;
        _setCharacterItems(id, Slot.WEAPON, Rarity.NORMAL, tmp);
        tmp[0] = 300002;
        tmp[1] = 300102;
        tmp[2] = 300202;
        tmp[3] = 300302;
        _setCharacterItems(id, Slot.WEAPON, Rarity.HIGH, tmp);
        // ... (truncated for brevity, logic follows _initKei)
    }

    // ----------------------------------
    // MINT FUNCTION (CORE LOGIC)
    // ----------------------------------

    /**
     * @notice Mints a new character, assigning base stats and random items.
     * @dev Called by PackSales contract.
     * @param to The recipient of the new NFT.
     * @param characterId The template ID (e.g., 1 for Kei) to mint.
     */
    function mint(
        address to,
        uint256 characterId
    ) external onlyModerators returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);

        uint16[] memory tempItemsRarity = new uint16[](4);
        // 1. Link token to its template and assign base stats
        tokenIdToTemplateId[tokenId] = characterId;

        uint256[4] memory generatedItemIds; // To store for the event

        // 2. Random item assignment AND STORAGE
        for (uint8 i = 0; i < 4; i++) {
            Slot slot = Slot(i);

            // 2a. Determine random rarity (0-5)
            Rarity rarity = Rarity(uint8(_getRandomNumber(tokenId + i) % 6));
            // 2b. Get the list of possible items
            uint256[] storage items = characterItems[characterId][slot][rarity];

            if (items.length > 0) {
                // 2c. Pick a random item from the list
                uint256 itemIndex = _getRandomNumber(tokenId + i + 100) %
                    items.length;
                uint256 selectedItem = items[itemIndex];

                // 2d. *** STORE THE ITEM ***
                equippedItems[tokenId][slot] = selectedItem;
                generatedItemIds[i] = selectedItem;
                tempItemsRarity[i] = uint16(uint8(rarity) + 1);
            }
        }

        uint16 perf = (((tempItemsRarity[0] +
            tempItemsRarity[1] +
            tempItemsRarity[2] +
            tempItemsRarity[3]) - 4) / (24 - 4)) * 100;

        uint16 atk = tempItemsRarity[0] *
            50 +
            tempItemsRarity[1] *
            10 +
            tempItemsRarity[3] *
            5 +
            100;

        uint16 def = tempItemsRarity[1] *
            100 +
            tempItemsRarity[2] *
            350 +
            tempItemsRarity[3] *
            100;

        uint16 hp = tempItemsRarity[1] *
            200 +
            tempItemsRarity[2] *
            200 +
            tempItemsRarity[3] *
            150 +
            500;

        Stats memory stats = Stats({perf: perf, atk: atk, def: def, hp: hp});
        characterStats[tokenId] = stats;

        // 3. Emit event with generated data
        emit CharacterMinted(
            tokenId,
            characterId,
            generatedItemIds[0], // WEAPON
            generatedItemIds[1], // HEAD
            generatedItemIds[2], // BODY
            generatedItemIds[3] // BOOTS
        );
        return tokenId;
    }

    function mintPredefined(
        address to,
        uint256 characterId,
        uint256[] memory items,
        uint16[] memory stats
    ) external onlyModerators returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);

        // 1. Link token to its template and assign base stats
        tokenIdToTemplateId[tokenId] = characterId;

        uint256[4] memory generatedItemIds; // To store for the event

        // 2. Random item assignment AND STORAGE
        for (uint8 i = 0; i < 4; i++) {
            Slot slot = Slot(i);

            if (items.length > 0) {
                uint256 selectedItem = items[i];

                equippedItems[tokenId][slot] = selectedItem;
                generatedItemIds[i] = selectedItem;
            }
        }

        characterStats[tokenId] = Stats({
            perf: stats[0],
            atk: stats[1],
            def: stats[2],
            hp: stats[3]
        });

        // 3. Emit event with generated data
        emit CharacterMinted(
            tokenId,
            characterId,
            generatedItemIds[0], // WEAPON
            generatedItemIds[1], // HEAD
            generatedItemIds[2], // BODY
            generatedItemIds[3] // BOOTS
        );
        return tokenId;
    }

    // ----------------------------------
    // BURN FUNCTION
    // ----------------------------------

    function burn(uint256 tokenId) public override {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Caller not owner or approved"
        );
        require(msg.sender == soulForgeContract, "Only SoulForge can burn");

        // Clear associated data to save gas
        delete characterStats[tokenId];
        delete isPveBoosted[tokenId];
        delete tokenIdToTemplateId[tokenId];
        for (uint8 i = 0; i < 4; i++) {
            delete equippedItems[tokenId][Slot(i)];
        }

        _burn(tokenId);
    }

    // ----------------------------------
    // VIEW FUNCTIONS
    // ----------------------------------

    /**
     * @notice Gets all combined data for a specific character token.
     * @param tokenId The ID of the token to query.
     * @return A CharacterData struct containing stats, items, template ID, and boost status.
     */
    function getCharacterData(
        uint256 tokenId
    ) external view returns (CharacterData memory) {
        require(_exists(tokenId), "Token does not exist");

        // 1. Get Stats, TemplateID, and Boost Status
        Stats memory _stats = characterStats[tokenId];
        uint256 _templateId = tokenIdToTemplateId[tokenId];
        bool _isBoosted = isPveBoosted[tokenId];

        // 2. Get Equipped Items
        EquippedItem[] memory _items = new EquippedItem[](4);
        for (uint8 i = 0; i < 4; i++) {
            _items[i] = EquippedItem({
                slot: Slot(i),
                itemId: equippedItems[tokenId][Slot(i)]
            });
        }

        // 3. Return all data in the new struct
        return
            CharacterData({
                currentStats: _stats,
                items: _items,
                templateId: _templateId,
                isPveBoosted: _isBoosted
            });
    }

    /**
     * @notice Gets the current stats for a specific token.
     */
    function getStats(uint256 tokenId) external view returns (Stats memory) {
        require(_exists(tokenId), "Token does not exist");
        return characterStats[tokenId];
    }

    /**
     * @notice Gets the randomly generated items for a specific token.
     */
    function getEquippedItems(
        uint256 tokenId
    ) external view returns (EquippedItem[] memory) {
        require(_exists(tokenId), "Token does not exist");

        EquippedItem[] memory items = new EquippedItem[](4);
        for (uint8 i = 0; i < 4; i++) {
            items[i] = EquippedItem({
                slot: Slot(i),
                itemId: equippedItems[tokenId][Slot(i)]
            });
        }
        return items;
    }

    // ----------------------------------
    // ADMIN FUNCTIONS
    // ----------------------------------

    function setModerator(address _moderator) external onlyOwner {
        moderatorAddress = _moderator;
    }

    function setAuthorizedContracts(
        address _packSales,
        address _soulForge
    ) external onlyOwner {
        packSalesContract = _packSales;
        soulForgeContract = _soulForge;
    }
}
