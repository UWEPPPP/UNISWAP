// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;
import "./ERC20test.sol";
import "../src/uniswapTool.sol";
import "forge-std/Test.sol";

   contract uniswapv3PoolTest is Test {
    ERC20Mintable token0;
    ERC20Mintable token1;
    UniswapV3Pool pool;
    
    bool transferInMintCallback = true;
    bool transferInSwapCallback = true;
    bool shouldTransferInCallback =true;
    struct TestCaseParams {
        uint256 wethBalance;
        uint256 usdcBalance;
        int24 currentTick;
        int24 lowerTick;
        int24 upperTick;
        uint128 liquidity;
        uint160 currentSqrtP;
        bool shouldTransferInCallback;
        bool mintLiqudity;
    }
    
    
    function setUp() public {
        token0 = new ERC20Mintable("Ether","ETH",18);        
        token1 = new ERC20Mintable("USDC","USDC",18);
    }
    function setupTestCase(TestCaseParams memory params)
    internal
    returns (uint256 poolBalance0, uint256 poolBalance1)
{
    token0.mint(address(this), params.wethBalance);
    token1.mint(address(this), params.usdcBalance);

    pool = new UniswapV3Pool(
        address(token0),
        address(token1),
        params.currentSqrtP,
        params.currentTick
    );

    if (params.mintLiqudity) {
        (poolBalance0, poolBalance1) = pool.mint(
            address(this),
            params.lowerTick,
            params.upperTick,
            params.liquidity
        );
    }

    shouldTransferInCallback = params.shouldTransferInCallback;
    }


    function uniswapV3MintCallback(uint256 amount0, uint256 amount1) public {
    if (shouldTransferInCallback) {
        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);
    }
}
     function testAll() public{
       TestCaseParams memory params = TestCaseParams({
        wethBalance: 1 ether,
        usdcBalance: 5000 ether,
        currentTick: 85176,
        lowerTick: 84222,
        upperTick: 86129,
        liquidity: 1517882343751509868544,
        currentSqrtP: 5602277097478614198912276234240,
        shouldTransferInCallback: true,
        mintLiqudity: true
    });
    (uint256 poolBalance0, uint256 poolBalance1) = setupTestCase(params);
     uint256 expectedAmount0 = 0.998976618347425280 ether;
     uint256 expectedAmount1 = 5000 ether;
     assertEq(
    poolBalance0,
    expectedAmount0,
    "incorrect token0 deposited amount"
     );
    assertEq(
    poolBalance1,
    expectedAmount1,
    "incorrect token1 deposited amount"
     );
     assertEq(token0.balanceOf(address(pool)), expectedAmount0, "mistake96" );
     assertEq(token1.balanceOf(address(pool)), expectedAmount1,"mistake97");
     bytes32 positionKey = keccak256(
    abi.encodePacked(address(this), params.lowerTick, params.upperTick)
    );
    uint128 posLiquidity = pool.positions(positionKey);
    assertEq(posLiquidity, params.liquidity,"mistake102");//没有初始化 position的update
    (bool tickInitialized, uint128 tickLiquidity) = pool.ticks(
     params.lowerTick
    );
assertTrue(tickInitialized,"mistake106");//没有初始化 tick的update函数
assertEq(tickLiquidity, params.liquidity,"mistake107");//与上面连带

(tickInitialized, tickLiquidity) = pool.ticks(params.upperTick);
assertTrue(tickInitialized,"mistake110");//同上
assertEq(tickLiquidity, params.liquidity,"mistake111");//同上
(uint160 sqrtPriceX96, int24 tick) = pool.slot0();
assertEq(
    sqrtPriceX96,
    5602277097478614198912276234240,
    "invalid current sqrtP"
);
assertEq(tick, 85176, "invalid current tick");
assertEq(
    pool.liquidity(),
    1517882343751509868544,
    "invalid current liquidity"//该流动性压根就没有初始化
);
     }
}