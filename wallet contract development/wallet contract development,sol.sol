// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOracle {
    function verifyOTP(address user, string memory otp) external returns (bool);
    function verifyBiometric(address user, bytes memory biometricData) external returns (bool);
}

contract SmartWallet {
    address public owner;
    string private passcode;
    
    IOracle public otpOracle;
    IOracle public biometricOracle;
    
    event FundsDeposited(address indexed user, uint amount);
    event FundsTransferred(address indexed to, uint amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the wallet owner.");
        _;
    }
    
    modifier verifyPasscode(string memory _passcode) {
        require(keccak256(abi.encodePacked(_passcode)) == keccak256(abi.encodePacked(passcode)), "Invalid passcode.");
        _;
    }
    
    constructor(address _otpOracle, address _biometricOracle, string memory _passcode) {
        owner = msg.sender;
        otpOracle = IOracle(_otpOracle);
        biometricOracle = IOracle(_biometricOracle);
        passcode = _passcode;
    }

    function deposit() external payable onlyOwner {
        emit FundsDeposited(msg.sender, msg.value);
    }
    
    function transferFundsWithOTP(address payable _to, uint _amount, string memory otp, string memory _passcode) 
        public 
        onlyOwner 
        verifyPasscode(_passcode) 
    {
        require(otpOracle.verifyOTP(msg.sender, otp), "OTP verification failed.");
        require(_amount <= address(this).balance, "Insufficient balance.");
        _to.transfer(_amount);
        emit FundsTransferred(_to, _amount);
    }
    
    function transferFundsWithBiometric(address payable _to, uint _amount, bytes memory biometricData, string memory _passcode) 
        public 
        onlyOwner 
        verifyPasscode(_passcode) 
    {
        require(biometricOracle.verifyBiometric(msg.sender, biometricData), "Biometric verification failed.");
        require(_amount <= address(this).balance, "Insufficient balance.");
        _to.transfer(_amount);
        emit FundsTransferred(_to, _amount);
    }
    
    function withdrawAll(string memory _passcode) 
        public 
        onlyOwner 
        verifyPasscode(_passcode) 
    {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
        emit FundsTransferred(msg.sender, balance);
    }

    // Change Passcode
    function changePasscode(string memory oldPasscode, string memory newPasscode) 
        public 
        onlyOwner 
        verifyPasscode(oldPasscode) 
    {
        passcode = newPasscode;
    }
    
    // Fallback function to receive Ether
    receive() external payable {
        emit FundsDeposited(msg.sender, msg.value);
    }
}