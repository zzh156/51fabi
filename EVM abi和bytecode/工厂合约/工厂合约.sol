
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
