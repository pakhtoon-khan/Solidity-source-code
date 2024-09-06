// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract OTPSystem {
    using SafeMath for uint256;

    struct User {
        string username;
        address publicKey;
        uint256 otpSeed;
        uint256 lastOtpTimestamp;
    }

    mapping(address => User) public users;
    mapping(address => uint256) public lastOtpGenerated;

    event UserRegistered(address indexed user, string username);
    event OtpGenerated(address indexed user, uint256 otp);
    event UserAuthenticated(address indexed user, bool success);

    modifier onlyRegistered() {
        require(bytes(users[msg.sender].username).length > 0, "User not registered");
        _;
    }

    function register(string memory _username, uint256 _otpSeed) public {
        require(bytes(users[msg.sender].username).length == 0, "User already registered");
        users[msg.sender] = User(_username, msg.sender, _otpSeed, block.timestamp);
        emit UserRegistered(msg.sender, _username);
    }

    function generateOtp() public onlyRegistered returns (uint256) {
        User storage user = users[msg.sender];
        uint256 currentTime = block.timestamp;
        require(currentTime > user.lastOtpTimestamp + 30 seconds, "OTP can only be generated every 30 seconds");

        uint256 otp = uint256(keccak256(abi.encodePacked(user.otpSeed, currentTime))) % 1000000; // 6-digit OTP
        user.lastOtpTimestamp = currentTime;
        lastOtpGenerated[msg.sender] = otp;

        emit OtpGenerated(msg.sender, otp);
        return otp;
    }

    function authenticate(uint256 _otp) public onlyRegistered returns (bool) {
        require(block.timestamp <= users[msg.sender].lastOtpTimestamp + 30 seconds, "OTP expired");
        bool isAuthenticated = (lastOtpGenerated[msg.sender] == _otp);
        emit UserAuthenticated(msg.sender, isAuthenticated);
        return isAuthenticated;
    }
}   