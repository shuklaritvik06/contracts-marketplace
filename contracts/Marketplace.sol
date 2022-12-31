// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title A NFT Contract
 * @author Ritvik Shukla
 * @notice This contract is used to mint the tokens
 * @dev All function calls are currently implemented without side effects
 */
contract Marketplace is ReentrancyGuard {
	using Counters for Counters.Counter;
	Counters.Counter private _itemId;
	Counters.Counter private _soldId;
	address payable owner;
	uint256 listingPrice = 0.03 ether;

	constructor() {
		owner = payable(msg.sender);
	}

	/**
	 * @dev Market Item Struct
	 */
	struct MarketItem {
		uint256 itemId;
		address nftContract;
		uint256 tokenId;
		address payable seller;
		address payable owner;
		uint256 price;
		bool sold;
	}
	mapping(uint256 => MarketItem) private idToMarketItem;

	/**
	 * @dev Event that will be emitted on a Item Creation
	 */
	event MarketItemCreated(
		uint256 itemId,
		address nftContract,
		uint256 tokenId,
		address seller,
		address owner,
		uint256 price,
		bool sold
	);

	/**
	 * @dev This function will return the listing price of this contract
	 */
	function getListingPrice() public view returns (uint256) {
		return listingPrice;
	}

	/**
	 * @notice This function will create the market item
	 * @dev Non Reentrant modifier to prevent a Reentry Attack for creating item
	 * @param nftContract The address of the NFT Contract
	 * @param tokenId The token ID of the NFT
	 * @param price The price of the NFT
	 * @custom:learning The address(0) is used to create a null address in the owner place that noone currently hold this
	 * @return The item ID
	 */
	function createMarketItem(
		address nftContract,
		uint256 tokenId,
		uint256 price
	) public payable nonReentrant returns (uint256) {
		require(price > 0, "Price must be greater than 0");
		require(msg.value == listingPrice, "Price be more than listing");
		_itemId.increment();
		uint256 itemId = _itemId.current();
		idToMarketItem[itemId] = MarketItem(
			itemId,
			nftContract,
			tokenId,
			payable(msg.sender),
			payable(address(0)),
			price,
			false
		);

		/**
		 * @dev This will transfer the current token to the contract address
		 */
		IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
		emit MarketItemCreated(
			itemId,
			nftContract,
			tokenId,
			msg.sender,
			address(0),
			price,
			false
		);
		return itemId;
	}

	/**
	 * @notice This function will return the market item
	 * @param itemId The item ID
	 * @param nftContract The address of the NFT contract
	 * @dev Non Reentrant modifier to prevent a Reentry Attack for creating item
	 */

	function createMarketSale(address nftContract, uint256 itemId)
		public
		payable
		nonReentrant
	{
		uint256 price = idToMarketItem[itemId].price;
		uint256 tokenId = idToMarketItem[itemId].tokenId;
		require(msg.value == price, "Less than asking price");
		idToMarketItem[itemId].seller.transfer(msg.value);

		/**
		 * @dev This will transfer the current token to the buyers address who sent the message
		 */
		IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
		idToMarketItem[itemId].owner = payable(msg.sender);
		idToMarketItem[itemId].sold = true;
		_soldId.increment();
		payable(owner).transfer(listingPrice);
	}

	/**
	 * @notice This function will return the market item
	 * @param itemId The item ID
	 * @return The market item
	 */
	function fetchMarketItem(uint256 itemId)
		public
		view
		returns (MarketItem memory)
	{
		return idToMarketItem[itemId];
	}

	/**
	 * @notice This function will return the market items
	 * @return The market items
	 */
	function fetchMarketItems() public view returns (MarketItem[] memory) {
		uint256 itemCount = _itemId.current();
		uint256 unsoldItemCount = _itemId.current() - _soldId.current();
		uint256 currentIndex = 0;
		/**
		 * @dev This will create a array with the length of unsoldItemCount
		 */
		MarketItem[] memory items = new MarketItem[](unsoldItemCount);
		for (uint256 i = 0; i < itemCount; i++) {
			if (idToMarketItem[i + 1].owner == address(0)) {
				uint256 currentId = idToMarketItem[i + 1].itemId;
				MarketItem storage currentItem = idToMarketItem[currentId];
				items[currentIndex] = currentItem;
				currentIndex += 1;
			}
		}
		return items;
	}

	/**
	 * @notice This function will return the market items you hold
	 * @return The market items you hold
	 */

	function fetchMyNFTs() public view returns (MarketItem[] memory) {
		uint256 totalItemCount = _itemId.current();
		uint256 itemCount = 0;
		uint256 currentIndex = 0;
		for (uint256 i = 0; i < totalItemCount; i++) {
			if (idToMarketItem[i + 1].owner == msg.sender) {
				itemCount += 1;
			}
		}
		MarketItem[] memory items = new MarketItem[](itemCount);
		for (uint256 i = 0; i < totalItemCount; i++) {
			if (idToMarketItem[i + 1].owner == msg.sender) {
				uint256 currentId = idToMarketItem[i + 1].itemId;
				MarketItem storage currentItem = idToMarketItem[currentId];
				items[currentIndex] = currentItem;
				currentIndex += 1;
			}
		}
		return items;
	}

	/**
	 * @notice This function will return the market items you have created
	 * @return The market items you have created
	 */

	function fetchItemsCreated() public view returns (MarketItem[] memory) {
		uint256 totalItemCount = _itemId.current();
		uint256 itemCount = 0;
		uint256 currentIndex = 0;
		for (uint256 i = 0; i < totalItemCount; i++) {
			if (idToMarketItem[i + 1].seller == msg.sender) {
				itemCount += 1;
			}
		}
		MarketItem[] memory items = new MarketItem[](itemCount);
		for (uint256 i = 0; i < totalItemCount; i++) {
			if (idToMarketItem[i + 1].seller == msg.sender) {
				uint256 currentId = idToMarketItem[i + 1].itemId;
				MarketItem storage currentItem = idToMarketItem[currentId];
				items[currentIndex] = currentItem;
				currentIndex += 1;
			}
		}
		return items;
	}
}
