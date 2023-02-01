import {
  EthereumClient,
  modalConnectors,
  walletConnectProvider,
} from "@web3modal/ethereum";

import { Web3Modal } from "@web3modal/react";
import { configureChains, createClient, WagmiConfig } from "wagmi";
import { goerli, localhost } from "wagmi/chains";

const chains = [goerli, localhost];
const { provider } = configureChains(chains, [
  walletConnectProvider({ projectId: import.meta.env.VITE_WALLET_CONNECT_PROJECT_ID }),
]);

const wagmiClient = createClient({
  autoConnect: true,
  connectors: modalConnectors({ appName: "Multi Sig Wallet", chains }),
  provider,
});

const ethereumClient = new EthereumClient(wagmiClient, chains);

export {
  ethereumClient,
  wagmiClient,
  chains,
}
