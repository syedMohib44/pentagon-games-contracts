interface IEFG {
    function mint(address to) external returns (uint256);

    function setTransferable(uint256 tokenId, bool enabled) external;

    function isTransferable(uint256 tokenId) external view returns (bool);
}
