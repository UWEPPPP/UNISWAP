// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "./lib/Library.sol";
import "./lib/IERC20.sol";
import "./lib/IUniswapV3SwapCallback.sol";
import "./lib/IUniswapV3MintCallback.sol";
error InvalidTickRange();
error ZeroLiquidity();
error InsufficientInputAmount();

contract UniswapV3Pool{
    using Tick for mapping(int24 =>Tick.Info);
    using Position for mapping(bytes32 => Position.Info);
    using Position for Position.Info;

    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );
    
    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;
    
    //交易代币
    address public immutable token0;
    address public immutable token1;

    //打包变量方便阅读
    struct Slot0//插槽??
    {
        uint160 sqrtPriceX96;
        int24 tick;
    }
    Slot0 public slot0;
   
    //流动性数值
    uint128 public liquidity;

    // Ticks 信息
    mapping (int24=>Tick.Info ) public ticks;
    //Positions 信息
    mapping(bytes32 => Position.Info) public positions;

    
    constructor(
    address token0_,
    address token1_,
    uint160 sqrtPriceX96,
    int24 tick       
    ) {
        token0=token0_;
        token1=token1_;
        slot0=Slot0({sqrtPriceX96: sqrtPriceX96,tick:tick});//命名参数初始化
    }
   
   
    function mint(
        address owner,
        int24 lowerTick,
        int24 upperTick,
        uint128 amount 
    ) external returns (uint256 amount0,uint256 amount1){ 
        if(
            
            lowerTick >= upperTick ||
            lowerTick <  MIN_TICK ||
            upperTick >  MAX_TICK
        ) revert InvalidTickRange();
        if(amount==0) revert ZeroLiquidity();
        amount0=0.998976618347425280 ether;
        amount1= 5000 ether;
        uint256 balance0Before;
        uint256 balance1Before;
        if(amount0 > 0) balance0Before = balance0();
        if(amount1 > 0) balance1Before = balance1();
          IUniswapV3MintCallback(msg.sender).uniswapV3MintCallback(
       amount0,
       amount1
        );
if (amount0 > 0 && balance0Before + amount0 > balance0())
    revert InsufficientInputAmount();
if (amount1 > 0 && balance1Before + amount1 > balance1())
    revert InsufficientInputAmount();     
     }

    function balance0() internal view returns (uint256 balance) {
        balance = IERC20(token0).balanceOf(address(this));
    }

    function balance1() internal view returns (uint256 balance) {
        balance = IERC20(token1).balanceOf(address(this));
    }

}