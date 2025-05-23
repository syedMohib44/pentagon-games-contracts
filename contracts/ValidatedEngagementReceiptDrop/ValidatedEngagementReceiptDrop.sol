import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {BasicAccessControl} from "../shared/BasicAccessControl.sol";
import {Freezable} from "../shared/Freezable.sol";

/**
 * Validated User Engagement EchoVault Gas Provision Contract
 */
contract ValidatedEngagementReceiptDrop is BasicAccessControl {
    event AirdropTransfer(
        address indexed tokenAddress,
        address[] indexed addresses,
        uint256[] indexed values
    );

    event AirdropTransfer(
        address[] indexed addresses,
        uint256[] indexed values
    );

    //0.001
    mapping(address => uint256) public amountToAirdrop;
    mapping(address => uint256) public airdropped;

    uint256 public maxDrop = 1;

    receive() external payable {}

    /**
     * @dev Airdrop Tokens to user addresses and called by only owner
     * @param addresses array of addresses
     * @param values array of values in wei format (1 PEN = 10^18 wei)
     **/
    function doAirdrop(
        address[] memory addresses,
        uint256[] memory values
    ) external onlyModerators {
        for (uint256 i = 0; i < addresses.length; i++) {
            require(
                airdropped[addresses[i]] < maxDrop,
                "Already airdropped to User"
            );

            require(
                values[i] <= amountToAirdrop[address(0)],
                "Invalid amount provided"
            );
            payable(addresses[i]).transfer(values[i]);
            airdropped[addresses[i]]++;
        }

        emit AirdropTransfer(addresses, values);
    }

    function setMaxDrop(uint256 _maxDrop) external onlyOwner {
        maxDrop = _maxDrop;
    }

    function setAmountToAirdrop(
        address _token,
        uint256 _amountToAirdrop
    ) external onlyOwner {
        amountToAirdrop[_token] = _amountToAirdrop;
    }

    function withdrawAll() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawIfAnyNativeBalance(
        address payable receiver
    ) external onlyOwner returns (uint256) {
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
