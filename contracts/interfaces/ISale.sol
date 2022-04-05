//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;


interface ISale {
    function addPrivateSales(address[] memory investors, uint256[] memory amounts) external;
    function mint(address team, address development, address reserve) external;
    function getUserDeposits(address user) external view returns (uint256);
}