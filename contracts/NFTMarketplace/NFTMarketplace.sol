// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

contract NFTMarketplace is Ownable, ReentrancyGuard {
    constructor() Ownable(msg.sender) {}
    struct Listing {
        address seller;
        address collection;
        uint256 price;
        address paymentToken;
        uint256 expiry;
    }
    struct Bid {
        uint256 bidId; // Unique ID generated off-chain
        address bidder;
        uint256 price;
        uint256 size;
        string trait; // Specific trait for the bid
        address paymentToken;
        address collection; // Associated collection
    }

    uint256 public bidCounter;
    mapping(address => bool) public whitelistedCollections;
    mapping(address => mapping(uint256 => Listing)) public listings;
    mapping(uint256 => Bid) public collectionBids;
    mapping(address => uint256) public marketplaceFees; // Admin-configured marketplace fees
    mapping(address => bool) public whitelistedPaymentTokens;
    event NFTListed(
        address indexed collection,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price,
        address paymentToken,
        uint256 expiry
    );
    event NFTSold(
        address indexed collection,
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price,
        address paymentToken
    );
    event NFTBidPlaced(
        uint256 indexed bidId,
        address indexed collection,
        address indexed bidder,
        uint256 price,
        uint256 size,
        string trait,
        address paymentToken
    );
    event CollectionWhitelisted(address indexed collection, bool status);
    event MarketplaceFeeUpdated(address indexed collection, uint256 fee);
    event FundsWithdrawn(address indexed admin, uint256 amount);
    event NFTBidCancelled(uint256 indexed bidId);
    event NFTListingCancelled(
        address indexed collection,
        uint256 indexed tokenId
    );
    event NFTBidAccepted(
        uint256 indexed bidId,
        address indexed collection,
        address indexed bidder,
        uint256 price,
        address paymentToken
    );
    modifier onlyWhitelisted(address collection) {
        require(
            whitelistedCollections[collection],
            "Collection not whitelisted"
        );
        _;
    }

    function whitelistCollection(address collection, bool status)
        external
        onlyOwner
    {
        whitelistedCollections[collection] = status;
        emit CollectionWhitelisted(collection, status);
    }

    function whitelistPaymentToken(address token, bool status)
        external
        onlyOwner
    {
        whitelistedPaymentTokens[token] = status;
    }

    function setMarketplaceFee(address collection, uint256 fee)
        external
        onlyOwner
    {
        marketplaceFees[collection] = fee;
        emit MarketplaceFeeUpdated(collection, fee);
    }

    function listNFTs(
        address collection,
        uint256[] calldata tokenIds,
        uint256[] calldata prices,
        address paymentToken,
        uint256[] calldata expiries
    ) external onlyWhitelisted(collection) {
        require(tokenIds.length > 0, "Must list at least one NFT");
        require(
            tokenIds.length == prices.length &&
                tokenIds.length == expiries.length,
            "Token IDs, prices, and expiries length mismatch"
        );
        require(
            IERC721(collection).isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved"
        );
        require(
            whitelistedPaymentTokens[paymentToken],
            "Payment token not whitelisted"
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(prices[i] > 0, "Price must be greater than 0");
            require(
                expiries[i] > block.timestamp,
                "Expiry must be in the future"
            );
            require(
                IERC721(collection).ownerOf(tokenIds[i]) == msg.sender,
                "Not NFT owner"
            );
            listings[collection][tokenIds[i]] = Listing(
                msg.sender,
                collection,
                prices[i],
                paymentToken,
                expiries[i]
            );
            emit NFTListed(
                collection,
                tokenIds[i],
                msg.sender,
                prices[i],
                paymentToken,
                expiries[i]
            );
        }
    }

    // implement cancel listing
    function cancelListing(address collection, uint256[] calldata tokenIds)
        external
        onlyWhitelisted(collection)
    {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                listings[collection][tokenIds[i]].seller == msg.sender,
                "Not listing owner"
            );
            delete listings[collection][tokenIds[i]];
            emit NFTListingCancelled(collection, tokenIds[i]);
        }
    }

    function buyNFT(address collection, uint256[] calldata tokenIds)
        external
        payable
        nonReentrant
        onlyWhitelisted(collection)
    {
        uint256 totalPrice = 0;
        address paymentToken = address(0);

        // Calculate total price (NFT price + fee + royalty) for all tokens.
        for (uint256 i = 0; i < tokenIds.length; i++) {
            Listing memory item = listings[collection][tokenIds[i]];
            require(item.seller != address(0), "NFT not listed");
            require(block.timestamp <= item.expiry, "NFT listing expired");

            // Use the payment token of the first listing for all items.
            if (i == 0) paymentToken = item.paymentToken;
            require(
                paymentToken == item.paymentToken,
                "Payment token mismatch"
            );

            uint256 fee = (marketplaceFees[collection] * item.price) / 10000;
            uint256 royaltyAmount;
            address royaltyReceiver;
            if (
                IERC2981(collection).supportsInterface(
                    type(IERC2981).interfaceId
                )
            ) {
                (royaltyReceiver, royaltyAmount) = IERC2981(collection)
                    .royaltyInfo(tokenIds[i], item.price);
            }
            totalPrice = totalPrice + item.price + fee + royaltyAmount;
        }

        // Process payment based on token type.
        if (paymentToken == address(0)) {
            require(msg.value >= totalPrice, "Insufficient ETH sent");
        } else {
            require(
                IERC20(paymentToken).transferFrom(
                    msg.sender,
                    address(this),
                    totalPrice
                ),
                "Token transfer failed"
            );
        }

        // Process each NFT purchase.
        for (uint256 i = 0; i < tokenIds.length; i++) {
            Listing memory item = listings[collection][tokenIds[i]];
            uint256 fee = (marketplaceFees[collection] * item.price) / 10000;
            uint256 royaltyAmount = 0;
            address royaltyReceiver = address(0);
            if (
                IERC2981(collection).supportsInterface(
                    type(IERC2981).interfaceId
                )
            ) {
                (royaltyReceiver, royaltyAmount) = IERC2981(collection)
                    .royaltyInfo(tokenIds[i], item.price);
            }
            uint256 sellerProceeds = item.price - fee - royaltyAmount;
            if (paymentToken == address(0)) {
                // Distribute ETH funds.
                if (royaltyAmount > 0) {
                    (bool royaltyPaid, ) = payable(royaltyReceiver).call{
                        value: royaltyAmount
                    }("");
                    require(royaltyPaid, "Royalty payment failed");
                }
                (bool feePaid, ) = payable(owner()).call{value: fee}("");
                require(feePaid, "Fee transfer failed");
                (bool sellerPaid, ) = payable(item.seller).call{
                    value: sellerProceeds
                }("");
                require(sellerPaid, "Seller transfer failed");
            } else {
                // Distribute ERC20 tokens.
                if (royaltyAmount > 0) {
                    require(
                        IERC20(paymentToken).transfer(
                            royaltyReceiver,
                            royaltyAmount
                        ),
                        "Royalty token transfer failed"
                    );
                }
                require(
                    IERC20(paymentToken).transfer(owner(), fee),
                    "Fee token transfer failed"
                );
                require(
                    IERC20(paymentToken).transfer(item.seller, sellerProceeds),
                    "Seller token transfer failed"
                );
            }

            // Transfer NFT ownership and remove the listing.
            IERC721(collection).safeTransferFrom(
                item.seller,
                msg.sender,
                tokenIds[i]
            );
            delete listings[collection][tokenIds[i]];
            emit NFTSold(
                collection,
                tokenIds[i],
                msg.sender,
                item.price,
                paymentToken
            );
        }
    }

    function placeBid(
        address collection,
        uint256 price,
        uint256 size,
        string calldata trait,
        address paymentToken
    ) external onlyWhitelisted(collection) {
        require(price > 0, "Invalid price");
        require(size > 0, "Invalid size");
        require(paymentToken != address(0), "Invalid payment token");
        require(
            whitelistedPaymentTokens[paymentToken],
            "Payment token not whitelisted"
        );
        // --- BALANCE CHECK ---
        require(
            IERC20(paymentToken).balanceOf(msg.sender) >= price * size,
            "Insufficient balance"
        );
        // --- FULL ALLOWANCE CHECK ---
        uint256 requiredAllowance = price * size;
        require(
            IERC20(paymentToken).allowance(msg.sender, address(this)) >=
                requiredAllowance,
            "Payment token allowance too low for full bid size"
        );
        bidCounter++;
        collectionBids[bidCounter] = Bid(
            bidCounter,
            msg.sender,
            price,
            size,
            trait,
            paymentToken,
            collection // Store collection association
        );
        emit NFTBidPlaced(
            bidCounter,
            collection,
            msg.sender,
            price,
            size,
            trait,
            paymentToken
        );
    }

    function acceptBid(
        address collection,
        uint256 bidId,
        uint256[] calldata tokenIds
    ) external nonReentrant onlyWhitelisted(collection) {
        // 1. Basic checks
        require(collectionBids[bidId].size > 0, "Invalid bid index");
        Bid memory bid = collectionBids[bidId];
        require(bid.collection == collection, "Bid collection mismatch");
        require(
            tokenIds.length > 0 && tokenIds.length <= bid.size,
            "Invalid token count"
        );

        // Ensure seller actually owns and has approved these NFTs
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                IERC721(collection).ownerOf(tokenIds[i]) == msg.sender,
                "Not NFT owner"
            );
            require(
                IERC721(collection).isApprovedForAll(msg.sender, address(this)),
                "Marketplace not approved"
            );
        }

        // 2. Calculate total payment required (bid.price + fee + royalty for each NFT)
        uint256 totalPaymentRequired = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            // Marketplace fee is a percentage of the bid price
            uint256 fee = (marketplaceFees[collection] * bid.price) / 10000;

            // Fetch royalties if collection supports ERC2981
            uint256 royaltyAmount = 0;
            address royaltyReceiver = address(0);
            if (
                IERC2981(collection).supportsInterface(
                    type(IERC2981).interfaceId
                )
            ) {
                (royaltyReceiver, royaltyAmount) = IERC2981(collection)
                    .royaltyInfo(tokenIds[i], bid.price);
            }

            // Add up the cost of this single token sale
            // total cost = bid.price + fee + royalty
            totalPaymentRequired += (bid.price + fee + royaltyAmount);
        }

        // 3. Pull totalPaymentRequired from bidder into this contract
        require(
            IERC20(bid.paymentToken).transferFrom(
                bid.bidder,
                address(this),
                totalPaymentRequired
            ),
            "Payment transfer failed"
        );

        // 4. Distribute payments & transfer NFTs one by one
        for (uint256 i = 0; i < tokenIds.length; i++) {
            // Recompute fee and royalty for each token
            uint256 fee = (marketplaceFees[collection] * bid.price) / 10000;
            uint256 royaltyAmount = 0;
            address royaltyReceiver = address(0);
            if (
                IERC2981(collection).supportsInterface(
                    type(IERC2981).interfaceId
                )
            ) {
                (royaltyReceiver, royaltyAmount) = IERC2981(collection)
                    .royaltyInfo(tokenIds[i], bid.price);
            }

            // Seller gets whatever remains after fee + royalty
            uint256 sellerProceeds = bid.price - fee - royaltyAmount;

            // Pay royalty if owed
            if (royaltyAmount > 0) {
                require(
                    IERC20(bid.paymentToken).transfer(
                        royaltyReceiver,
                        royaltyAmount
                    ),
                    "Royalty transfer failed"
                );
            }

            // Pay marketplace fee
            if (fee > 0) {
                require(
                    IERC20(bid.paymentToken).transfer(owner(), fee),
                    "Fee transfer failed"
                );
            }

            // Pay seller
            require(
                IERC20(bid.paymentToken).transfer(msg.sender, sellerProceeds),
                "Seller proceeds transfer failed"
            );

            // Transfer the NFT to the bidder
            IERC721(collection).safeTransferFrom(
                msg.sender,
                bid.bidder,
                tokenIds[i]
            );
        }

        // 5. Remove the bid entry and emit event
        delete collectionBids[bidId];
        emit NFTBidAccepted(
            bidId,
            collection,
            bid.bidder,
            // totalPaymentRequired is the total spent by bidder
            totalPaymentRequired,
            bid.paymentToken
        );
    }

    // implement cancel bid
    function cancelBid(uint256 bidId) external {
        require(collectionBids[bidId].bidder == msg.sender, "Not bid owner");
        delete collectionBids[bidId];
        emit NFTBidCancelled(bidId);
    }

    // implement withdraw funds
    function withdrawFunds(address token, uint256 amount) external onlyOwner {
        if (token == address(0)) {
            require(
                address(this).balance >= amount,
                "Insufficient ETH balance"
            );
            (bool success, ) = payable(msg.sender).call{value: amount}("");
            require(success, "ETH withdrawal failed");
        } else {
            require(
                IERC20(token).balanceOf(address(this)) >= amount,
                "Insufficient token balance"
            );
            require(
                IERC20(token).transfer(msg.sender, amount),
                "Token withdrawal failed"
            );
        }
        emit FundsWithdrawn(msg.sender, amount);
    }
}
