// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IBlockchain_Superheroes {
    function mintNextToken(address _owner, uint256 _tokenId) external returns (bool);

    function totalSupply() external view returns (uint256);

    function cap() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);
}
