// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEchoVault_Distributor {
    event Mint(address _owner, uint256 token);

    function registerToken(
        address _owner,
        address _erc20
    ) external payable returns (bool);

    function setContracts(address _blockchainSuperheroes) external;

    function togglePausePEN() external;

    function togglePauseERC20() external;

    function updatePENPrice(uint256 _nativePriceNFT) external;

    function updateERC20Price(uint256 _erc20PriceNFT) external;

    function adminWithdraw(uint256 _amount) external;

    function adminWithdrawERC20(address _token, uint256 _amount) external;

    function setMintingCap(uint256 _mintingCap) external;

    function mintingCount() external view returns (uint256);

    function mintingCap() external view returns (uint256);

    function nativePriceNFT() external view returns (uint256);

    function erc20PriceNFT() external view returns (uint256);

    function _mintingPausedNative() external view returns (bool);

    function _mintingPausedERC20() external view returns (bool);

    function userERC20(address user) external view returns (address);
}
