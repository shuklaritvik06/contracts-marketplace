import { HardhatUserConfig } from "hardhat/config";
import { config as configureDotEnv } from "dotenv";
import "@nomicfoundation/hardhat-toolbox";
import "solidity-coverage";
import "hardhat-gas-reporter";
configureDotEnv();
const RPC_URL = process.env.RPC_URL;
const ACCOUNT_KEY = process.env.ACCOUNT_ONE;
const CHAIN_ID = parseInt(process.env.CHAIN_ID as string, 10);
const API_KEY = process.env.COIN_MARKET_API_KEY;
const VERIFY_KEY = process.env.VERIFY_KEY;
const config: HardhatUserConfig = {
	solidity: "0.8.17",
	defaultNetwork: "hardhat",
	networks: {
		hardhat: {
			chainId: 1337,
		},
		goerli: {
			url: RPC_URL,
			accounts: [ACCOUNT_KEY as string],
			chainId: CHAIN_ID,
		},
	},
	gasReporter: {
		enabled: true,
		currency: "USD",
		coinmarketcap: API_KEY,
		noColors: true,
		showTimeSpent: true,
		outputFile: "./gas-report.txt",
	},
	mocha: {
		timeout: 500000,
	},
	etherscan: {
		apiKey: VERIFY_KEY,
	},
	typechain: {
		outDir: "./typechain",
	},
};

export default config;
