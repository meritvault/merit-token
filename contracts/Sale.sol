//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import { InvestorsVesting, IVesting } from './InvestorsVesting.sol';
import './CliffVesting.sol';
import './interfaces/ISale.sol';
import './interfaces/IMerit.sol';


contract Sale is ISale, Ownable {
    using SafeMath for uint256;

    IMerit public meritToken;
    IVesting public immutable vesting;

    address public reserveLockContract;                                                      
    address public developmentLockContract;
    address public teamLockContract;
   
    uint256 public constant PRIVATE_Sale_LOCK_PERCENT = 1000; // 10% of tokens

    mapping(address => uint256) internal _deposits;
    event Deposited(address indexed user, uint256 amount);


    // ------------------------
    // CONSTRUCTOR
    // ------------------------

    constructor(address meritToken_) {
        require(meritToken_ != address(0), 'Sale: Empty token address!');
        meritToken = IMerit(meritToken_);

        address vestingAddr = address(new InvestorsVesting(meritToken_));
        vesting = IVesting(vestingAddr);
    }

    // ------------------------
    // SETTERS (OWNABLE)   
    // ------------------------

    /// @notice Admin can manually add private sale investors with this method
    /// @dev It can be called ONLY during private sale, also lengths of addresses and investments should be equal
    /// @param investors Array of investors addresses
    /// @param amounts Tokens Amount which investors needs to receive 
    function addPrivateSales(address[] memory investors, uint256[] memory amounts) external override onlyOwner {
        require(investors.length > 0, 'addPrivateSales: Array can not be empty!');
        require(investors.length == amounts.length, 'addPrivateSales: Arrays should have the same length!');

        vesting.submitMulti(investors, amounts, PRIVATE_Sale_LOCK_PERCENT);
    }



 
    /// @notice Mint and lock tokens for team, development, reserve
    /// @dev Only admin can call it once.
    function mintSales(address teamReceiver, address developmentReceiver, address reserveReceiver) external override {
        require(developmentReceiver != address(0) && reserveReceiver != address(0) && teamReceiver != address(0), 'mintSales: Can not be zero address!');
        require(developmentLockContract == address(0) && reserveLockContract == address(0) && teamLockContract == address(0), 'mintSales: Already locked!');
  
        teamLockContract = address(new CliffVesting(teamReceiver, 60 days, 720 days, address(meritToken)));    //  1 month cliff  24 months vesting
        developmentLockContract = address(new CliffVesting(developmentReceiver, 60 days, 365 days, address(meritToken)));      //  30 days cliff   12 months vesting
        reserveLockContract = address(new CliffVesting(reserveReceiver, 60 days, 720 days, address(meritToken)));        //  2 months cliff 2 years vesting

        meritToken.mint(teamLockContract, 10000 ether);  // 10k tokens
        meritToken.mint(developmentLockContract, 10000 ether);  // 10k tokens
        meritToken.mint(reserveLockContract, 30000 ether);    // 30k tokens
    }

    // ------------------------
    // GETTERS
    // ------------------------

    /// @notice Returns how much user invested during sale
    /// @param user address
    function getUserDeposits(address user) external override view returns (uint256) {
        return _deposits[user];
    }
 }
