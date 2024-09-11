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
        string [] memory stringparams,
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
    address public feeRecipient = 0xD40d9FdcA22ab26CE2f313fE9bFd5894c4a13a6d;

    struct CreatedContract {
        address creator;
        address contractAddress;
        string protocolType;  
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
        string protocolType
    );

    event DividendTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 decimals,
        uint256 tTotal,
        string protocolType
    );

    event LPDividendTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 decimals,
        uint256 tTotal,
        string protocolType
    );

    event LPDividendReferralTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 decimals,
        uint256 tTotal,
        string protocolType
    );

    event MintBrutalDividendTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 totalSupply,
        string protocolType
    );

    event MintPoolBurnTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 totalSupply,
        string protocolType
    );

    event LPMiningReferralTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 totalSupply,
        string protocolType
    );

    event CompoundingReferralTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 totalSupply,
        string protocolType
    );

    event Panda314Created(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 totalSupply,
        string protocolType
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
        CreatedContract memory newContract = CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            protocolType: protocolType
        });
        createdContracts.push(newContract);
        contractsByCreator[msg.sender].push(newContract);

        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");

        emit StandardTokenCreated(msg.sender, clone, name, symbol, decimals, initialSupply, protocolType);
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
        CreatedContract memory newContract = CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            protocolType: protocolType
        });
        createdContracts.push(newContract);
        contractsByCreator[msg.sender].push(newContract);

        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");

        emit DividendTokenCreated(msg.sender, clone, name, symbol, decimals, tTotal, protocolType);
        return clone;
    }


    function createLPDividendToken(
        string[] memory stringParams, // 包含name和symbol的数组
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable returns (address) {
        require(msg.value == lpDividendTokenFee, "Incorrect fee");

        // 克隆模板
        address clone = lpDividendTokenTemplate.clone();
        
        // 调用克隆合约的初始化方法，传入四个数组
        IPandaLPDividendToken(clone).initialize(stringParams, addressParams, numberParams, boolParams);

        // 定义协议类型
        string memory protocolType = "LP Dividend Token";
        
        // 记录新创建的合约
        CreatedContract memory newContract = CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            protocolType: protocolType
        });
        
        // 将新合约加入创建记录中
        createdContracts.push(newContract);
        contractsByCreator[msg.sender].push(newContract);

        // 转移手续费给接收者
        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");

        // 触发事件
        emit LPDividendTokenCreated(msg.sender, clone, stringParams[0], stringParams[1], numberParams[0], numberParams[1], protocolType);
        
        // 返回克隆合约地址
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
        CreatedContract memory newContract = CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            protocolType: protocolType
        });
        createdContracts.push(newContract);
        contractsByCreator[msg.sender].push(newContract);

        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");

        emit LPDividendReferralTokenCreated(msg.sender, clone, stringParams[0], stringParams[1], numberParams[0], numberParams[1], protocolType);
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
        CreatedContract memory newContract = CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            protocolType: protocolType
        });
        createdContracts.push(newContract);
        contractsByCreator[msg.sender].push(newContract);

        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");

        emit MintBrutalDividendTokenCreated(msg.sender, clone, stringParams[0], stringParams[1], numberParams[0], protocolType);
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
        CreatedContract memory newContract = CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            protocolType: protocolType
        });
        createdContracts.push(newContract);
        contractsByCreator[msg.sender].push(newContract);

        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");

        emit MintPoolBurnTokenCreated(msg.sender, clone, stringParams[0], stringParams[1], numberParams[0], protocolType);
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
        CreatedContract memory newContract = CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            protocolType: protocolType
        });
        createdContracts.push(newContract);
        contractsByCreator[msg.sender].push(newContract);

        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");

        emit LPMiningReferralTokenCreated(msg.sender, clone, stringParams[0], stringParams[1], numberParams[0], protocolType);
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
        CreatedContract memory newContract = CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            protocolType: protocolType
        });
        createdContracts.push(newContract);
        contractsByCreator[msg.sender].push(newContract);

        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");

        emit CompoundingReferralTokenCreated(msg.sender, clone, stringParams[0], stringParams[1], numberParams[0], protocolType);
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
        CreatedContract memory newContract = CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            protocolType: protocolType
        });
        createdContracts.push(newContract);
        contractsByCreator[msg.sender].push(newContract);

        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");

        emit Panda314Created(msg.sender, clone, stringParams[0], stringParams[1], numberParams[0], protocolType);
        return clone;
    }

    function getContractsByCreator(address creator) external view returns (CreatedContract[] memory) {
        return contractsByCreator[creator];
    }

    function getCreatedContracts() external view returns (CreatedContract[] memory) {
        return createdContracts;
    }
}
