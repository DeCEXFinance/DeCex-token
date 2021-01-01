pragma solidity ^0.6.6;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import './ManagementPart.sol';
import './UniPart.sol';




contract DECEXERC20 is ManagementPart,IERC20 {
    using SafeMath for uint256;
    using Address for address;
   
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ///////////////public usage part/////////////////////

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) public _balances; 
    uint256 public _totalSupply; 
    string  public _name;
    string  public _symbol;
    uint8   public _decimals;
    

    ///////////////UniSwap part//////////////////////////

 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////token distribution part/////////////////////

    uint256 public constant MaxSupply = 1000000e18;
    uint256 public  initialSupply; 


    ///////////////10% for airDrop and Marketing////////////

    //mint 1% for public airdrop
    //mint 0.5% for CoreAirdrop
    uint256 public constant forAirdropSociety = 5000e18; //0.5%
    uint256 public constant forAirdropMedia = 5000e18; //0.5%
    uint256 public constant forMarketing = 80000e18; //8%
    ////////////////////////////////////////////////////////

    
    uint256 public constant forSeedSell = 50000e18; //5%
    uint256 public constant forGenesisStakingPool = 50000e18; //lock 30 days 5%
    uint256 public constant forLaterProgress = 100000e18; //lock 90 days 10%
    uint256 public constant forProjectKeep = 50000e18; // lock 90 days 5%

    uint256 public constant initialLiquidity = 40e18;   ///40 dcx for initail uniswap pool
    uint256 public constant forLiquidity = 199960e18; //20% 40 decex for initial liquidity


    uint256 public constant forPublicSell = 450000e18; //45% 45w decex for PublicSellContract

    
  

    address public _forAirdropSocietyAddress = address(0xe2E68a22A3Ad7B8181b6A6bFC8a985B4c7c5367D); 
    address public _forAirdropMediaAddress = address(0xF26C3875b2BA60FEcDcec2c615c85FbD139a1503); 
    address public _forMarketingAddress = address(0xf2342b1D5154C0f06F1eb7E8d09f0e71Ba103734); 
    address public _forSeedSellAddress = address(0x8353B27a37C4bFb648A510358998AEEdBF68D9d0); 


    address public _forGenesisStakingPoolAddress = address(0x1ca7163c8C323F14d5054e28Eac2DF196bCd104f); //10%  lock 30 days //5
    address public _forLaterProgressAddress = address(0xF662B5c689c8382367aFEDbdBFa9085EF07Af3AB); //10% lock 90 days //6
    address public _forProjectKeepAddress = address(0xC564b835AAdF56De1884FED770643a61eB0426A7); //5% lock 90 days //7
    address public _forLiquidPoolAddress = address(0x695493347bb71bF68683bC0628dd1180dbc39d61);  //20% //8

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //////charge part burn////////

   
    uint256 public constant _rateBase = 100000;
    uint256 public _totalBurnToken = 0; //c
    uint256 public constant _maxBurnAmount = 799083e18; //c 799083e18

    address public _burnAddress = address(0);
    uint256 public _toBurn_rate = 1000;
    uint256 public _toLiquidity_rate = 1000;
    uint256 public _toBuyBack_rate  = 2000;
    uint256 public _toProject_rate = 1000;

    address public _toLiquidPoolChargeAddress = address(0); //9  contract address
    address public _toBuyBackPoolChargeAddress = address(0x14A777403FCe6271A4b5fce7a27c866f33671ade); //10
    address public _toProjectPoolChargeAddress= address(0xcB1350E994d8BcbA55575ABe429D953e2B4a7208); //11

    event DecexChargeFeeEvent(address sender ,uint256 burn, uint256 toLiquidity, uint256 buyBack , uint256 toProject);
    event TransferToPoolEvent( address poolAddress, uint256 value);
    event SetToLiquidPoolEvent(address newPool);
    event SetToBuyBack_PoolEvent(address newPool);
    event SetToProjectPoolEvent(address newPool);
    event SetChargeFeeEvent(uint256 new_toBurn_rate, uint256 new_toLiquidity_rate, uint256 new_toBuyBack_rate , uint256 new_toProject_rate);

    
     function setChargeFee(
        uint256 toBurn_rate, 
        uint256 toLiquidity_rate, 
        uint256 toBuyBack_rate,  
        uint256 toProject_rate
    ) public  onlyOwner{
        require(toBurn_rate > 0 &&  toBurn_rate < _rateBase, "toBurn rate must more than zero" );
        require(toLiquidity_rate > 0 &&  toLiquidity_rate < _rateBase, "toLiquidity rate must more than zero" );
        require(toBuyBack_rate > 0 &&  toBuyBack_rate < _rateBase, "toBuyBack rate must more than zero" );
        require(toProject_rate > 0 &&  toProject_rate < _rateBase, "toProject rate must more than zero" );
        require(_frozenAccount[msg.sender] != true, "sender was frozen" );
        require(_toLiquidPoolChargeAddress != address(0), "toLiquidPool not set" );
        require(_toBuyBackPoolChargeAddress != address(0), "toBuyBackPool not set" );
        require(_toProjectPoolChargeAddress != address(0), "toProjectPool not set" );
        

        _toBurn_rate = toBurn_rate;
        _toLiquidity_rate = toLiquidity_rate;
        _toBuyBack_rate  = toBuyBack_rate;
        _toProject_rate = toProject_rate;

        emit SetChargeFeeEvent(toBurn_rate, toLiquidity_rate, toBuyBack_rate, toProject_rate);          
    }


    function setToLiquidPool(
       address payable newPoolAddress
    ) public  onlyOwner{
        require(newPoolAddress != address(0), "invild address" );
        require(_frozenAccount[msg.sender] != true, "sender was frozen" );

        _toLiquidPoolChargeAddress = newPoolAddress;

        emit SetToLiquidPoolEvent( newPoolAddress);
    }

    function setToBuyBack_Pool(
       address payable newPoolAddress
    ) public  onlyOwner{
        require(newPoolAddress != address(0), "invild address" );
        require(_frozenAccount[msg.sender] != true, "sender was frozen" );

        _toBuyBackPoolChargeAddress = newPoolAddress;

        emit SetToBuyBack_PoolEvent(newPoolAddress);
    }

    function setToProjectPool(
       address payable newPoolAddress
    ) public  onlyOwner{
        require(newPoolAddress != address(0), "invild address" );
        require(_frozenAccount[msg.sender] != true, "sender was frozen" );

        _toProjectPoolChargeAddress = newPoolAddress;

        emit SetToProjectPoolEvent(newPoolAddress);
    }


    function getPoolAddresses() public view returns (address,address,address){

        return (_toLiquidPoolChargeAddress,_toBuyBackPoolChargeAddress, _toProjectPoolChargeAddress);
    }


    function _transferToPool(
        address sender,
         address poolAddress, uint256 amount
    ) internal virtual {
        require(amount > 0 , "ERC20: transfer amount less than zero 1 ");


        _transfer(sender, poolAddress, amount);
    }

    function _charge(uint256 amountBefore, address sender) 
        internal
        virtual
        returns (uint256){
        
        require(amountBefore > 0 , "ERC20: transfer amount less than zero 2");
         
        uint256 liquidityFee = amountBefore.mul(_toLiquidity_rate).div(_rateBase);
        uint256 buyBackFee = amountBefore.mul(_toBuyBack_rate).div(_rateBase);
        uint256 toProjectFee = amountBefore.mul(_toProject_rate).div(_rateBase);
        uint256 burnFee = amountBefore.mul(_toBurn_rate).div(_rateBase);


         if (burnFee > 0) {
                //to burn
            if(_totalBurnToken < _maxBurnAmount){
                amountBefore = amountBefore.sub(burnFee,'x1');
                _totalBurnToken = _totalBurnToken.add(burnFee);
                _transferToPool(sender,_burnAddress,burnFee);
            }     
        }

        if (liquidityFee > 0) {
            //to liquidPool toooooooooooo be implmented more specific
            amountBefore = amountBefore.sub(liquidityFee,'x2');
            _transferToPool(sender, _toLiquidPoolChargeAddress, liquidityFee );
        }

        if (buyBackFee > 0) {
            //to buybackAddress
            amountBefore = amountBefore.sub(buyBackFee,'x3');
            _transferToPool(sender, _toBuyBackPoolChargeAddress, buyBackFee );
        }

        if (toProjectFee> 0) {
            //to projectAddress
            amountBefore = amountBefore.sub(toProjectFee,'x4');
            _transferToPool(sender, _toProjectPoolChargeAddress, toProjectFee );
        }

        return (amountBefore);   
    }

    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//interface for Selling and Airdrop//


 mapping(address => bool) public allowedAddress;


 event AddActivityAddressEvent(uint8 activityIndex ,address account);
 event SendDcxEvent(uint8 activityIndex ,address ToAccount, uint256 amount);



 uint256 public constant publicAirdropTargetAmount = 10000e18;
 uint256 public publicAirdropMintAmount;


   function setActivityAddress(address account, uint8 lableIndex, bool turnOff) public onlyOwner {
        require(account != address(0), "zero address");
        require(_frozenAccount[msg.sender] != true, "sender was frozen" );
        
        allowedAddress[account] = turnOff;
       
      
        emit AddActivityAddressEvent( lableIndex, account);
    }


    function sendDcx(address account, uint256 amount , uint8 activityIndex) public {
        require(allowedAddress[msg.sender],'the address is not allowed, only activities contract address allowed');

        require(account != address(0), "zero address");
        require(amount > 0 , "invalid amount input");

        if(activityIndex == 99 ){

             require(publicAirdropMintAmount.add(amount) <= publicAirdropTargetAmount,"exceed");

              _mint(account,amount,activityIndex);

              publicAirdropMintAmount = publicAirdropMintAmount.add(amount);

        }

    }

    function queryPublicAirDropMintStatus() public view returns (uint256 ,uint256){
        return (publicAirdropMintAmount,publicAirdropTargetAmount);
    }

    function _mint(address account, uint256 amount, uint8 activityIndex) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_totalSupply.add(amount) <= MaxSupply, "mint exceed maxSupply");

      

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);

        emit SendDcxEvent(activityIndex, account, amount);
    }

    function checkAddress(address account) public view returns (bool){
        return allowedAddress[account];
    }


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */

     
     
    constructor() public {

         _name = "DeCEX";
        _symbol = "DCX";
        _decimals = 18;

        initialSupply = initialSupply.add(forAirdropSociety).add(forAirdropMedia).add(forMarketing).add(forSeedSell).add(forGenesisStakingPool).add(forLaterProgress).add(forProjectKeep).add(initialLiquidity).add(forLiquidity);
       
        _totalSupply = initialSupply;

        _balances[_forAirdropSocietyAddress] = forAirdropSociety;
        _balances[_forAirdropMediaAddress] = forAirdropMedia;
        _balances[_forMarketingAddress] = forMarketing;
        

        _balances[_forGenesisStakingPoolAddress] = forGenesisStakingPool;
        _balances[_forLaterProgressAddress] = forLaterProgress;
        _balances[_forProjectKeepAddress] = forProjectKeep;
        _balances[_forLiquidPoolAddress] = forLiquidity;
        _balances[_forSeedSellAddress] = forSeedSell;



        _balances[address(this)] = initialLiquidity; //40 dec
        
     
        _frozenAccount[_forGenesisStakingPoolAddress] = true;
        _frozenAccount[_forLaterProgressAddress] = true;
        _frozenAccount[_forProjectKeepAddress] = true;

        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
        factory = IUniswapV2Factory(uniswapRouter.factory());
    }



    function setupUni(address toLiquidty) public payable onlyOwner {
        require(_frozenAccount[msg.sender] != true, "sender was frozen" );
        
        _toLiquidPoolChargeAddress = toLiquidty;

        address uniPairCreated = createPair();

        uniPair = uniPairCreated;

        addWhiteList(uniPairCreated);
        addWhiteList(UNISWAP_ROUTER_ADDRESS);
        addWhiteList(address(this));
        addWhiteList(_toLiquidPoolChargeAddress);
        
        initialPair();

    }

    function setupPublicSell(address contractAddress) public payable onlyOwner {
        require(_frozenAccount[msg.sender] != true, "sender was frozen" );

        addWhiteList(contractAddress);

        _balances[contractAddress] = forPublicSell; 

         _totalSupply = _totalSupply.add(forPublicSell);
         
    }



     

    
    /////////////////////////////////////////////////////////////////
    
    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {


        if( _whiteList[_msgSender()]){
             _transfer(_msgSender(), recipient, amount); 
        }else{
           uint256 transferToAmount = _charge(amount,_msgSender());
           _transfer(_msgSender(), recipient, transferToAmount); 
        }
       
        return true;
    }

  
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        require( _frozenAccount[owner] != true, "account frozen 3");
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        require( _frozenAccount[spender] != true, "account frozen 4");
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        if( _whiteList[sender]){
              _transfer(sender, recipient, amount);
             
             _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance 5"));
        }else{
           uint256 transferToAmount = _charge(amount,sender);
           _transfer(sender, recipient, transferToAmount);
           _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance 5"));
        }
       
        return true;
    }

   
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        require( _frozenAccount[spender] != true, "account frozen 6");
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

   
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        require( _frozenAccount[spender] != true, "account frozen 7");
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero 8" ));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(_frozenAccount[sender] != true, "sender was frozen" );
       
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
   
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(_frozenAccount[owner] != true, "sender was frozen" );
        require(owner != address(0), "ERC20: approve from the zero address 13");
        require(spender != address(0), "ERC20: approve to the zero address 14");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
