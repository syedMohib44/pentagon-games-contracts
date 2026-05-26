// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../shared/Freezable.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

interface IERC677Receiver {
    function onTokenTransfer(
        address sender,
        uint256 value,
        bytes calldata data
    ) external;
}

/**
 * Carats token (CT)
 * Features: Daily Mint Caps, Per-Transaction Limits, and ERC677 Support.
 */
contract Carat is ERC20, Freezable, BasicAccessControl {
    // ERC677 event
    event TransferAndCall(
        address indexed from,
        address indexed to,
        uint256 value,
        bytes data
    );

    // --- State Variables ---

    // Total amount an address can receive via minting per 24 hours
    uint256 public DAILY_MINT_CAP = 100 * 10 ** 18;

    // Maximum amount allowed in a SINGLE mint call (Daily Cap / 3)
    uint256 public MAX_PER_MINT_CALL = DAILY_MINT_CAP / 3;

    mapping(address => uint256) public mintedToday;
    mapping(address => uint256) public lastMintDay;

    constructor() ERC20("Carats", "CT") {}

    function isContract(address account) public view returns (bool) {
        return account.code.length > 0;
    }

    function _dayIndex() internal view returns (uint256) {
        return block.timestamp / 1 days;
    }

    /**
     * @dev Validates both the single-call limit and the cumulative daily limit.
     */
    function _enforceMintLimits(address _to, uint256 _amount) internal {
        // 1. Enforce Per-Call Limit (Daily Amount / 3)
        require(
            _amount <= MAX_PER_MINT_CALL,
            "CT: Amount exceeds single-call limit"
        );

        uint256 d = _dayIndex();

        // Reset tracker if a new day has started for this user
        if (lastMintDay[_to] != d) {
            lastMintDay[_to] = d;
            mintedToday[_to] = 0;
        }

        // 2. Enforce Cumulative Daily Cap
        require(
            mintedToday[_to] + _amount <= DAILY_MINT_CAP,
            "CT: Daily mint cap exceeded"
        );

        mintedToday[_to] += _amount;
    }

    function mint(address _to, uint256 _amount) external onlyModerators {
        require(!isContract(_to), "Cannot mint to a contract");

        _enforceMintLimits(_to, _amount);
        _mint(_to, _amount);
    }

    function bulkMint(
        address[] calldata _to,
        uint256[] calldata _amount
    ) external onlyModerators {
        require(_to.length == _amount.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < _to.length; i++) {
            require(!isContract(_to[i]), "Cannot mint to a contract");

            _enforceMintLimits(_to[i], _amount[i]);
            _mint(_to[i], _amount[i]);
        }
    }

    /**
     * @dev Updates the daily cap and automatically resets the per-call limit to 1/3.
     */
    function setConfig(uint256 _newDailyMintCap) external onlyModerators {
        DAILY_MINT_CAP = _newDailyMintCap;
        MAX_PER_MINT_CALL = _newDailyMintCap / 3;
    }

    function freeze(address _account) external onlyModerators {
        freezes[_account] = true;
        emit Frozen(_account);
    }

    function unfreeze(address _account) external onlyModerators {
        freezes[_account] = false;
        emit Unfrozen(_account);
    }

    function transferAndCall(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external returns (bool) {
        _transfer(msg.sender, _to, _value);

        emit TransferAndCall(msg.sender, _to, _value, _data);

        if (isContract(_to)) {
            IERC677Receiver receiver = IERC677Receiver(_to);
            receiver.onTokenTransfer(msg.sender, _value, _data);
        }

        return true;
    }

    /**
     * @dev Hook that is called before any transfer of tokens.
     * Includes freeze enforcement.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        // Super call is important for ERC20 logic
        super._beforeTokenTransfer(from, to, amount);

        require(!isFrozen(from), "ERC20Freezable: from account is frozen");
        require(!isFrozen(to), "ERC20Freezable: to account is frozen");
    }
}
