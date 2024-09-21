// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IEERC314 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event AddLiquidity(uint32 _blockToUnlockLiquidity, uint256 value);
    event RemoveLiquidity(uint256 value);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out
    );
}

contract Panda314 is IEERC314 {
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _lastTxTime;
    mapping(address => uint32) private lastTransaction;

    uint256 private _totalSupply;

    uint32 public blockToUnlockLiquidity;

    string private _name;
    string private _symbol;

    address public owner;
    address payable public fundAddress;

    uint256 public maxWalletAmount;

    uint256 public _buyFundFee;
    uint256 public buy_burnFee;

    uint256 public _sellFundFee;
    uint256 public sell_burnFee;

    uint256 public liquidityPct;
    uint256 public cooldownSec;

    bool public tradingEnable;
    bool public liquidityAdded;
    bool public enableWalletLimit;

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyLiquidityProvider() {
        require(
            msg.sender == fundAddress,
            "You are not the liquidity provider"
        );
        _;
    }

    function initialize(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) public{
        _name = stringParams[0];
        _symbol = stringParams[1];



        fundAddress = payable(addressParams[0]);
        owner = tx.origin;
        _totalSupply = numberParams[0];
        maxWalletAmount = numberParams[1];

        _buyFundFee = numberParams[2];
        buy_burnFee = numberParams[3];

        _sellFundFee = numberParams[4];
        sell_burnFee = numberParams[5];

        liquidityPct = numberParams[6];
        cooldownSec = numberParams[7];

        enableWalletLimit = boolParams[0];

        uint256 liquidityAmount = (_totalSupply * liquidityPct) / 10000;
        address ReceiveAddress = addressParams[1];
        _balances[ReceiveAddress] = _totalSupply - liquidityAmount;
        
        _balances[address(this)] = liquidityAmount;

        emit Transfer(address(0), address(this), liquidityAmount);
        emit Transfer(address(0), ReceiveAddress, _totalSupply - liquidityAmount);

    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        // sell or transfer
        if (to == address(this)) {
            sell(value);
        } else {
            _transfer(msg.sender, to, value);
        }
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual {
        if (to != address(0)) {
            require(
                lastTransaction[msg.sender] != block.number,
                "You can't make two transactions in the same block"
            );
            lastTransaction[msg.sender] = uint32(block.number);

            require(
                block.timestamp >= _lastTxTime[msg.sender] + cooldownSec,
                "Sender must wait for cooldown"
            );
            _lastTxTime[msg.sender] = block.timestamp;
        }

        require(
            _balances[from] >= value,
            "ERC20: transfer amount exceeds balance"
        );

        unchecked {
            _balances[from] = _balances[from] - value;
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function getReserves() public view returns (uint256, uint256) {
        return (address(this).balance, _balances[address(this)]);
    }


    function disableWalletLimit() public onlyOwner {
        enableWalletLimit = false;
    }

    function changeWalletLimit(uint256 _amount) external onlyOwner {
        maxWalletAmount = _amount;
    }
    function changeCooldownSec(uint256 sec) external onlyOwner {
        cooldownSec = sec;
    }

    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }
    function setFundAddress(address payable addr) external onlyOwner {
        fundAddress = addr;
    }
    function addLiquidity(uint32 _blockToUnlockLiquidity)
        public
        payable
        onlyLiquidityProvider
    {
        require(liquidityAdded == false, "Liquidity already added");

        liquidityAdded = true;

        require(msg.value > 0, "No ETH sent");
        require(block.number < _blockToUnlockLiquidity, "Block number too low");

        blockToUnlockLiquidity = _blockToUnlockLiquidity;
        tradingEnable = true;


        emit AddLiquidity(_blockToUnlockLiquidity, msg.value);
    }

    function removeLiquidity() public onlyLiquidityProvider {
        require(block.number > blockToUnlockLiquidity, "Liquidity locked");

        tradingEnable = false;

        payable(msg.sender).transfer(address(this).balance);

        emit RemoveLiquidity(address(this).balance);
    }

    function extendLiquidityLock(uint32 _blockToUnlockLiquidity)
        public
        onlyLiquidityProvider
    {
        require(
            blockToUnlockLiquidity < _blockToUnlockLiquidity,
            "You can't shorten duration"
        );

        blockToUnlockLiquidity = _blockToUnlockLiquidity;
    }

    function getAmountOut(uint256 value, bool _buy)
        public
        view
        returns (uint256)
    {
        (uint256 reserveETH, uint256 reserveToken) = getReserves();

        if (_buy) {
            return (value * reserveToken) / (reserveETH + value);
        } else {
            return (value * reserveETH) / (reserveToken + value);
        }
    }

    function buy() internal {
        require(tradingEnable, "Trading not enable");

        uint256 msgValue = msg.value;
        uint256 feeValue = (msgValue * _buyFundFee) / 10000;
        uint256 swapValue = msgValue - feeValue;

        fundAddress.transfer(feeValue);

        uint256 token_amount = (swapValue * _balances[address(this)]) /
            (address(this).balance);

        if (enableWalletLimit) {
            require(
                token_amount + _balances[msg.sender] <= maxWalletAmount,
                "Max wallet exceeded"
            );
        }

        uint256 burn_amount = (token_amount * buy_burnFee) / 10000;
        uint256 user_amount = token_amount - burn_amount;
        _transfer(address(this), msg.sender, user_amount);
        _transfer(address(this), address(0), burn_amount);

        emit Swap(msg.sender, swapValue, 0, 0, user_amount);
    }

    function sell(uint256 sell_amount) internal {
        require(tradingEnable, "Trading not enable");

        uint256 burn_amount = (sell_amount * sell_burnFee) / 10000;
        uint256 swap_amount = sell_amount - burn_amount;

        uint256 ethAmount = (swap_amount * address(this).balance) /
            (_balances[address(this)] + swap_amount);

        require(ethAmount > 0, "Sell amount too low");
        require(
            address(this).balance >= ethAmount,
            "Insufficient ETH in reserves"
        );

        _transfer(msg.sender, address(this), swap_amount);
        _transfer(msg.sender, address(0), burn_amount);

        uint256 feeValue = (ethAmount * _sellFundFee) / 10000;
        payable(fundAddress).transfer(feeValue);
        payable(msg.sender).transfer(ethAmount - feeValue);

        emit Swap(msg.sender, 0, sell_amount, ethAmount - feeValue, 0);
    }

    receive() external payable {
        buy();
    }
}
