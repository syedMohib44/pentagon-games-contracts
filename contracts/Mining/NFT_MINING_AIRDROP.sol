import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";
import {Freezable} from "../shared/Freezable.sol";

contract NFT_MINING_AIRDROP is BasicAccessControl {
    event AirdropTransfer(
        address indexed tokenAddress,
        address[] indexed addresses,
        uint256[] indexed values
    );

    event AirdropTransfer(
        address[] indexed addresses,
        uint256[] indexed values
    );

    // uint256 public rewardBlockTime = 10 minutes;
    // uint256 public lastDroppedTime = 0;
    mapping(address => uint256) public rewardBlockTime;
    mapping(address => uint256) public lastDroppedTime;
    mapping(address => uint256) public amountToAirdrop;

    /**
     * @dev Airdrop Tokens to user addresses and called by only owner
     *
     **/
    function doAirdropERC20(
        address _tokenAddress,
        address[] memory addresses,
        uint256[] memory values
    ) external onlyModerators {
        require(_tokenAddress != address(0), "ERC20 address cannot be null");
        
        uint256 nextBlockTime = rewardBlockTime[_tokenAddress] +
            lastDroppedTime[_tokenAddress];

        require(nextBlockTime <= block.timestamp, "Wait for next reward block");

        for (uint256 i = 0; i < addresses.length; i++) {
            require(
                values[i] <= amountToAirdrop[_tokenAddress],
                "Invalid amount provided"
            );
            IERC20(_tokenAddress).transfer(addresses[i], values[i]);
        }
        lastDroppedTime[_tokenAddress] = block.timestamp;

        emit AirdropTransfer(_tokenAddress, addresses, values);
    }

    receive() external payable {}

    /**
     * @dev Airdrop Tokens to user addresses and called by only owner
     * @param addresses array of addresses
     * @param values array of values in wei format (1 PEN = 10^18 wei)
     **/
    function doAirdrop(address[] memory addresses, uint256[] memory values)
        external
        onlyModerators
    {
        uint256 nextBlockTime = rewardBlockTime[address(0)] +
            lastDroppedTime[address(0)];

        require(nextBlockTime <= block.timestamp, "Wait for next reward block");

        for (uint256 i = 0; i < addresses.length; i++) {
            require(
                values[i] <= amountToAirdrop[address(0)],
                "Invalid amount provided"
            );
            payable(addresses[i]).transfer(values[i]);
        }

        lastDroppedTime[address(0)] = block.timestamp;
        emit AirdropTransfer(addresses, values);
    }

    function setAmountToAirdrop(address _token, uint256 _amountToAirdrop)
        external
        onlyOwner
    {
        amountToAirdrop[_token] = _amountToAirdrop;
    }

    function updateSetting(
        address _token,
        uint256 _amountToAirdrop,
        uint256 _rewardBlockTime
    ) external onlyOwner {
        amountToAirdrop[_token] = _amountToAirdrop;
        rewardBlockTime[_token] = _rewardBlockTime;
    }

    function withdrawAll() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawIfAnyNativeBalance(address payable receiver)
        external
        onlyOwner
        returns (uint256)
    {
        uint256 balance = address(this).balance;
        receiver.transfer(balance);
        return balance;
    }

    function withdrawIfAnyTokenBalance(
        address contractAddress,
        address payable receiver
    ) external onlyOwner returns (uint256) {
        IERC20 token = IERC20(contractAddress);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(receiver, balance);
        return balance;
    }

    /**
     * @dev Withraw Tokens by admin
     *
     **/
    function withdrawTokenBalance(
        address _tokenAddress,
        address _recieverAddress
    ) public onlyOwner {
        uint256 airdropContractBalance = IERC20(_tokenAddress).balanceOf(
            address(this)
        );

        require(airdropContractBalance > 0, "Balance is low");
        IERC20(_tokenAddress).transfer(
            _recieverAddress,
            airdropContractBalance
        );
    }
}