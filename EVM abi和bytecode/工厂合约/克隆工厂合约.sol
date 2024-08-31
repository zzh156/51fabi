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

contract PandaTokenFactory {
    using Clones for address;

    address public immutable template;
    address public feeRecipient = 0x1B7557295D94937f30AC3D0D4198B5C27F32Ca58;
    uint256 public constant creationFee = 0.025 ether;

    struct CreatedContract {
        address creator;
        address contractAddress;
    }

    CreatedContract[] public createdContracts;

    event PandaTokenCreated(address indexed creator, address tokenAddress, string name, string symbol, uint256 decimals, uint256 initialSupply);

    constructor(address _template) {
        require(_template != address(0), "Template address cannot be zero");
        template = _template;
    }

    function createPandaToken(
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
        createdContracts.push(CreatedContract({
            creator: msg.sender,
            contractAddress: clone
        }));

        // 转移费用到指定地址
        (bool success, ) = feeRecipient.call{value: msg.value}("");
        require(success, "Fee transfer failed");

        emit PandaTokenCreated(msg.sender, clone, name, symbol, decimals, initialSupply);
        return clone;
    }

    function getCreatedContracts() external view returns (CreatedContract[] memory) {
        return createdContracts;
    }
}
