// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MiddleContract {
    address payable public feeRecipient = payable(0x1B7557295D94937f30AC3D0D4198B5C27F32Ca58);
    mapping(address => bool) public createdContracts;

    // Event for contract creation
    event ContractCreated(address creator, address newContract, string contractType);

    // Fees in wei
    uint256 public standardTokenFee = 0.04 ether;
    uint256 public dividendTokenFee = 0.05 ether;
    uint256 public presaleFee = 0.08 ether;
    uint256 public lpDividendFee = 0.09 ether;
    uint256 public lpDividendReferralFee = 0.1 ether;
    uint256 public compoundReferralFee = 0.13 ether;
    uint256 public lpMiningReferralFee = 0.18 ether;

    // Function modifiers to check correct payment
    modifier paidCorrectAmount(uint256 fee) {
        require(msg.value == fee, "Incorrect payment amount");
        _;
    }

    // Function to create contracts using bytecode and transfer ownership to caller
    function _createContract(bytes memory bytecode, bytes memory constructorArgs) internal returns (address) {
        bytes memory code = abi.encodePacked(bytecode, constructorArgs);
        address addr;
        assembly {
            addr := create(0, add(code, 0x20), mload(code))
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
        createdContracts[addr] = true;
        return addr;
    }

    function encodeParams(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) internal pure returns (bytes memory) {
        return abi.encode(stringParams, addressParams, numberParams, boolParams);
    }

    function createPresale(
        bytes memory bytecode,
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable paidCorrectAmount(presaleFee) {
        bytes memory constructorArgs = encodeParams(stringParams, addressParams, numberParams, boolParams);
        address newContract = _createContract(bytecode, constructorArgs);
        
        emit ContractCreated(msg.sender, newContract, "Presale");
        feeRecipient.transfer(msg.value);
    }

    function createStandardToken(
        bytes memory bytecode,
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable paidCorrectAmount(standardTokenFee) {
        bytes memory constructorArgs = encodeParams(stringParams, addressParams, numberParams, boolParams);
        address newContract = _createContract(bytecode, constructorArgs);
        
        IERC20(newContract).transfer(msg.sender, IERC20(newContract).balanceOf(address(this)));
        emit ContractCreated(msg.sender, newContract, "Standard Token");
        feeRecipient.transfer(msg.value);
    }

    function createDividendToken(
        bytes memory bytecode,
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable paidCorrectAmount(dividendTokenFee) {
        bytes memory constructorArgs = encodeParams(stringParams, addressParams, numberParams, boolParams);
        address newContract = _createContract(bytecode, constructorArgs);
        
        IERC20(newContract).transfer(msg.sender, IERC20(newContract).balanceOf(address(this)));
        emit ContractCreated(msg.sender, newContract, "Dividend Token");
        feeRecipient.transfer(msg.value);
    }

    function createLPDividend(
        bytes memory bytecode,
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable paidCorrectAmount(lpDividendFee) {
        bytes memory constructorArgs = encodeParams(stringParams, addressParams, numberParams, boolParams);
        address newContract = _createContract(bytecode, constructorArgs);
        
        IERC20(newContract).transfer(msg.sender, IERC20(newContract).balanceOf(address(this)));
        emit ContractCreated(msg.sender, newContract, "LP Dividend");
        feeRecipient.transfer(msg.value);
    }

    function createLPDividendReferral(
        bytes memory bytecode,
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable paidCorrectAmount(lpDividendReferralFee) {
        bytes memory constructorArgs = encodeParams(stringParams, addressParams, numberParams, boolParams);
        address newContract = _createContract(bytecode, constructorArgs);
        
        IERC20(newContract).transfer(msg.sender, IERC20(newContract).balanceOf(address(this)));
        emit ContractCreated(msg.sender, newContract, "LP Dividend + Referral");
        feeRecipient.transfer(msg.value);
    }

    function createProtocol314(
        bytes memory bytecode,
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable paidCorrectAmount(protocol314Fee) {
        bytes memory constructorArgs = encodeParams(stringParams, addressParams, numberParams, boolParams);
        address newContract = _createContract(bytecode, constructorArgs);
        
        IERC20(newContract).transfer(msg.sender, IERC20(newContract).balanceOf(address(this)));
        emit ContractCreated(msg.sender, newContract, "Protocol 314");
        feeRecipient.transfer(msg.value);
    }

    function createCompoundReferral(
        bytes memory bytecode,
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable paidCorrectAmount(compoundReferralFee) {
        bytes memory constructorArgs = encodeParams(stringParams, addressParams, numberParams, boolParams);
        address newContract = _createContract(bytecode, constructorArgs);
        
        IERC20(newContract).transfer(msg.sender, IERC20(newContract).balanceOf(address(this)));
        emit ContractCreated(msg.sender, newContract, "Compound + Referral");
        feeRecipient.transfer(msg.value);
    }

    function createMintViolentDividend(
        bytes memory bytecode,
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams
    ) external payable paidCorrectAmount(mintViolentDividendFee) {
        bytes memory constructorArgs = abi.encode(stringParams, addressParams, numberParams);
        address newContract = _createContract(bytecode, constructorArgs);
        
        IERC20(newContract).transfer(msg.sender, IERC20(newContract).balanceOf(address(this)));
        emit ContractCreated(msg.sender, newContract, "Mint + Violent Dividend");
        feeRecipient.transfer(msg.value);
    }

    function createMintBurnPool(
        bytes memory bytecode,
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable paidCorrectAmount(mintBurnPoolFee) {
        bytes memory constructorArgs = encodeParams(stringParams, addressParams, numberParams, boolParams);
        address newContract = _createContract(bytecode, constructorArgs);
        
        IERC20(newContract).transfer(msg.sender, IERC20(newContract).balanceOf(address(this)));
        emit ContractCreated(msg.sender, newContract, "Mint + Burn Pool");
        feeRecipient.transfer(msg.value);
    }

    function createLPMiningReferral(
        bytes memory bytecode,
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable paidCorrectAmount(lpMiningReferralFee) {
        bytes memory constructorArgs = encodeParams(stringParams, addressParams, numberParams, boolParams);
        address newContract = _createContract(bytecode, constructorArgs);
        
        IERC20(newContract).transfer(msg.sender, IERC20(newContract).balanceOf(address(this)));
        emit ContractCreated(msg.sender, newContract, "LP Mining + Referral");
        feeRecipient.transfer(msg.value);
    }
}
