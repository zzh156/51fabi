// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/proxy/Clones.sol";

interface IPandaStandardToken {
    function initialize(
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 initialSupply_,
        address owner_
    ) external;
}


interface IPandaLPDividendToken {
    function initialize(
        string[] memory stringParams, // 包含name和symbol的数组
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external;
}

interface IPandaLPDividendReferralToken {
    function initialize(
        string[] memory stringParams, 
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external;
}

interface IPandaLPMiningReferralToken {
    function initialize(
        string[] memory stringParams, 
        address[] memory addressParams, 
        uint256[] memory numberParams, 
        bool[] memory boolParams
    ) external;
}

contract TokenFactory {
    using Clones for address;

    address public immutable standardTokenTemplate;
    address public immutable lpDividendTokenTemplate;
    address public immutable lpDividendReferralTokenTemplate;
    address public immutable lpMiningReferralTokenTemplate;
    address public feeRecipient = 0x2fa5fBC3472F75A99559F9e6A0aD02cd7132a3c0;

    struct CreatedContract {
        address creator;
        address contractAddress;
        string protocolType;
        uint256 creationTime;  // 添加时间戳字段
    }

    CreatedContract[] public createdContracts;
    mapping(address => CreatedContract[]) public contractsByCreator;

    // 定义不同协议的费用标准
    uint256 public constant standardTokenFee = 0.5 ether;
    uint256 public constant lpDividendTokenFee = 1 ether;
    uint256 public constant lpDividendReferralTokenFee = 1 ether;
    uint256 public constant lpMiningReferralTokenFee = 2 ether;

    event StandardTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 decimals,
        uint256 initialSupply,
        string protocolType,
        uint256 creationTime  // 添加时间戳
    );

 

    event LPDividendTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 decimals,
        uint256 tTotal,
        string protocolType,
        uint256 creationTime  // 添加时间戳
    );

    event LPDividendReferralTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 decimals,
        uint256 tTotal,
        string protocolType,
        uint256 creationTime  // 添加时间戳
    );

   

    

    event LPMiningReferralTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 totalSupply,
        string protocolType,
        uint256 creationTime  // 添加时间戳
    );

   

   

    constructor(
        address _standardTokenTemplate,
        address _lpDividendTokenTemplate,
        address _lpDividendReferralTokenTemplate, 
        address _lpMiningReferralTokenTemplate
    ) {
        standardTokenTemplate = _standardTokenTemplate;
        lpDividendTokenTemplate = _lpDividendTokenTemplate;
        lpDividendReferralTokenTemplate = _lpDividendReferralTokenTemplate;
        lpMiningReferralTokenTemplate = _lpMiningReferralTokenTemplate;
    }

    function createStandardToken(
        string memory name,
        string memory symbol,
        uint256 decimals,
        uint256 initialSupply
    ) external payable returns (address) {
        require(msg.value == standardTokenFee, "Incorrect fee");

        address clone = standardTokenTemplate.clone();
        IPandaStandardToken(clone).initialize(name, symbol, decimals, initialSupply, msg.sender);

        string memory protocolType = "Standard Token";
        uint256 creationTime = block.timestamp;  // 记录时间戳
        CreatedContract memory newContract = CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            protocolType: protocolType,
            creationTime: creationTime
        });
        createdContracts.push(newContract);
        contractsByCreator[msg.sender].push(newContract);

        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");

        emit StandardTokenCreated(msg.sender, clone, name, symbol, decimals, initialSupply, protocolType, creationTime);
        return clone;
    }


    function createLPDividendToken(
        string[] memory stringParams, // 包含name和symbol的数组
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable returns (address) {
        require(msg.value == lpDividendTokenFee, "Incorrect fee");

        address clone = lpDividendTokenTemplate.clone();
        IPandaLPDividendToken(clone).initialize(stringParams, addressParams, numberParams, boolParams);

        string memory protocolType = "LP Dividend Token";
        uint256 creationTime = block.timestamp;  // 记录时间戳
        CreatedContract memory newContract = CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            protocolType: protocolType,
            creationTime: creationTime
        });
        createdContracts.push(newContract);
        contractsByCreator[msg.sender].push(newContract);

        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");

        emit LPDividendTokenCreated(msg.sender, clone, stringParams[0], stringParams[1], numberParams[0], numberParams[1], protocolType, creationTime);
        return clone;
    }

    function createLPDividendReferralToken(
        string[] memory stringParams, 
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable returns (address) {
        require(msg.value == lpDividendReferralTokenFee, "Incorrect fee");

        address clone = lpDividendReferralTokenTemplate.clone();
        IPandaLPDividendReferralToken(clone).initialize(stringParams, addressParams, numberParams, boolParams);

        string memory protocolType = "LP Dividend + Referral Token";
        uint256 creationTime = block.timestamp;  // 记录时间戳
        CreatedContract memory newContract = CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            protocolType: protocolType,
            creationTime: creationTime
        });
        createdContracts.push(newContract);
        contractsByCreator[msg.sender].push(newContract);

        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");

        emit LPDividendReferralTokenCreated(msg.sender, clone, stringParams[0], stringParams[1], numberParams[0], numberParams[1], protocolType, creationTime);
        return clone;
    }

    
    

    function createLPMiningReferralToken(
        string[] memory stringParams, 
        address[] memory addressParams, 
        uint256[] memory numberParams, 
        bool[] memory boolParams
    ) external payable returns (address) {
        require(msg.value == lpMiningReferralTokenFee, "Incorrect fee");

        address clone = lpMiningReferralTokenTemplate.clone();
        IPandaLPMiningReferralToken(clone).initialize(stringParams, addressParams, numberParams, boolParams);

        string memory protocolType = "LP Mining + Referral Token";
        uint256 creationTime = block.timestamp;  // 记录时间戳
        CreatedContract memory newContract = CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            protocolType: protocolType,
            creationTime: creationTime
        });
        createdContracts.push(newContract);
        contractsByCreator[msg.sender].push(newContract);

        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");

        emit LPMiningReferralTokenCreated(msg.sender, clone, stringParams[0], stringParams[1], numberParams[0], protocolType, creationTime);
        return clone;
    }

    

   

    function getContractsByCreator(address creator) external view returns (CreatedContract[] memory) {
        return contractsByCreator[creator];
    }

    function getCreatedContracts() external view returns (CreatedContract[] memory) {
        return createdContracts;
    }
}
