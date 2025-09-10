// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";

contract GunniesKiller is ReentrancyGuard, BasicAccessControl {
    event Kill(string matchId, address from, address to);
    event KillTotal(
        string matchId,
        address from,
        address to,
        uint256 totalKill
    );

    event TotalKill(address from, uint256 totalKill, uint256 lastUpdate);

    mapping(address => bool) public whitelisted;

    function kill(string memory _matchId, address _to) external nonReentrant {
        require(_to != address(0), "Cannot kill null address");
        require(whitelisted[msg.sender] == true, "Player is not whitelisted");
        emit Kill(_matchId, msg.sender, _to);
    }

    function killWithCount(
        string memory _matchId,
        address _to,
        uint256 _totalKill
    ) external nonReentrant {
        require(_to != address(0), "Cannot kill null address");
        require(whitelisted[msg.sender] == true, "Player is not whitelisted");
        emit KillTotal(_matchId, msg.sender, _to, _totalKill);
    }

    function killWithCount(
        uint256 _totalKill
    ) external nonReentrant {
        require(whitelisted[msg.sender] == true, "Player is not whitelisted");
        emit TotalKill(msg.sender, _totalKill, block.timestamp);
    }

    function toggleWhitelist(address _address) external onlyModerators {
        require(_address != address(0), "Cannot toggle null address");
        whitelisted[_address] = !whitelisted[_address];
    }
}
