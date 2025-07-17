// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "../shared/BasicUpgradeableAccessControl.sol";
import "../shared/Freezable.sol";

contract EchoVault is
    Initializable,
    ERC20Upgradeable,
    UUPSUpgradeable,
    BasicUpgradeableAccessControl,
    Freezable
{
    /**
     * Events:
     * Friends
     * Follower
     */
    enum FriendRequest {
        NONE,
        REQUEST,
        FRIEND,
        UNFRIEND
    }

    enum FollowRequest {
        NONE,
        FOLLOW,
        UNFOLLOW
    }

    event Request(
        FriendRequest request,
        address friend,
        address owner,
        uint256 amount
    );
    event Follow(address friend, address owner, uint256 amount);

    mapping(address => bool) public transferable;
    bool public isTransferable = false;

    uint256 public constant MAX_SUPPLY = 100_000_000 * 1e18;
    uint256 public constant OWNER_SHARE = (MAX_SUPPLY * 80) / 100; // 80%
    uint256 public constant DEV_SHARE = (MAX_SUPPLY * 5) / 100; // 5%

    address public constant DEV_ADDRESS =
        0xB2e3e82a95f5c4c47E30A5b420Ac4f99d32EF61f;

    mapping(address => FriendRequest) public friendRequests;
    mapping(address => FollowRequest) public followRequests;

    mapping(address => bool) public blockList;
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

    constructor() {
        _disableInitializers(); // Required for upgradeable contracts
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        address _owner
    ) public payable initializer {
        __ERC20_init(_name, _symbol);
        __UUPSUpgradeable_init();
        __Ownable_init(); // ✅ This initializes the owner

        _mint(address(this), MAX_SUPPLY);
        _transfer(address(this), _owner, OWNER_SHARE);

        if (msg.value == 0) {
            _transfer(address(this), DEV_ADDRESS, DEV_SHARE);
        }
        transferOwnership(_owner);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    function requestFriend() external {
        require(
            msg.sender != address(0),
            "Cannot send friend request to null address"
        );
        require(!blockList[msg.sender], "You are block by user");

        require(
            friendRequests[msg.sender] == FriendRequest.NONE ||
                friendRequests[msg.sender] == FriendRequest.UNFRIEND,
            "Invalid request type"
        );
        require(msg.sender != owner(), "Cannot send friend request to ownself");

        if (friendRequests[msg.sender] == FriendRequest.UNFRIEND) {
            friendRequests[msg.sender] = FriendRequest.UNFRIEND;
        } else if (friendRequests[msg.sender] == FriendRequest.NONE) {
            friendRequests[msg.sender] = FriendRequest.REQUEST;
        }
        emit Request(friendRequests[msg.sender], msg.sender, owner(), 0);
    }

    function acceptFriend(address _friend) external onlyOwner {
        require(!blockList[_friend], "You have blocked the user");

        require(
            friendRequests[_friend] == FriendRequest.REQUEST ||
                friendRequests[_friend] == FriendRequest.UNFRIEND,
            "Invalid request type"
        );
        require(!isFriend[_friend], "Already a friend");
        require(friendCount < FRIEND_MAX, "Friend cap reached");

        if (friendRequests[_friend] == FriendRequest.REQUEST) {
            friendCount++;
            _transfer(address(this), _friend, FRIEND_AMOUNT);
            emit Request(
                FriendRequest.FRIEND,
                _friend,
                msg.sender,
                FRIEND_AMOUNT
            );
        } else if (friendRequests[_friend] == FriendRequest.UNFRIEND) {
            emit Request(FriendRequest.FRIEND, _friend, msg.sender, 0);
        }
        isFriend[_friend] = true;
        friendRequests[_friend] = FriendRequest.FRIEND;
    }

    function rejectFriendRequest(address _friend) external onlyOwner {
        require(
            friendRequests[_friend] == FriendRequest.REQUEST,
            "No pending request to reject"
        );
        friendRequests[_friend] = FriendRequest.NONE;
        emit Request(FriendRequest.NONE, _friend, msg.sender, 0);
    }

    function cancelFriendRequest() external {
        require(
            friendRequests[msg.sender] == FriendRequest.REQUEST,
            "No pending request to cancel"
        );
        friendRequests[msg.sender] = FriendRequest.NONE;
        emit Request(FriendRequest.NONE, msg.sender, owner(), 0);
    }

    function unFriend(address _friend) external onlyOwner {
        require(
            !blockList[_friend],
            "You have blocked the user, unfriended already"
        );

        require(
            friendRequests[_friend] == FriendRequest.FRIEND ||
                friendRequests[_friend] == FriendRequest.REQUEST,
            "Invalid request type"
        );
        require(isFriend[_friend], "Not a friend");

        isFriend[_friend] = false;
        friendRequests[_friend] = FriendRequest.UNFRIEND;
        emit Request(FriendRequest.UNFRIEND, _friend, msg.sender, 0);
    }

    function blockUser(address _friend) external onlyOwner {
        if (friendRequests[_friend] == FriendRequest.NONE) {
            friendRequests[_friend] = FriendRequest.NONE;
        } else {
            friendRequests[_friend] = FriendRequest.UNFRIEND;
        }

        if (followRequests[_friend] == FollowRequest.NONE) {
            followRequests[_friend] = FollowRequest.NONE;
        } else {
            followRequests[_friend] = FollowRequest.UNFOLLOW;
        }

        isFriend[_friend] = false;
        blockList[_friend] = true;
        isFollower[_friend] = false;
        emit Request(friendRequests[_friend], _friend, msg.sender, 0);
    }

    function unBlockUser(address _friend) external onlyOwner {
        blockList[_friend] = false;
        emit Request(friendRequests[_friend], _friend, msg.sender, 0);
    }

    function followUser() external {
        require(!blockList[msg.sender], "You are block by user");

        require(
            followRequests[msg.sender] == FollowRequest.NONE ||
                followRequests[msg.sender] == FollowRequest.UNFOLLOW,
            "Invalid request type"
        );

        require(!isFollower[msg.sender], "Already a follower");
        require(msg.sender != owner(), "Cannot follow to ownself");
        require(followerCount < FOLLOWER_MAX, "Follower cap reached");

        if (followRequests[msg.sender] == FollowRequest.NONE) {
            followerCount++;
            _transfer(address(this), msg.sender, FOLLOWER_AMOUNT);
            emit Follow(msg.sender, owner(), FOLLOWER_AMOUNT);
        } else if (followRequests[msg.sender] == FollowRequest.UNFOLLOW) {
            emit Follow(msg.sender, owner(), 0);
        }
        isFollower[msg.sender] = true;
        followRequests[msg.sender] = FollowRequest.FOLLOW;
    }

    function unFollowUser() external {
        require(!blockList[msg.sender], "You are block by user");

        require(
            followRequests[msg.sender] == FollowRequest.FOLLOW,
            "Invalid request type"
        );

        require(isFollower[msg.sender], "Not a follower");
        require(msg.sender != owner(), "Cannot unfollow to ownself");

        isFollower[msg.sender] = false;
        // token.disperse(msg.sender, FOLLOWER_AMOUNT);
        emit Follow(msg.sender, owner(), 0);
    }

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
