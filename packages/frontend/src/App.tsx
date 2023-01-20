import { Tabs, TabList, TabPanels, Tab, TabPanel } from '@chakra-ui/react'

// import './App.css'

function App() {

  return <Tabs>
    <TabList>
      <Tab>Main</Tab>
      <Tab>Pending Txs</Tab>
      <Tab>Debug</Tab>
    </TabList>

    <TabPanels>
      <TabPanel>
        <p>Main</p>
      </TabPanel>

      <TabPanel>
        Pending Txs
      </TabPanel>

      <TabPanel>
        Debug
      </TabPanel>
    </TabPanels>
  </Tabs>
}

export default App
