// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/proxy/Clones.sol";

interface IPandaToken {
    function initialize(
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 initialSupply_,
        address owner_
    ) external;
}

contract StandardTokenFactory {
    using Clones for address;

    address public immutable template;
    address public feeRecipient = 0x2fa5fBC3472F75A99559F9e6A0aD02cd7132a3c0;
    uint256 public constant creationFee = 0.025 ether;

    struct CreatedContract {
        address creator;
        address contractAddress;
        string protocolType;
        uint256 creationTime;  // 添加时间戳字段
    }

    CreatedContract[] public createdContracts;
    mapping(address => CreatedContract[]) public contractsByCreator;

    event StandardTokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol,
        uint256 decimals,
        uint256 initialSupply,
        string protocolType  // 记录代币协议类型
    );

    constructor(address _template) {
        require(_template != address(0), "Template address cannot be zero");
        template = _template;
    }

    function createStandardToken(
        string memory name,
        string memory symbol,
        uint256 decimals,
        uint256 initialSupply
    ) external payable returns (address) {
        require(msg.value == creationFee, "Incorrect fee");

        // 创建克隆合约
        address clone = template.clone();

        // 初始化克隆合约
        IPandaToken(clone).initialize(name, symbol, decimals, initialSupply, msg.sender);

        // 记录创建的合约信息
        string memory protocolType = "Standard Token";  // 自动设置协议类型为标准代币
        uint256 creationTime = block.timestamp;  // 记录时间戳
        CreatedContract memory newContract = CreatedContract({
            creator: msg.sender,
            contractAddress: clone,
            protocolType: protocolType,
            creationTime: creationTime
        });
        createdContracts.push(newContract);
        contractsByCreator[msg.sender].push(newContract);

        // 转移费用到指定地址
        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");

        emit StandardTokenCreated(msg.sender, clone, name, symbol, decimals, initialSupply, protocolType);
        return clone;
    }

    // 修改后的函数，返回包含合约地址和代币类型的结构体数组
    function getContractsByCreator(address creator) external view returns (CreatedContract[] memory) {
        return contractsByCreator[creator];
    }

    function getCreatedContracts() external view returns (CreatedContract[] memory) {
        return createdContracts;
    }
}
