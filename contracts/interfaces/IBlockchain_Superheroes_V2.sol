// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IBlockchain_Superheroes_V2 {
    function mintNextToken(address _owner) external returns (bool);

    function currentToken() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function cap() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);
}
