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

interface IPandaDividendToken {
    function initialize(
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 tTotal_,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
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

interface IPandaMintBrutalDividendToken {
    function initialize(
        string[] memory stringParams, 
        address[] memory addressParams, 
        uint256[] memory numberParams
    ) external;
}

interface IPandaMintPoolBurnToken {
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

interface IPandaCompoundingReferralToken {
    function initialize(
        string[] memory stringParams, 
        address[] memory addressParams,
        uint256[] memory numberParams, 
        bool[] memory boolParams
    ) external;
}

interface IPanda314 {
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
    address public immutable dividendTokenTemplate;
    address public immutable lpDividendTokenTemplate;
    address public immutable lpDividendReferralTokenTemplate;
    address public immutable mintBrutalDividendTokenTemplate;
    address public immutable mintPoolBurnTokenTemplate;
    address public immutable lpMiningReferralTokenTemplate;
    address public immutable compoundingReferralTokenTemplate;
    address public immutable panda314Template;
    address public feeRecipient = 0x3C8601461C71d83Ae71B480B5cA4ecAFf1923B58;

    struct CreatedContract {
        address creator;
        address contractAddress;
        string protocolType;
        uint256 creationTime;  // 添加时间戳字段
    }

    CreatedContract[] public createdContracts;
    mapping(address => CreatedContract[]) public contractsByCreator;

    // 定义不同协议的费用标准
    uint256 public constant standardTokenFee = 0.04 ether;
    uint256 public constant dividendTokenFee = 0.05 ether;
    uint256 public constant lpDividendTokenFee = 0.1 ether;
    uint256 public constant lpDividendReferralTokenFee = 0.11 ether;
    uint256 public constant panda314Fee = 0.12 ether;
    uint256 public constant compoundingReferralTokenFee = 0.14 ether;
    uint256 public constant mintBrutalDividendTokenFee = 0.13 ether;
    uint256 public constant mintPoolBurnTokenFee = 0.15 ether;
    uint256 public constant lpMiningReferralTokenFee = 0.18 ether;

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

    event DividendTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 decimals,
        uint256 tTotal,
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

    event MintBrutalDividendTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 totalSupply,
        string protocolType,
        uint256 creationTime  // 添加时间戳
    );

    event MintPoolBurnTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 totalSupply,
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

    event CompoundingReferralTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 totalSupply,
        string protocolType,
        uint256 creationTime  // 添加时间戳
    );

    event Panda314Created(
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
        address _dividendTokenTemplate,
        address _lpDividendTokenTemplate,
        address _lpDividendReferralTokenTemplate,
        address _mintBrutalDividendTokenTemplate,
        address _mintPoolBurnTokenTemplate,
        address _lpMiningReferralTokenTemplate,
        address _compoundingReferralTokenTemplate,
        address _panda314Template
    ) {
        standardTokenTemplate = _standardTokenTemplate;
        dividendTokenTemplate = _dividendTokenTemplate;
        lpDividendTokenTemplate = _lpDividendTokenTemplate;
        lpDividendReferralTokenTemplate = _lpDividendReferralTokenTemplate;
        mintBrutalDividendTokenTemplate = _mintBrutalDividendTokenTemplate;
        mintPoolBurnTokenTemplate = _mintPoolBurnTokenTemplate;
        lpMiningReferralTokenTemplate = _lpMiningReferralTokenTemplate;
        compoundingReferralTokenTemplate = _compoundingReferralTokenTemplate;
        panda314Template = _panda314Template;
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

    function createDividendToken(
        string memory name,
        string memory symbol,
        uint256 decimals,
        uint256 tTotal,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable returns (address) {
        require(msg.value == dividendTokenFee, "Incorrect fee");

        address clone = dividendTokenTemplate.clone();
        IPandaDividendToken(clone).initialize(name, symbol, decimals, tTotal, addressParams, numberParams, boolParams);

        string memory protocolType = "Dividend Token";
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

        emit DividendTokenCreated(msg.sender, clone, name, symbol, decimals, tTotal, protocolType, creationTime);
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

    function createMintBrutalDividendToken(
        string[] memory stringParams, 
        address[] memory addressParams, 
        uint256[] memory numberParams
    ) external payable returns (address) {
        require(msg.value == mintBrutalDividendTokenFee, "Incorrect fee");

        address clone = mintBrutalDividendTokenTemplate.clone();
        IPandaMintBrutalDividendToken(clone).initialize(stringParams, addressParams, numberParams);

        string memory protocolType = "Mint+Brutal Dividend Token";
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

        emit MintBrutalDividendTokenCreated(msg.sender, clone, stringParams[0], stringParams[1], numberParams[0], protocolType, creationTime);
        return clone;
    }

    function createMintPoolBurnToken(
        string[] memory stringParams, 
        address[] memory addressParams, 
        uint256[] memory numberParams, 
        bool[] memory boolParams
    ) external payable returns (address) {
        require(msg.value == mintPoolBurnTokenFee, "Incorrect fee");

        address clone = mintPoolBurnTokenTemplate.clone();
        IPandaMintPoolBurnToken(clone).initialize(stringParams, addressParams, numberParams, boolParams);

        string memory protocolType = "Mint+Pool Burn Token";
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

        emit MintPoolBurnTokenCreated(msg.sender, clone, stringParams[0], stringParams[1], numberParams[0], protocolType, creationTime);
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

    function createCompoundingReferralToken(
        string[] memory stringParams, 
        address[] memory addressParams,
        uint256[] memory numberParams, 
        bool[] memory boolParams
    ) external payable returns (address) {
        require(msg.value == compoundingReferralTokenFee, "Incorrect fee");

        address clone = compoundingReferralTokenTemplate.clone();
        IPandaCompoundingReferralToken(clone).initialize(stringParams, addressParams, numberParams, boolParams);

        string memory protocolType = "Compounding + Referral Token";
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

        emit CompoundingReferralTokenCreated(msg.sender, clone, stringParams[0], stringParams[1], numberParams[0], protocolType, creationTime);
        return clone;
    }

    function createPanda314Token(
        string[] memory stringParams, 
        address[] memory addressParams,
        uint256[] memory numberParams, 
        bool[] memory boolParams
    ) external payable returns (address) {
        require(msg.value == panda314Fee, "Incorrect fee");

        address clone = panda314Template.clone();
        IPanda314(clone).initialize(stringParams, addressParams, numberParams, boolParams);

        string memory protocolType = "314 Token";
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

        emit Panda314Created(msg.sender, clone, stringParams[0], stringParams[1], numberParams[0], protocolType, creationTime);
        return clone;
    }

    function getContractsByCreator(address creator) external view returns (CreatedContract[] memory) {
        return contractsByCreator[creator];
    }

    function getCreatedContracts() external view returns (CreatedContract[] memory) {
        return createdContracts;
    }
}
