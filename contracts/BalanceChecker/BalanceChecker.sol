pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BalanceChecker {
    /* Fallback function, don't accept any ETH */
    fallback() external payable {
        revert("BalanceChecker does not accept payments");
    }

    receive() external payable {
        revert("BalanceChecker does not accept payments");
    }

    /*
    Check the token balance of a wallet in a token contract

    Returns the balance of the token for user. Avoids possible errors:
      - return 0 on non-contract address 
      - returns 0 if the contract doesn't implement balanceOf
    */
    function tokenBalance(address user, address token) public view returns (uint256) {
        // check if token is actually a contract
        uint256 tokenCode;
        assembly {
            tokenCode := extcodesize(token)
        } // contract code size

        // is it a contract and does it implement balanceOf
        if (tokenCode > 0) {
            try IERC20(token).balanceOf(user) returns (uint256 balance) {
                return balance;
            } catch {
                return 0;
            }
        } else {
            return 0;
        }
    }

    /*
    Check the token balances of a wallet for multiple tokens.
    Pass address(0) as a "token" address to get ETH balance.
    
    Returns an array of balances in the order of users and tokens.
    */
    function balances(
        address[] memory users,
        address[] memory tokens
    ) external view returns (uint256[] memory) {
        uint256[] memory addrBalances = new uint256[](tokens.length * users.length);

        for (uint256 i = 0; i < users.length; i++) {
            for (uint256 j = 0; j < tokens.length; j++) {
                uint256 addrIdx = j + tokens.length * i;
                if (tokens[j] != address(0)) {
                    addrBalances[addrIdx] = tokenBalance(users[i], tokens[j]);
                } else {
                    addrBalances[addrIdx] = users[i].balance; // ETH balance
                }
            }
        }

        return addrBalances;
    }
}
