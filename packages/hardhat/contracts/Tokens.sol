// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";

contract Tokens is ERC1155PresetMinterPauser {
  uint256 public constant MAIN_CURRENCY = 0;
  bytes32 public constant admin = keccak256("DEFAULT_ADMIN_ROLE");

  constructor() ERC1155PresetMinterPauser("https://some-kind-of-uri.json") {
    grantRole(admin, msg.sender);
    _mint(msg.sender, MAIN_CURRENCY, 10**18, "");
  }
}
