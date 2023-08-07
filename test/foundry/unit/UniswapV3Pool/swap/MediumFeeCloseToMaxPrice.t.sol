pragma solidity ^0.7.6;
pragma abicoder v2;

import {UniswapV3PoolSwapTest} from "./UniswapV3PoolSwap.t.sol";
import {IUniswapV3Pool} from "contracts/core/interfaces/IUniswapV3Pool.sol";

contract MediumFeeCloseToMaxPriceTest is UniswapV3PoolSwapTest {
    function setUp() public override {
        super.setUp();

        int24 tickSpacing = TICK_SPACING_60;

        string memory poolName = ".close_to_max_price";
        address pool =
            poolFactory.createPool({tokenA: address(token0), tokenB: address(token1), tickSpacing: tickSpacing});

        // hardcoded value, because we can't reproduce it within solidity
        // sqrt(2^127) * 2^96
        uint160 startingPrice = 1033437718471923706666374484006904511252097097914;

        IUniswapV3Pool(pool).initialize(startingPrice);

        uint128 liquidity = 2e18;

        positions.push(
            Position({tickLower: getMinTick(tickSpacing), tickUpper: getMaxTick(tickSpacing), liquidity: liquidity})
        );

        uniswapV3Callee.mint(pool, users.alice, positions[0].tickLower, positions[0].tickUpper, positions[0].liquidity);

        uint256 poolBalance0 = token0.balanceOf(pool);
        uint256 poolBalance1 = token1.balanceOf(pool);

        (uint160 sqrtPriceX96, int24 tick,,,,,) = IUniswapV3Pool(pool).slot0();

        poolSetup = PoolSetup({
            poolName: poolName,
            pool: pool,
            poolBalance0: poolBalance0,
            poolBalance1: poolBalance1,
            sqrtPriceX96: sqrtPriceX96,
            tick: tick
        });
    }
}
