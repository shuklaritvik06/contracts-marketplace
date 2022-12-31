import { run } from "hardhat";
const verify = async (contractAddress: string, args: Array<any>) => {
	console.log("Verifying contract...");
	try {
		await run("verify:verify", {
			address: contractAddress,
			constructorArguments: args,
		});
	} catch (e: unknown) {
		console.log("Error while verifying contract:", e);
	}
};

export default verify;
