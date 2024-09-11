
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address _spender, uint _value) external;

    function transferFrom(address _from, address _to, uint _value) external ;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface ISwapPair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function skim(address to) external;
    
    function sync() external;
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}
interface IWBNB {
    function withdraw(uint wad) external; //unwarp WBNB -> BNB
}

contract PandaToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address payable public fundAddress;

    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 public kb;
    uint256 public maxWalletAmount;
    
    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _rewardList;


    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public currency;
    mapping(address => bool) public _swapPairList;

    bool public antiSYNC = true;
    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee;
    uint256 public _buyLPFee;
    uint256 public buy_burnFee;

    uint256 public _sellFundFee;
    uint256 public _sellLPFee;
    uint256 public sell_burnFee;

    uint256 public addLiquidityFee;
    uint256 public removeLiquidityFee;

    uint256 public airdropNumbs;
    bool public currencyIsEth;

    uint256 public startTradeBlock;

    uint256 public numTokensSellRate = 20; // 100%

    address public _mainPair;
    uint256 public lastLpBurnTime;
    uint256 public lpBurnRate;
    uint256 public lpBurnFrequency;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    bool public enableOffTrade;
    bool public enableKillBlock;
    bool public enableRewardList;
    bool public enableWalletLimit;
    bool public enableChangeTax;
    bool public airdropEnable;

    uint256 public price;
    uint256 public minted;
    uint256 public amountPerUnits;
    uint256 public mintLimit;

     function initialize(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) external {
        

        _name = stringParams[0];
        _symbol = stringParams[1];
        _decimals = numberParams[0];
        _tTotal = numberParams[1];
        maxWalletAmount = numberParams[2];

        fundAddress = payable(addressParams[0]);
        currency = addressParams[1];
        _swapRouter = ISwapRouter(addressParams[2]);
        address ReceiveAddress = addressParams[3];

        enableOffTrade = boolParams[0];
        enableKillBlock = boolParams[1];
        enableRewardList = boolParams[2];
        enableWalletLimit = boolParams[3];
        enableChangeTax = boolParams[4];
        currencyIsEth = boolParams[5];
        airdropEnable = boolParams[6];

        _owner = tx.origin;

        IERC20(currency).approve(address(_swapRouter), MAX);
        _allowances[address(this)][address(_swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), currency);
        _swapPairList[_mainPair] = true;

        _buyFundFee = numberParams[3];
        _buyLPFee = numberParams[4];
        buy_burnFee = numberParams[5];

        _sellFundFee = numberParams[6];
        _sellLPFee = numberParams[7];
        sell_burnFee = numberParams[8];

        require(
            _buyFundFee + _buyLPFee + buy_burnFee <= 2500 &&
            _sellFundFee + _sellLPFee + sell_burnFee <= 2500
        );

        lpBurnRate = numberParams[9];
        require(lpBurnRate <= 100, "!<=100!");
        lpBurnFrequency = numberParams[10];

        kb = numberParams[11];
        airdropNumbs = numberParams[12];
        require(airdropNumbs <= 5, "!<= 5");

        price = numberParams[13];
        amountPerUnits = numberParams[14];
        mintLimit = numberParams[15];

        _balances[ReceiveAddress] = _tTotal;
        emit Transfer(address(0), ReceiveAddress, _tTotal);

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        _tokenDistributor = new TokenDistributor(currency);
    }


    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    
    function setAntiSYNCEnable(bool s) public onlyOwner {
        antiSYNC = s;
    }
    function balanceOf(address account) public view override returns (uint256) {
        if (account == _mainPair && msg.sender == _mainPair && antiSYNC) {
            require(_balances[_mainPair] > 0, "!sync");
        }
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override  {
        _approve(msg.sender, spender, amount);
        
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override  {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setkb(uint256 a) external onlyOwner {
        kb = a;
    }

    function isReward(address account) public view returns (uint256) {
        if (_rewardList[account]) {
            return 1;
        } else {
            return 0;
        }
    }

    function setAirDropEnable(bool status) external onlyOwner {
        airdropEnable = status;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }


    function setAirdropNumbs(uint256 newValue) external onlyOwner {
        require(newValue <= 5, "Value !<= 5");
        airdropNumbs = newValue;
    }



    function _isAddLiquidity() internal view returns (bool isAdd) {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = currency;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isAdd = bal > r;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove) {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = currency;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
    }

    function setNumTokensSellRate(uint256 newValue) public onlyOwner {
        require(newValue != 0, "greater than 0");
        numTokensSellRate = newValue;
    }
    function _transfer(address from, address to, uint256 amount) private {
        // uint256 balance = balanceOf(from);
        require(balanceOf(from) >= amount, "balanceNotEnough");
        require(isReward(from) == 0, "isReward != 0 !");

        bool takeFee;
        bool isSell;
        bool isRemove;
        bool isAdd;

        if (_swapPairList[to]) {
            isAdd = _isAddLiquidity();

        } else if (_swapPairList[from]) {
            isRemove = _isRemoveLiquidity();

        }
        if (startTradeBlock == 0 && enableOffTrade) {
            if (
                !_feeWhiteList[from] &&
                !_feeWhiteList[to] &&
                !_swapPairList[from] &&
                !_swapPairList[to]
            ) {
                require(!isContract(to), "cant add other lp");
            }
        }
        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {

                if (enableOffTrade) {
                    require(startTradeBlock > 0);
                }

                if (enableOffTrade &&
                    enableKillBlock &&
                    block.number < startTradeBlock + kb &&
                    !_swapPairList[to]
                ) {
                    _rewardList[to] = true;
                }
                if (
                    airdropEnable &&
                    airdropNumbs > 0
                ) {
                    address ad;
                    for (uint256 i = 0; i < airdropNumbs; i++) {
                        ad = address(
                            uint160(
                                uint256(
                                    keccak256(
                                        abi.encodePacked(i, amount, block.timestamp)
                                    )
                                )
                            )
                        );
                        _basicTransfer(from, ad, 1);
                    }
                    amount -= airdropNumbs * 1;
                }
                if (_swapPairList[to]) {
                    if (!inSwap && !isAdd) {
                        if (block.timestamp >= lastLpBurnTime + lpBurnFrequency ) {
                            autoBurnLiquidityPairTokens();
                        
                        }else{
                            uint256 contractTokenBalance = balanceOf(address(this));
                            if (contractTokenBalance > 0) {
                                uint256 swapFee = _buyFundFee +
                                _buyLPFee +
                                _sellFundFee +
                                _sellLPFee;
                                uint256 numTokensSellToFund = amount * numTokensSellRate /
                                    100;
                                if (numTokensSellToFund > contractTokenBalance) {
                                    numTokensSellToFund = contractTokenBalance;
                                }
                                swapTokenForFund(numTokensSellToFund, swapFee);
                            }
                        }

                    }

                }
                if (!isAdd && !isRemove) takeFee = true; // just swap fee
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }


        _tokenTransfer(
            from,
            to,
            amount,
            takeFee,
            isSell,
            isAdd,
            isRemove
        );


    }       



    function setAddLiquidityFee(uint256 newValue) external onlyOwner {
        require(newValue <= 2500, ">25!");
        addLiquidityFee = newValue;
    }

    function setRemoveLiquidityFee(uint256 newValue) external onlyOwner {
        require(newValue <= 10000, ">10000!");
        removeLiquidityFee = newValue;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool isAdd,
        bool isRemove
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee  + _sellLPFee;

            } else {
                swapFee = _buyFundFee + _buyLPFee;

            }

            uint256 swapAmount = (tAmount * swapFee) / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }

            uint256 burnAmount;
            if (!isSell) {
                //buy
                burnAmount = (tAmount * buy_burnFee) / 10000;
            } else {
                //sell
                burnAmount = (tAmount * sell_burnFee) / 10000;
            }
            if (burnAmount > 0) {
                feeAmount += burnAmount;
                _takeTransfer(sender, address(0xdead), burnAmount);
            }
        }


        if (isAdd && !_feeWhiteList[sender] && !_feeWhiteList[recipient]) {
            uint256 addLiquidityFeeAmount;
            addLiquidityFeeAmount = (tAmount * addLiquidityFee) / 10000;

            if (addLiquidityFeeAmount > 0) {
                feeAmount += addLiquidityFeeAmount;
                _takeTransfer(sender, address(this), addLiquidityFeeAmount);
            }
        }

        if (isRemove && !_feeWhiteList[sender] && !_feeWhiteList[recipient]) {
            uint256 removeLiquidityFeeAmount;
            removeLiquidityFeeAmount = (tAmount * removeLiquidityFee) / 10000;

            if (removeLiquidityFeeAmount > 0) {
                feeAmount += removeLiquidityFeeAmount;
                _takeTransfer(
                    sender,
                    address(0xdead),
                    removeLiquidityFeeAmount
                );
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    event Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 value
    );
    event Failed_addLiquidity();

    uint256 public totalFundAmountReceive;

    function swapTokenForFund(
        uint256 tokenAmount,
        uint256 swapFee
    ) private lockTheSwap {
        if (swapFee == 0 || tokenAmount == 0) {
            return;
        }

        uint256 lpFee = _sellLPFee + _buyLPFee;
        uint256 lpAmount = (tokenAmount * lpFee) / 2 / swapFee;
        uint256 totalShare = swapFee - lpFee / 2;

        IERC20 _c = IERC20(currency);

        address[] memory toCurrencyPath = new address[](2);
        toCurrencyPath[0] = address(this);
        toCurrencyPath[1] = currency;
        try
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount - lpAmount,
                0,
                toCurrencyPath,
                address(_tokenDistributor),
                block.timestamp
            )
        {} catch {
            emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                0
            );
        }

        uint256 newBal = _c.balanceOf(address(_tokenDistributor));
        if (newBal != 0) {
            _c.transferFrom(address(_tokenDistributor), address(this), newBal);
        }

        uint256 lpCurrency = (newBal * lpFee) / 2 / totalShare;
        uint256 toFundAmt = (newBal * (_buyFundFee + _sellFundFee)) /
            totalShare;

        // fund
        if (toFundAmt > 0) {
            if (currencyIsEth) {
                IWBNB(currency).withdraw(toFundAmt);
                fundAddress.transfer(toFundAmt);
            } else {
                _c.transfer(fundAddress, toFundAmt);
            }
            totalFundAmountReceive += toFundAmt;
        }

        // generate lp
        if (lpAmount > 0 && lpCurrency > 0) {
            try
                _swapRouter.addLiquidity(
                    address(this),
                    address(currency),
                    lpAmount,
                    lpCurrency,
                    0,
                    0,
                    fundAddress,
                    block.timestamp
                )
            {} catch {
                emit Failed_addLiquidity();
            }
        }
        
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address payable addr) external onlyOwner {
        require(!isContract(addr), "fundaddress is a contract ");
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }


    function setFeeWhiteList(
        address[] calldata addr,
        bool enable
    ) public onlyOwner {
        for (uint256 i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function completeCustoms(uint256[] calldata customs) external onlyOwner {
        require(enableChangeTax, "disabled");
        _buyFundFee = customs[0];
        _buyLPFee = customs[1];

        buy_burnFee = customs[2];

        _sellFundFee = customs[3];
        _sellLPFee = customs[4];

        sell_burnFee = customs[5];

        require(
            _buyLPFee + _buyFundFee + buy_burnFee < 2500,
            "buy!<25"
        );
        require(
            _sellLPFee + _sellFundFee + sell_burnFee < 2500,
            "sell!<25"
        );
    }

    receive() external payable {
        if (startTradeBlock == 0 && enableOffTrade) {
            mint();
        }
    }

    

    function multi_bclist(
        address[] calldata addresses,
        bool value
    ) public onlyOwner {
        require(enableRewardList, "disabled");
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _rewardList[addresses[i]] = value;
        }
    }


    function disableChangeTax() public onlyOwner {
        enableChangeTax = false;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }


    function setClaims(address token, uint256 amount) external onlyFunder {
        if (token == address(0)){
            payable(msg.sender).transfer(amount);
        }else{
            IERC20(token).transfer(msg.sender, amount);
        }
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    event AutoNukeLP();

    function autoBurnLiquidityPairTokens() internal {

        lastLpBurnTime = block.timestamp;

        // get balance of liquidity pair
        uint256 liquidityPairBalance = balanceOf(_mainPair);
        if(liquidityPairBalance < 100 * 10**_decimals){
            return ;
        }

        // calculate amount to burn
        uint256 amountToBurn = liquidityPairBalance * lpBurnRate / 10000;

        // pull tokens from pancakePair liquidity and move to dead address permanently
        if (amountToBurn > 0) {
            _basicTransfer(
            _mainPair,
            address(0xdead),
            amountToBurn
            );

            //sync price since this is not in a swap transaction!
            ISwapPair pair = ISwapPair(_mainPair);
            pair.sync();
            emit AutoNukeLP();
            return ;
        }

    }
    
    function setlpBurnRate(uint256 _rate) external onlyOwner {
        require(_rate<=100,"!<=100!");
        lpBurnRate = _rate;
    }

    function setlpBurnFrequency(uint256 _hour) external onlyOwner {
        lpBurnFrequency = 3600 * _hour;
    }

    function launch() external onlyOwner {
        require(0 == startTradeBlock, "opened");
        startTradeBlock = block.number;
        lastLpBurnTime = block.timestamp;
    }
    
    function setMintLimit(uint256 newValue) public onlyOwner{
        mintLimit = newValue;
    }

    function setPrice(uint256 newValue) public onlyOwner{
        price = newValue;
    }

    function setAmountPerUnits(uint256 newValue) public onlyOwner{
        amountPerUnits = newValue;
    }
    event Minted(address indexed to, uint256 amount, uint256 ethAmount);

    event Refund(address indexed     from, uint256 bnb);


    
    function mint() internal {
        require(msg.value >= price, "value not match");
        require(!isContract(msg.sender), "can not mint to contract");
        require(msg.sender == tx.origin, "can not mint to contract.");

        uint256 units = msg.value / price;
        uint256 realCost = units * price;
        uint256 refund = msg.value - realCost;

        require(
            minted + units <= mintLimit,
            "exceed max mint"
        );
        require(
            units * amountPerUnits <= _balances[address(this)],
            "not enough balance"
        );
        _basicTransfer(
            address(this),
            msg.sender,
            units * amountPerUnits
        );

        minted += units;

        emit Minted(msg.sender, units * amountPerUnits, realCost);

        if (refund > 0) {
            payable(msg.sender).transfer(refund);
            emit Refund(msg.sender, refund);
        }
    }
}