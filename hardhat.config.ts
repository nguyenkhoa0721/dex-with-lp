import { HardhatUserConfig } from "hardhat/config";
import dotenv from "dotenv";
import "@nomicfoundation/hardhat-toolbox";

dotenv.config({ path: ".env" });

const QUICKNODE_API = process.env.QUICKNODE_HTTP_URL as string;
const PRIVATE_KEY = process.env.PRIVATE_KEY as string;

const config: HardhatUserConfig = {
    solidity: "0.8.17",
    networks: {
        goerli: {
            url: QUICKNODE_API,
            accounts: [PRIVATE_KEY],
        },
    },
};

export default config;
