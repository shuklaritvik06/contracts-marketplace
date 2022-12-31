import { ethers } from "hardhat";
import {
	NFT__factory,
	Marketplace__factory,
	NFT,
	Marketplace,
} from "../typechain";
import verify from "../utils/verify";

async function main() {
	const logger = new ethers.utils.Logger("v1.0.0");
	const MarketPlaceFactory: Marketplace__factory =
		await ethers.getContractFactory("Marketplace");
	logger.info("Deploying Marketplace...");
	const MarketPlace: Marketplace = await MarketPlaceFactory.deploy();
	logger.info("Marketplace deployed to:", MarketPlace.address);
	const MarketPlaceDeployed = await MarketPlace.deployed();
	const NFTTokenFactory: NFT__factory = await ethers.getContractFactory("NFT");
	logger.info("Deploying NFTToken...");
	const NFTToken: NFT = await NFTTokenFactory.deploy(MarketPlace.address);
	const NFTTokenDeployed = await NFTToken.deployed();
	logger.info("NFTToken deployed to:", NFTToken.address);
	await verify(NFTTokenDeployed.address, [MarketPlaceDeployed.address]);
	await verify(MarketPlaceDeployed.address, []);
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
