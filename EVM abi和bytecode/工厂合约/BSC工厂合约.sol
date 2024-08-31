// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";

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

interface ITokenTemplate {
    function initialize(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external;
}

contract MiddleContract {
    using Clones for address;

    address payable public feeRecipient = payable(0x1B7557295D94937f30AC3D0D4198B5C27F32Ca58);

    address public standardTokenTemplate;
    address public dividendTokenTemplate;
    address public presaleTemplate;
    address public lpDividendTemplate;
    address public lpDividendReferralTemplate;
    address public protocol314Template;
    address public compoundReferralTemplate;
    address public mintViolentDividendTemplate;
    address public mintBurnPoolTemplate;
    address public lpMiningReferralTemplate;

    // Fees in wei
    uint256 public standardTokenFee = 0.04 ether;
    uint256 public dividendTokenFee = 0.05 ether;
    uint256 public presaleFee = 0.08 ether;
    uint256 public lpDividendFee = 0.09 ether;
    uint256 public lpDividendReferralFee = 0.1 ether;
    uint256 public protocol314Fee = 0.12 ether;
    uint256 public compoundReferralFee = 0.14 ether;
    uint256 public mintViolentDividendFee = 0.13 ether;
    uint256 public mintBurnPoolFee = 0.15 ether;
    uint256 public lpMiningReferralFee = 0.18 ether;

    event ContractCreated(address creator, address newContract, string contractType);

    constructor(
        address _standardTokenTemplate,
        address _dividendTokenTemplate,
        address _presaleTemplate,
        address _lpDividendTemplate,
        address _lpDividendReferralTemplate,
        address _protocol314Template,
        address _compoundReferralTemplate,
        address _mintViolentDividendTemplate,
        address _mintBurnPoolTemplate,
        address _lpMiningReferralTemplate
    ) {
        standardTokenTemplate = _standardTokenTemplate;
        dividendTokenTemplate = _dividendTokenTemplate;
        presaleTemplate = _presaleTemplate;
        lpDividendTemplate = _lpDividendTemplate;
        lpDividendReferralTemplate = _lpDividendReferralTemplate;
        protocol314Template = _protocol314Template;
        compoundReferralTemplate = _compoundReferralTemplate;
        mintViolentDividendTemplate = _mintViolentDividendTemplate;
        mintBurnPoolTemplate = _mintBurnPoolTemplate;
        lpMiningReferralTemplate = _lpMiningReferralTemplate;
    }

    function createToken(
        address template,
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams,
        uint256 fee,
        string memory contractType
    ) internal returns (address) {
        require(msg.value == fee, "Incorrect payment amount");

        address clone = template.clone();
        ITokenTemplate(clone).initialize(stringParams, addressParams, numberParams, boolParams);

        emit ContractCreated(msg.sender, clone, contractType);

        feeRecipient.transfer(msg.value);

        return clone;
    }

    function createStandardToken(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable {
        createToken(standardTokenTemplate, stringParams, addressParams, numberParams, boolParams, standardTokenFee, "Standard Token");
    }

    function createDividendToken(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable {
        createToken(dividendTokenTemplate, stringParams, addressParams, numberParams, boolParams, dividendTokenFee, "Dividend Token");
    }

    function createPresale(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable {
        createToken(presaleTemplate, stringParams, addressParams, numberParams, boolParams, presaleFee, "Presale");
    }

    function createLPDividend(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable {
        createToken(lpDividendTemplate, stringParams, addressParams, numberParams, boolParams, lpDividendFee, "LP Dividend");
    }

    function createLPDividendReferral(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable {
        createToken(lpDividendReferralTemplate, stringParams, addressParams, numberParams, boolParams, lpDividendReferralFee, "LP Dividend + Referral");
    }

    function createProtocol314(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable {
        createToken(protocol314Template, stringParams, addressParams, numberParams, boolParams, protocol314Fee, "Protocol 314");
    }

    function createCompoundReferral(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable {
        createToken(compoundReferralTemplate, stringParams, addressParams, numberParams, boolParams, compoundReferralFee, "Compound + Referral");
    }

    function createMintViolentDividend(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams
    ) external payable {
        createToken(mintViolentDividendTemplate, stringParams, addressParams, numberParams, new bool , mintViolentDividendFee, "Mint + Violent Dividend");
    }

    function createMintBurnPool(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable {
        createToken(mintBurnPoolTemplate, stringParams, addressParams, numberParams, boolParams, mintBurnPoolFee, "Mint + Burn Pool");
    }

    function createLPMiningReferral(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable {
        createToken(lpMiningReferralTemplate, stringParams, addressParams, numberParams, boolParams, lpMiningReferralFee, "LP Mining + Referral");
    }
}
