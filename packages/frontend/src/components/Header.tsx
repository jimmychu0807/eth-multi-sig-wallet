import { Box } from '@chakra-ui/react';
import { Web3Button, Web3NetworkSwitch } from "@web3modal/react";

function Header() {
  return <>
    <Box w="100%">
      <Web3NetworkSwitch />
    </Box>
  </>
}

export {
  Header
}
