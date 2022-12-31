import { ethers } from "hardhat";
import {
	Marketplace,
	Marketplace__factory,
	NFT,
	NFT__factory,
} from "../typechain";
import { assert } from "chai";

describe("Marketplace Tests", function () {
	let MarketplaceFactory: Marketplace__factory;
	let marketplace: Marketplace;
	let NFTTokenFactory: NFT__factory;
	let NFTContract: NFT;
	const logger = new ethers.utils.Logger("v1.0.0");
	this.beforeAll(async () => {
		MarketplaceFactory = (await ethers.getContractFactory(
			"Marketplace"
		)) as Marketplace__factory;
		marketplace = await MarketplaceFactory.deploy();
		marketplace = await marketplace.deployed();
		NFTTokenFactory = (await ethers.getContractFactory("NFT")) as NFT__factory;
		NFTContract = await NFTTokenFactory.deploy(marketplace.address);
		logger.info(`Marketplace Contract deployed at ${marketplace.address}`);
		logger.info(`NFT Contract deployed at ${NFTContract.address}`);
	});
	it("Should be able to create an item and sell", async function () {
		const listingPrice = await marketplace.getListingPrice();
		const auction = ethers.utils.parseUnits("10", "ether");
		await NFTContract.createToken("https://via.placeholder.com/200");
		await NFTContract.createToken("https://via.placeholder.com/300");
		await NFTContract.createToken("https://via.placeholder.com/500");
		await marketplace.createMarketItem(NFTContract.address, 1, auction, {
			value: listingPrice,
		});
		await marketplace.createMarketItem(NFTContract.address, 2, auction, {
			value: listingPrice,
		});
		const [_, buyerAddress] = await ethers.getSigners();
		await marketplace
			.connect(buyerAddress)
			.createMarketSale(NFTContract.address, 1, {
				value: auction,
			});
	});
	it("Should be able to get an item with id", async function () {
		const item = await marketplace.fetchMarketItem(1);
		assert(parseInt(item.itemId.toString()) !== 0, "Not found any item");
		logger.info(`Got an item with id ${item.itemId}`);
	});
	it("Should be able to get market items", async function () {
		const [sellerAddress, _] = await ethers.getSigners();
		const items = await marketplace.connect(sellerAddress).fetchMarketItems();
		assert(items.length !== 0, "No items found");
		logger.info(`Got the items ${items}`);
	});
	it("Should be able to fetch all items created", async function () {
		const [sellerAddress, _] = await ethers.getSigners();
		const items = await marketplace.connect(sellerAddress).fetchItemsCreated();
		assert(items.length !== 0, "No items found");
		logger.info(`Got the items ${items}`);
	});
	it("Should be able to fetch all bought items", async function () {
		const [_, buyerAddress] = await ethers.getSigners();
		const items = await marketplace.connect(buyerAddress).fetchMyNFTs();
		assert(items.length !== 0, "No items found");
		logger.info(`Got the items ${items}`);
	});
});
