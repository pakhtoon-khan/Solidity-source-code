// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract BlumeLiquidStaking is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable BLS; 
    mapping(address => uint256) public stakedBalances; 
    address[] public stakers; 

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    constructor(address _BLS) ERC20("Staked BLS", "stBLS") {
        require(_BLS != address(0), "BLS token address cannot be zero");
        BLS = IERC20(_BLS);
    }

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        BLS.safeTransferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
        stakedBalances[msg.sender] += amount;

        
        if (stakedBalances[msg.sender] == amount) {
            stakers.push(msg.sender); 
        }

        emit Staked(msg.sender, amount);
    }
    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient stBLS balance");
        _burn(msg.sender, amount);
        BLS.safeTransfer(msg.sender, amount);
        stakedBalances[msg.sender] -= amount;

        emit Unstaked(msg.sender, amount);
    }

      function getTotalStaked(address user) external view returns (uint256) {
        return stakedBalances[user];
    }

    function getStakers() external view returns (address[] memory) {
        return stakers;
    }
}