//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol';


contract Merit is ERC20PresetMinterPauser, Ownable {
    using SafeMath for uint256;
    
    uint256 public constant MAX_SUPPLY = 20000 ether;

    // ------------------------
    // CONSTRUCTOR
    // ------------------------

    constructor () ERC20PresetMinterPauser('Merit Vault', 'MERIT') {
        // Silence
    }


    // ------------------------
    // INTERNAL
    // ------------------------

    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= MAX_SUPPLY, '_mint: Cap exceeded!');

        super._mint(account, amount);
    }

}