// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "../shared/BasicAccessControl.sol";
import "../shared/Freezable.sol";
import "../interfaces/IEchoVault_Distributor.sol";

// TODO: Create a factory contract with dynamic name and symbol
contract EchoVault is ERC20, Freezable, BasicAccessControl {
    /**
     * Events:
     * Friends
     * Follower
     */
    enum FriendRequest {
        NONE,
        REQUEST,
        ACCEPT
    }

    event Request(
        FriendRequest request,
        address friend,
        address owner,
        uint256 amount
    );
    event Follow(address friend, address owner, uint256 amount);

    IEchoVault_Distributor public echoVaultDistributor;

    mapping(address => bool) public transferable;
    bool public isTransferable = false;

    uint256 public constant MAX_SUPPLY = 100_000_000 * 1e18;
    uint256 public constant OWNER_SHARE = (MAX_SUPPLY * 80) / 100; // 80%
    uint256 public constant DEV_SHARE = (MAX_SUPPLY * 5) / 100; // 5%

    address public constant DEV_ADDRESS =
        0xB2e3e82a95f5c4c47E30A5b420Ac4f99d32EF61f;

    mapping(address => FriendRequest) public friendRequests;

    mapping(address => bool) public isFriend;
    mapping(address => bool) public isFollower;
    mapping(address => bool) public isReferral;

    uint256 public constant FRIEND_AMOUNT = MAX_SUPPLY / 100_000; // 0.001%
    uint256 public constant FOLLOWER_AMOUNT = MAX_SUPPLY / 10_000_000; // 0.00001%
    uint256 public constant REFERRAL_AMOUNT = MAX_SUPPLY / 10_000; // 0.01%

    uint256 public constant FRIEND_MAX = 5_000;
    uint256 public constant FOLLOWER_MAX = 500_000;
    uint256 public constant REFERRAL_MAX = 500;

    uint256 public friendCount;
    uint256 public followerCount;
    uint256 public referralCount;

    //TODO: Dev wallet is constant and if user pay more fee like 100 - 120 PC they don't have to pay 5%

    constructor(
        string memory _name,
        string memory _symbol,
        address _echoVaultDistributor,
        address _owner
    ) ERC20(_name, _symbol) {
        echoVaultDistributor = IEchoVault_Distributor(_echoVaultDistributor);
        _mint(address(this), MAX_SUPPLY);
        _transfer(address(this), _owner, OWNER_SHARE); // send 80% to owner
        _transfer(address(this), DEV_ADDRESS, DEV_SHARE);
    }

    function sendFriendRequest() external {
        require(
            msg.sender != address(0),
            "Cannot send friend request to null address"
        );
        require(
            friendRequests[msg.sender] == FriendRequest.NONE,
            "Invalid request type"
        );
        require(msg.sender != owner(), "Cannot send friend request to ownself");
        friendRequests[msg.sender] = FriendRequest.REQUEST;
        emit Request(FriendRequest.REQUEST, msg.sender, owner(), 0);
    }

    //TODO: unFriend and unFollow

    function acceptFriendRequest(address _friend) external onlyOwner {
        require(
            friendRequests[_friend] == FriendRequest.REQUEST,
            "Invalid request type"
        );
        require(!isFriend[_friend], "Already a friend");
        require(friendCount < FRIEND_MAX, "Friend cap reached");

        isFriend[_friend] = true;
        friendCount++;
        friendRequests[msg.sender] = FriendRequest.ACCEPT;
        _transfer(address(this), _friend, FRIEND_AMOUNT);
        // token.disperse(msg.sender, FRIEND_AMOUNT);
        emit Request(FriendRequest.ACCEPT, msg.sender, owner(), FRIEND_AMOUNT);
    }

    function addFollower() external {
        require(!isFollower[msg.sender], "Already a follower");
        require(msg.sender != owner(), "Cannot follow to ownself");
        require(followerCount < FOLLOWER_MAX, "Follower cap reached");

        isFollower[msg.sender] = true;
        followerCount++;
        _transfer(address(this), msg.sender, FOLLOWER_AMOUNT);
        // token.disperse(msg.sender, FOLLOWER_AMOUNT);
        emit Follow(msg.sender, owner(), FOLLOWER_AMOUNT);
    }

    //TODO: Refere a Prof and if the Mob creates a token then give Prof 0.1% of the Mob token total would be 500 invites alltogeather 5%
    // And the Mob will get 0.25% of token from Prof
    // function addReferral() external {
    //     require(!isReferral[msg.sender], "Already referred");
    //     require(referralCount < REFERRAL_MAX, "Referral cap reached");

    //     isReferral[msg.sender] = true;
    //     referralCount++;
    //     _transfer(address(this), msg.sender, REFERRAL_AMOUNT);
    //     // token.disperse(msg.sender, REFERRAL_AMOUNT);
    // }

    function getRemaining()
        external
        view
        returns (
            uint256 friendsLeft,
            uint256 followersLeft,
            uint256 referralsLeft
        )
    {
        return (
            FRIEND_MAX - friendCount,
            FOLLOWER_MAX - followerCount,
            REFERRAL_MAX - referralCount
        );
    }
}
