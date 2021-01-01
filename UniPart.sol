pragma solidity ^0.6.6;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";







contract UniPart is Ownable{
    using SafeMath for uint256;
    using Address for address;

    address public constant unifactoryAddress = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    IUniswapV2Factory public factory;
    IUniswapV2Router02 public uniswapRouter;

    event CreateUniPairEvent(address uniPair, uint timeStamp);
    event InitialPairEvent(uint256 DecexIn, uint256 ETHIN, uint timeStamp);
     

    uint public constant initialDecexIn = 40e18; //add with 0.1 eth

  
   
    function createPair() public onlyOwner returns (address){
        address uniPair;
        if (factory.getPair(address(this), uniswapRouter.WETH()) == address(0)) {
            uint createdTime =  block.timestamp;
            
            uniPair = factory.createPair(address(this), uniswapRouter.WETH());
          
            emit CreateUniPairEvent(uniPair,createdTime);
            
        }else{
            uniPair = factory.getPair(address(this), uniswapRouter.WETH());
        }

        return uniPair;
    }


    function initialPair() public payable onlyOwner returns (bool){   //create pair with liquidity and add pair and uniswap routerV2 to white list to enable buy and sell

        uint deadline = block.timestamp + 15;

        IERC20 DecexToken = IERC20(address(this));

        require(DecexToken.approve(address(UNISWAP_ROUTER_ADDRESS), initialDecexIn), 'approve failed.');
        // require(WETHToken.approve(address(UNISWAP_ROUTER_ADDRESS), initialETHIn), 'approve failed.');

        uniswapRouter.addLiquidityETH{ value: msg.value }(address(this), initialDecexIn , initialDecexIn, msg.value ,address(this),deadline);

    
        emit InitialPairEvent(initialDecexIn, msg.value ,deadline );

        return true;
    }

    function getPair() public  view returns (address){
        return factory.getPair(address(this), uniswapRouter.WETH());
       
    }


    

}