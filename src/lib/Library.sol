// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
library Tick{
    struct Info{
        bool initialized;//初始化
        uint128 liquidity;
    }
     function update(
        mapping (int24=>Tick.Info) storage self,
        int24 tick,
        uint128 liquidityDelta
    ) internal {
        Tick.Info storage tickInfo = self[tick];
        uint128 liquidityBefore = tickInfo.liquidity;
        uint128 liquidityAfter  = liquidityBefore + liquidityDelta;

        if(liquidityBefore == 0){
            tickInfo.initialized = true;
        }
        tickInfo.liquidity = liquidityAfter;
        
        //它初始化一个流动性为 0 的 tick，
        //并且在上面添加新的流动性。正如上面所示，
        //我们会在下界 tick 和上界 tick 处均调用此函数，
        //流动性在两边都有添加。
    }
}


library Position{
    struct Info{
        uint128 liquidity;//资产流动性
    }
    function update(Info storage self,uint128 liquidityDelta) internal {
        uint128 liquidityBefore =self.liquidity;
        uint128 liquidityAfter = liquidityBefore + liquidityDelta;
        self.liquidity = liquidityAfter;
        //与 tick 的函数类似，它也在特定的位置上添加流动性
    }
    function get(
        mapping (bytes32=>Info) storage self,
        address owner,
        int24 lowerTick,
        int24 upperTick
        ) internal view returns(Position.Info storage position ){
        position =self[keccak256(abi.encodePacked(owner,lowerTick,upperTick))];
    }
}
