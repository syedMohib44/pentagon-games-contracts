pragma solidity >=0.8.0;


import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract BasicUpgradeableAccessControl is OwnableUpgradeable {
    uint16 public totalModerators = 0;
    mapping(address => bool) public moderators;
    bool public isMaintaining = true;

    modifier onlyModerators() {
        require(_msgSender() == owner() || moderators[_msgSender()] == true);
        _;
    }

    modifier isActive() {
        require(!isMaintaining);
        _;
    }

    function addModerator(address _newModerator) public onlyOwner {
        if (moderators[_newModerator] == false) {
            moderators[_newModerator] = true;
            totalModerators += 1;
        } else {
            delete moderators[_newModerator];
            totalModerators -= 1;
        }
    }

    function updateMaintaining(bool _isMaintaining) public onlyOwner {
        isMaintaining = _isMaintaining;
    }
}
