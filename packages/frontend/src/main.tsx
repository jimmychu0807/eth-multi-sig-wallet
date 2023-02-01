import React from 'react'
import ReactDOM from 'react-dom/client'
import { ChakraProvider, extendTheme } from '@chakra-ui/react'
import { WagmiConfig } from "wagmi"
import { Web3Modal } from "@web3modal/react"
import { wagmiClient, ethereumClient } from "./components/web3Modal"

import App from './App'
// import './index.css'

// Extending the theme
const colors = {
  brand: {
    900: '#1a365d',
    800: '#153e75',
    700: '#2a69ac',
  },
};

const theme = extendTheme({ colors });

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <ChakraProvider theme={theme}>
      <WagmiConfig client={wagmiClient}>
        <App />
      </WagmiConfig>

      <Web3Modal
        projectId={import.meta.env.VITE_WALLET_CONNECT_PROJECT_ID}
        ethereumClient={ ethereumClient }
      />
    </ChakraProvider>
  </React.StrictMode>,
)
