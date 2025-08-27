// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../shared/BasicAccessControl.sol";

contract PGWhitelistV2 is BasicAccessControl {
    struct Rule {
        bool exists;
        uint256 index;
    }

    // Whitelist
    address[] public whitelist;
    mapping(address => Rule) public whitelistRules;

    // From + To rules stored separately
    address[] public fromList;
    mapping(address => Rule) public fromRules;

    address[] public toList;
    mapping(address => Rule) public toRules;

    constructor() {}

    function addToWhitelist(address addr) external onlyOwner {
        require(!whitelistRules[addr].exists, "Already whitelisted");
        whitelistRules[addr] = Rule(true, whitelist.length);
        whitelist.push(addr);
    }

    function removeFromWhitelist(address addr) external onlyOwner {
        require(whitelistRules[addr].exists, "Not whitelisted");

        uint256 idx = whitelistRules[addr].index;
        address last = whitelist[whitelist.length - 1];

        whitelist[idx] = last;
        whitelistRules[last].index = idx;

        whitelist.pop();
        delete whitelistRules[addr];
    }

    function addFromRule(address addr) external onlyOwner {
        require(!fromRules[addr].exists, "From rule already exists");
        fromRules[addr] = Rule(true, fromList.length);
        fromList.push(addr);
    }

    function removeFromRule(address addr) external onlyOwner {
        require(fromRules[addr].exists, "From rule not found");

        uint256 idx = fromRules[addr].index;
        address last = fromList[fromList.length - 1];

        fromList[idx] = last;
        fromRules[last].index = idx;

        fromList.pop();
        delete fromRules[addr];
    }

    function addToRule(address addr) external onlyOwner {
        require(!toRules[addr].exists, "To rule already exists");
        toRules[addr] = Rule(true, toList.length);
        toList.push(addr);
    }

    function removeToRule(address addr) external onlyOwner {
        require(toRules[addr].exists, "To rule not found");

        uint256 idx = toRules[addr].index;
        address last = toList[toList.length - 1];

        toList[idx] = last;
        toRules[last].index = idx;

        toList.pop();
        delete toRules[addr];
    }

    function isWithdrawalAllowed(
        address from,
        address to
    ) external view returns (bool) {
        bool fromAllowed = fromRules[from].exists;
        if (!fromAllowed) return false;

        bool toAllowed = toRules[to].exists || toRules[address(0)].exists;

        return toAllowed;
    }
}
