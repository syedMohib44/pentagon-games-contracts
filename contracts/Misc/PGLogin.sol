pragma solidity >=0.8.0;

import "../shared/BasicAccessControl.sol";

contract PGLogin is BasicAccessControl {
    enum LOGIN_ROLE {
        NONE,
        ADMIN,
        MODERATOR,
        USER
    }

    struct UserData {
        LOGIN_ROLE role;
        uint256 index;
    }

    mapping(address => UserData) public usersData;
    address[] public users;

    constructor(address _user, LOGIN_ROLE _role) {
        assignRole(_user, _role);
    }

    function assignRole(address _user, LOGIN_ROLE _role) public onlyModerators {
        require(usersData[_user].role == LOGIN_ROLE.NONE, "Already assigned");

        users.push(_user);
        usersData[_user] = UserData({role: _role, index: users.length - 1});
    }

    function assignBulkRole(
        address[] memory _users,
        LOGIN_ROLE[] memory _roles
    ) public onlyModerators {
        require(_users.length == _roles.length, "Invalid length provided");

        for (uint256 i = 0; i < _users.length; i++) {
            require(
                usersData[_users[i]].role == LOGIN_ROLE.NONE,
                "Already assigned"
            );

            users.push(_users[i]);
            usersData[_users[i]] = UserData({
                role: _roles[i],
                index: users.length - 1
            });
        }
    }

    function removeRole(address _user) public onlyModerators {
        require(usersData[_user].role != LOGIN_ROLE.NONE, "Not assigned");

        uint256 index = usersData[_user].index;
        uint256 lastIndex = users.length - 1;
        address lastUser = users[lastIndex];

        if (index != lastIndex) {
            users[index] = lastUser;
            usersData[lastUser].index = index;
        }

        users.pop();
        delete usersData[_user];
    }

    function removeBulkRole(address[] memory _users) public onlyModerators {
        require(
            _users.length <= users.length,
            "Provided elements exceeds users"
        );

        for (uint256 i = 0; i < _users.length; i++) {
            require(
                usersData[_users[i]].role != LOGIN_ROLE.NONE,
                "Not assigned"
            );

            uint256 index = usersData[_users[i]].index;
            uint256 lastIndex = users.length - 1;
            address lastUser = users[lastIndex];

            if (index != lastIndex) {
                users[index] = lastUser;
                usersData[lastUser].index = index;
            }

            users.pop();
            delete usersData[_users[i]];
        }
    }

    function isLogin(
        address _user
    ) external view returns (uint256, LOGIN_ROLE) {
        UserData memory userData = usersData[_user];
        return (userData.index, userData.role);
    }
}
