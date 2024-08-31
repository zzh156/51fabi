// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/proxy/Clones.sol";

interface IStandardToken {
    function initialize(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external;
}

interface IDividendToken {
    function initialize(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external;
}

contract MiddleContract {
    using Clones for address;

    address public immutable standardTokenTemplate;
    address public immutable dividendTokenTemplate;
    address payable public feeRecipient = payable(0x1B7557295D94937f30AC3D0D4198B5C27F32Ca58);

    struct CreatedContract {
        address creator;
        address contractAddress;
        string contractType;
    }

    CreatedContract[] public createdContracts;

    // Fees in wei
    uint256 public standardTokenFee = 0.025 ether;
    uint256 public dividendTokenFee = 0.035 ether;

    // Event for contract creation
    event ContractCreated(address indexed creator, address newContract, string contractType);

    constructor(address _standardTokenTemplate, address _dividendTokenTemplate) {
        require(_standardTokenTemplate != address(0), "Standard Token template cannot be zero address");
        require(_dividendTokenTemplate != address(0), "Dividend Token template cannot be zero address");
        standardTokenTemplate = _standardTokenTemplate;
        dividendTokenTemplate = _dividendTokenTemplate;
    }

    // Function modifiers to check correct payment
    modifier paidCorrectAmount(uint256 fee) {
        require(msg.value == fee, "Incorrect payment amount");
        _;
    }

    function createStandardToken(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable paidCorrectAmount(standardTokenFee) {
        address clone = standardTokenTemplate.clone();
        IStandardToken(clone).initialize(stringParams, addressParams, numberParams, boolParams);

        createdContracts.push(CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            contractType: "Standard Token"
        }));

        emit ContractCreated(msg.sender, clone, "Standard Token");

        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");
    }

    function createDividendToken(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external payable paidCorrectAmount(dividendTokenFee) {
        address clone = dividendTokenTemplate.clone();
        IDividendToken(clone).initialize(stringParams, addressParams, numberParams, boolParams);

        createdContracts.push(CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            contractType: "Dividend Token"
        }));

        emit ContractCreated(msg.sender, clone, "Dividend Token");

        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");
    }

    function getCreatedContracts() external view returns (CreatedContract[] memory) {
        return createdContracts;
    }
}
