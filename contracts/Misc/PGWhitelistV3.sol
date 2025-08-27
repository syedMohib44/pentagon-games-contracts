pragma solidity >=0.8.0;

import "../shared/BasicAccessControl.sol";

contract PGWhitelistV3 is BasicAccessControl {
    struct WithdrawalRule {
        address[] fromList;
        address[] toList;
    }

    address[] public whitelist;
    WithdrawalRule[] private withdrawalRules;

    constructor() {}

    // Add new whitelist addresses
    function addToWhitelist(address addr) external onlyOwner {
        whitelist.push(addr);
    }

    // Add withdrawal rule
    function addWithdrawalRule(
        address[] memory fromList,
        address[] memory toList
    ) external onlyOwner {
        withdrawalRules.push(
            WithdrawalRule({fromList: fromList, toList: toList})
        );
    }

    // Check if withdrawal is allowed
    function isWithdrawalAllowed(
        address from,
        address to
    ) external view returns (bool) {
        for (uint i = 0; i < withdrawalRules.length; i++) {
            WithdrawalRule storage rule = withdrawalRules[i];

            bool fromAllowed = false;
            for (uint j = 0; j < rule.fromList.length; j++) {
                if (rule.fromList[j] == from) {
                    fromAllowed = true;
                    break;
                }
            }
            if (!fromAllowed) continue;

            bool toAllowed = false;
            for (uint k = 0; k < rule.toList.length; k++) {
                if (rule.toList[k] == to || rule.toList[k] == address(0)) {
                    // address(0) = "*"
                    toAllowed = true;
                    break;
                }
            }

            if (toAllowed) return true;
        }
        return false;
    }
}
