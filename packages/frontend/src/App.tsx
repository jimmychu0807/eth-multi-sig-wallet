import { Tabs, TabList, TabPanels, Tab, TabPanel } from '@chakra-ui/react'

import { Header } from "./components/Header"
import { Footer } from "./components/Footer"
// import './App.css'

function App() {
  return <>
    <Header />
    <Tabs>
      <TabList>
        <Tab>Main</Tab>
        <Tab>Pending Txs</Tab>
        <Tab>Debug</Tab>
      </TabList>

      <TabPanels>
        <TabPanel>
          Main
        </TabPanel>

        <TabPanel>
          Pending Txs
        </TabPanel>

        <TabPanel>
          Debug
        </TabPanel>
      </TabPanels>
    </Tabs>
    <Footer />
  </>
}

export default App
