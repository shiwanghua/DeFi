// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.5.0;

import './IWBNB.sol';
import './IBEP20.sol';
import './SafeMath.sol';
import './UniversalBEP20.sol';
import './IBscSwapFactory.sol';
import './IBurgerSwapFactory.sol';
import './IBakerySwapFactory.sol';
import './ICheeseSwapFactory.sol';
import './IPancakeSwapFactory.sol';


library DisableFlags {
    function check(uint256 my_flag, uint256 const_flag) internal pure returns (bool) {
        return (my_flag & const_flag) != 0;
    }
}

contract BinanceSplitConsts {
    uint256 internal constant FLAG_DISABLE_BURGER_SWAP = 0x01;
    uint256 internal constant FLAG_DISABLE_BURGER_SWAP_WBNB = 0x02;
    uint256 internal constant FLAG_DISABLE_BURGER_SWAP_BURGER = 0x04;
    uint256 internal constant FLAG_DISABLE_BAKERY_SWAP = 0x08;
    uint256 internal constant FLAG_DISABLE_BAKERY_SWAP_WBNB = 0x10;
    uint256 internal constant FLAG_DISABLE_CHEESE_SWAP = 0x20;
    uint256 internal constant FLAG_DISABLE_CHEESE_SWAP_WBNB = 0x40;
    uint256 internal constant FLAG_DISABLE_BSC_SWAP = 0x80;
    uint256 internal constant FLAG_DISABLE_BSC_SWAP_WBNB = 0x100;
    uint256 internal constant FLAG_DISABLE_PANCAKE_SWAP = 0x200;
    uint256 internal constant FLAG_DISABLE_PANCAKE_SWAP_WBNB = 0x400;
    uint256 internal constant FLAG_DISABLE_ALL_SPLIT_SOURCES = 0x800;
    uint256 internal constant FLAG_DISABLE_BURGER_SWAP_ALL = 0x1000;
    uint256 internal constant FLAG_DISABLE_BAKERY_SWAP_ALL = 0x2000;
    uint256 internal constant FLAG_DISABLE_CHEESE_SWAP_ALL = 0x4000;
    uint256 internal constant FLAG_DISABLE_BSC_SWAP_ALL = 0x8000;
    uint256 internal constant FLAG_DISABLE_PANCAKE_SWAP_ALL = 0x10000;

    uint256 internal constant DEXES_COUNT = 12;
    int256 internal constant VERY_NEGATIVE_VALUE = -1e72;
    IBEP20 internal constant ZERO_ADDRESS = IBEP20(0);
    IBEP20 internal constant BNB_ADDRESS = IBEP20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    IWBNB internal constant wbnb = IWBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IBEP20 internal constant burger = IBEP20(0xAe9269f27437f0fcBC232d39Ec814844a51d6b8f);

    IBscSwapFactory internal constant bsc_swap = IBscSwapFactory(0xCe8fd65646F2a2a897755A1188C04aCe94D2B8D0);
    IBurgerSwapFactory internal constant burger_swap = IBurgerSwapFactory(0x8a1E9d3aEbBBd5bA2A64d3355A48dD5E9b511256);
    IBakerySwapFactory internal constant bakery_swap = IBakerySwapFactory(0x01bF7C66c6BD861915CdaaE475042d3c4BaE16A7);
    ICheeseSwapFactory internal constant cheese_swap = ICheeseSwapFactory(0xdd538E4Fd1b69B7863E1F741213276A6Cf1EfB3B);
    IPancakeSwapFactory internal constant pancake_swap = IPancakeSwapFactory(0xBCfCcbde45cE874adCB698cC183deBcF17952812);
}

contract BinanceSplit is BinanceSplitConsts {
    using SafeMath for uint256;
    using DisableFlags for uint256;
    using UniversalBEP20 for IBEP20;
    using UniversalBEP20 for IWBNB;

    using BscSwapExchangeLib for IBscSwapExchange;
    using BurgerSwapExchangeLib for IBurgerSwapExchange;
    using BakerySwapExchangeLib for IBakerySwapExchange;
    using CheeseSwapExchangeLib for ICheeseSwapExchange;
    using PancakeSwapExchangeLib for IPancakeSwapExchange;

    // s is the parts, amounts is the exchangesReturns
    function _findBestDistribution(uint256 s, int256[][] memory amounts) internal pure returns (int256 returnAmount, uint256[] memory distribution) {
        uint256 n = amounts.length;

        int256[][] memory answer = new int256[][](n); // int[n][s+1]
        uint256[][] memory parent = new uint256[][](n); // int[n][s+1]

        for (uint i = 0; i < n; i++) {
            answer[i] = new int256[](s + 1);
            parent[i] = new uint256[](s + 1);
        }

        for (uint j = 0; j <= s; j++) {
            answer[0][j] = amounts[0][j];
            for (uint i = 1; i < n; i++) {
                answer[i][j] = -1e72;
            }
            parent[0][j] = 0;
        }

        for (uint i = 1; i < n; i++) {
            for (uint j = 0; j <= s; j++) {
                answer[i][j] = answer[i - 1][j];
                parent[i][j] = j;

                for (uint k = 1; k <= j; k++) {
                    if (answer[i - 1][j - k] + amounts[i][k] > answer[i][j]) {
                        answer[i][j] = answer[i - 1][j - k] + amounts[i][k];
                        parent[i][j] = j - k;
                    }
                }
            }
        }

        distribution = new uint256[](DEXES_COUNT);

        uint256 partsLeft = s;
        for (uint curExchange = n - 1; partsLeft > 0; --curExchange) {
            distribution[curExchange] = partsLeft - parent[curExchange][partsLeft];
            partsLeft = parent[curExchange][partsLeft];
        }

        returnAmount = (answer[n - 1][s] == VERY_NEGATIVE_VALUE) ? 0 : answer[n - 1][s];
    }

    function _linearInterpolation(uint256 value, uint256 parts) internal pure returns (uint256[] memory rets) {
        rets = new uint256[](parts);
        for (uint i = 0; i < parts; ++i) {
            rets[i] = value.mul(i + 1).div(parts);
        }
    }

    function _calculateNoReturn(
        IBEP20 /*fromToken*/,
        IBEP20 /*destToken*/,
        uint256 /*amount*/,
        uint256 parts,
        uint256 /*flags*/
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        this;
        return (new uint256[](parts), 0);
    }

    function _calculateFormula_997(
        uint256 fromBalance,
        uint256 toBalance,
        uint256 amount
    ) internal pure returns(uint256) {
        if (amount == 0) {
            return 0;
        }
        return amount.mul(toBalance).mul(997).div(
            fromBalance.mul(1000).add(amount.mul(997))
        );
    }

    function _calculateFormula_998(
        uint256 fromBalance,
        uint256 toBalance,
        uint256 amount
    ) internal pure returns(uint256) {
        if (amount == 0) {
            return 0;
        }
        return amount.mul(toBalance).mul(998).div(
            fromBalance.mul(1000).add(amount.mul(998))
        );
    }

    function _calculateBurgerSwap(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256[] memory amounts,
        uint256 /*flags*/
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        rets = new uint256[](amounts.length);
        IBEP20 fromTokenReal = fromToken.isBNB() ? wbnb : fromToken;
        IBEP20 destTokenReal = destToken.isBNB() ? wbnb : destToken;
        IBurgerSwapExchange exchange = burger_swap.getPair(fromTokenReal, destTokenReal);
        if (exchange != IBurgerSwapExchange(0)) {
            uint256 fromTokenBalance = fromTokenReal.universalBalanceOf(address(exchange));
            uint256 destTokenBalance = destTokenReal.universalBalanceOf(address(exchange));
            for (uint i = 0; i < amounts.length; ++i) {
                rets[i] = _calculateFormula_997(fromTokenBalance, destTokenBalance, amounts[i]);
            }
            return (rets, 600_000);
        }
    }

    function calculateBurgerSwap(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        return _calculateBurgerSwap(fromToken, destToken, _linearInterpolation(amount, parts), flags);
    }

    function _calculateBurgerSwapOverMidToken(
        IBEP20 fromToken,
        IBEP20 midToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        uint256 gas1;
        uint256 gas2;
        rets = _linearInterpolation(amount, parts);
        (rets, gas1) = _calculateBurgerSwap(fromToken, midToken, rets, flags);
        (rets, gas2) = _calculateBurgerSwap(midToken, destToken, rets, flags);
        return (rets, gas1 + gas2);
    }

    function calculateBurgerSwapBNB(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        if (fromToken.isBNB() || fromToken == wbnb || destToken.isBNB() || destToken == wbnb) {
            return (new uint256[](parts), 0);
        }
        return _calculateBurgerSwapOverMidToken(fromToken, wbnb, destToken, amount, parts, flags);
    }

    function calculateBurgerSwapBurger(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        if (fromToken == burger || destToken == burger) {
            return (new uint256[](parts), 0);
        }
        return _calculateBurgerSwapOverMidToken(fromToken, burger, destToken, amount, parts, flags);
    }

    function _calculateBakerySwap(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256[] memory amounts,
        uint256 /*flags*/
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        rets = new uint256[](amounts.length);
        IBEP20 fromTokenReal = fromToken.isBNB() ? wbnb : fromToken;
        IBEP20 destTokenReal = destToken.isBNB() ? wbnb : destToken;
        IBakerySwapExchange exchange = bakery_swap.getPair(fromTokenReal, destTokenReal);
        if (exchange != IBakerySwapExchange(0)) {
            uint256 fromTokenBalance = fromTokenReal.universalBalanceOf(address(exchange));
            uint256 destTokenBalance = destTokenReal.universalBalanceOf(address(exchange));
            for (uint i = 0; i < amounts.length; ++i) {
                rets[i] = _calculateFormula_997(fromTokenBalance, destTokenBalance, amounts[i]);
            }
            return (rets, 120_000);
        }
    }

    function calculateBakerySwap(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        return _calculateBakerySwap(fromToken, destToken, _linearInterpolation(amount, parts), flags);
    }

    function _calculateBakerySwapOverMidToken(
        IBEP20 fromToken,
        IBEP20 midToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        uint256 gas1;
        uint256 gas2;
        rets = _linearInterpolation(amount, parts);
        (rets, gas1) = _calculateBakerySwap(fromToken, midToken, rets, flags);
        (rets, gas2) = _calculateBakerySwap(midToken, destToken, rets, flags);
        return (rets, gas1 + gas2);
    }

    function calculateBakerySwapBNB(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        if (fromToken.isBNB() || fromToken == wbnb || destToken.isBNB() || destToken == wbnb) {
            return (new uint256[](parts), 0);
        }
        return _calculateBakerySwapOverMidToken(fromToken, wbnb, destToken, amount, parts, flags);
    }

    function _calculateBscSwap(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256[] memory amounts,
        uint256 /*flags*/
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        rets = new uint256[](amounts.length);
        IBEP20 fromTokenReal = fromToken.isBNB() ? wbnb : fromToken;
        IBEP20 destTokenReal = destToken.isBNB() ? wbnb : destToken;
        IBscSwapExchange exchange = bsc_swap.getPair(fromTokenReal, destTokenReal);
        if (exchange != IBscSwapExchange(0)) {
            uint256 fromTokenBalance = fromTokenReal.universalBalanceOf(address(exchange));
            uint256 destTokenBalance = destTokenReal.universalBalanceOf(address(exchange));
            for (uint i = 0; i < amounts.length; ++i) {
                rets[i] = _calculateFormula_997(fromTokenBalance, destTokenBalance, amounts[i]);
            }
            return (rets, 120_000);
        }
    }

    function calculateBscSwap(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        return _calculateBscSwap(fromToken, destToken, _linearInterpolation(amount, parts), flags);
    }

    function _calculateBscSwapOverMidToken(
        IBEP20 fromToken,
        IBEP20 midToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        uint256 gas1;
        uint256 gas2;
        rets = _linearInterpolation(amount, parts);
        (rets, gas1) = _calculateBscSwap(fromToken, midToken, rets, flags);
        (rets, gas2) = _calculateBscSwap(midToken, destToken, rets, flags);
        return (rets, gas1 + gas2);
    }

    function calculateBscSwapBNB(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        if (fromToken.isBNB() || fromToken == wbnb || destToken.isBNB() || destToken == wbnb) {
            return (new uint256[](parts), 0);
        }
        return _calculateBscSwapOverMidToken(fromToken, wbnb, destToken, amount, parts, flags);
    }

    function _calculatePancakeSwap(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256[] memory amounts,
        uint256 /*flags*/
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        rets = new uint256[](amounts.length);
        IBEP20 fromTokenReal = fromToken.isBNB() ? wbnb : fromToken;
        IBEP20 destTokenReal = destToken.isBNB() ? wbnb : destToken;
        IPancakeSwapExchange exchange = pancake_swap.getPair(fromTokenReal, destTokenReal);
        if (exchange != IPancakeSwapExchange(0)) {
            uint256 fromTokenBalance = fromTokenReal.universalBalanceOf(address(exchange));
            uint256 destTokenBalance = destTokenReal.universalBalanceOf(address(exchange));
            for (uint i = 0; i < amounts.length; ++i) {
                rets[i] = _calculateFormula_998(fromTokenBalance, destTokenBalance, amounts[i]);
            }
            return (rets, 120_000);
        }
    }

    function calculatePancakeSwap(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        return _calculatePancakeSwap(fromToken, destToken, _linearInterpolation(amount, parts), flags);
    }

    function _calculatePancakeSwapOverMidToken(
        IBEP20 fromToken,
        IBEP20 midToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        uint256 gas1;
        uint256 gas2;
        rets = _linearInterpolation(amount, parts);
        (rets, gas1) = _calculatePancakeSwap(fromToken, midToken, rets, flags);
        (rets, gas2) = _calculatePancakeSwap(midToken, destToken, rets, flags);
        return (rets, gas1 + gas2);
    }

    function calculatePancakeSwapBNB(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        if (fromToken.isBNB() || fromToken == wbnb || destToken.isBNB() || destToken == wbnb) {
            return (new uint256[](parts), 0);
        }
        return _calculatePancakeSwapOverMidToken(fromToken, wbnb, destToken, amount, parts, flags);
    }

    function _calculateCheeseSwap(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256[] memory amounts,
        uint256 /*flags*/
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        rets = new uint256[](amounts.length);
        IBEP20 fromTokenReal = fromToken.isBNB() ? wbnb : fromToken;
        IBEP20 destTokenReal = destToken.isBNB() ? wbnb : destToken;
        ICheeseSwapExchange exchange = cheese_swap.getPair(fromTokenReal, destTokenReal);
        if (exchange != ICheeseSwapExchange(0)) {
            uint256 fromTokenBalance = fromTokenReal.universalBalanceOf(address(exchange));
            uint256 destTokenBalance = destTokenReal.universalBalanceOf(address(exchange));
            for (uint i = 0; i < amounts.length; ++i) {
                rets[i] = _calculateFormula_998(fromTokenBalance, destTokenBalance, amounts[i]);
            }
            return (rets, 120_000);
        }
    }

    function calculateCheeseSwap(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        return _calculateCheeseSwap(fromToken, destToken, _linearInterpolation(amount, parts), flags);
    }

    function _calculateCheeseSwapOverMidToken(
        IBEP20 fromToken,
        IBEP20 midToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        uint256 gas1;
        uint256 gas2;
        rets = _linearInterpolation(amount, parts);
        (rets, gas1) = _calculateCheeseSwap(fromToken, midToken, rets, flags);
        (rets, gas2) = _calculateCheeseSwap(midToken, destToken, rets, flags);
        return (rets, gas1 + gas2);
    }

    function calculateCheeseSwapBNB(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) internal view returns(uint256[] memory rets, uint256 gas) {
        if (fromToken.isBNB() || fromToken == wbnb || destToken.isBNB() || destToken == wbnb) {
            return (new uint256[](parts), 0);
        }
        return _calculateCheeseSwapOverMidToken(fromToken, wbnb, destToken, amount, parts, flags);
    }

    function _getAllReserves(uint256 my_flag) internal pure returns (function(IBEP20, IBEP20, uint256, uint256, uint256) view returns(uint256[] memory, uint256)[DEXES_COUNT] memory) {
        bool invert = my_flag.check(FLAG_DISABLE_ALL_SPLIT_SOURCES);
        return [
            _calculateNoReturn,
            invert != my_flag.check(FLAG_DISABLE_BURGER_SWAP_ALL | FLAG_DISABLE_BURGER_SWAP) ? _calculateNoReturn : calculateBurgerSwap,
            invert != my_flag.check(FLAG_DISABLE_BURGER_SWAP_ALL | FLAG_DISABLE_BURGER_SWAP_WBNB) ? _calculateNoReturn : calculateBurgerSwapBNB,
            invert != my_flag.check(FLAG_DISABLE_BURGER_SWAP_ALL | FLAG_DISABLE_BURGER_SWAP_BURGER) ? _calculateNoReturn : calculateBurgerSwapBurger,
            invert != my_flag.check(FLAG_DISABLE_BAKERY_SWAP_ALL | FLAG_DISABLE_BAKERY_SWAP) ? _calculateNoReturn : calculateBakerySwap,
            invert != my_flag.check(FLAG_DISABLE_BAKERY_SWAP_ALL | FLAG_DISABLE_BAKERY_SWAP_WBNB) ? _calculateNoReturn : calculateBakerySwapBNB,
            invert != my_flag.check(FLAG_DISABLE_BSC_SWAP_ALL | FLAG_DISABLE_BSC_SWAP) ? _calculateNoReturn : calculateBscSwap,
            invert != my_flag.check(FLAG_DISABLE_BSC_SWAP_ALL | FLAG_DISABLE_BSC_SWAP_WBNB) ? _calculateNoReturn : calculateBscSwapBNB,
            invert != my_flag.check(FLAG_DISABLE_CHEESE_SWAP_ALL | FLAG_DISABLE_CHEESE_SWAP) ? _calculateNoReturn : calculateCheeseSwap,
            invert != my_flag.check(FLAG_DISABLE_CHEESE_SWAP_ALL | FLAG_DISABLE_CHEESE_SWAP_WBNB) ? _calculateNoReturn : calculateCheeseSwapBNB,
            invert != my_flag.check(FLAG_DISABLE_PANCAKE_SWAP_ALL | FLAG_DISABLE_PANCAKE_SWAP) ? _calculateNoReturn : calculatePancakeSwap,
            invert != my_flag.check(FLAG_DISABLE_PANCAKE_SWAP_ALL | FLAG_DISABLE_PANCAKE_SWAP_WBNB) ? _calculateNoReturn : calculatePancakeSwapBNB
        ];
    }

    struct Args {
        IBEP20 fromToken;
        IBEP20 destToken;
        uint256 amount;
        uint256 parts;
        uint256 flags;
        uint256 destTokenBNBPriceTimesGasPrice;
        uint256[] distribution;
        int256[][] matrix;
        uint256[DEXES_COUNT] gases;
        function(IBEP20, IBEP20, uint256, uint256, uint256) view returns(uint256[] memory, uint256)[DEXES_COUNT] reserves;
    }

    function _getReturnAndGasByDistribution(Args memory args) internal view returns (uint256 returnAmount, uint256 estimateGasAmount) {

        for (uint i = 0; i < DEXES_COUNT; ++i) {
            if (args.distribution[i] > 0) {
                estimateGasAmount = estimateGasAmount.add(args.gases[i]);
                int256 value = args.matrix[i][args.distribution[i]];
                returnAmount = returnAmount.add(uint256((value == VERY_NEGATIVE_VALUE ? 0 : value) +
                    int256(args.gases[i].mul(args.destTokenBNBPriceTimesGasPrice))
                ));
            }
        }
    }

    function getExpectedReturnWithGas(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags,
        uint256 destTokenBNBPriceTimesGasPrice
    ) public view returns(uint256 returnAmount, uint256 estimateGasAmount, uint256[] memory distribution) {

        distribution = new uint256[](DEXES_COUNT);
        if (fromToken == destToken) {
            return (amount, 0, distribution);
        }

        function(IBEP20,IBEP20,uint256,uint256,uint256) view returns(uint256[] memory, uint256)[DEXES_COUNT] memory reserves = _getAllReserves(flags);

        int256[][] memory matrix = new int256[][](DEXES_COUNT);
        uint256[DEXES_COUNT] memory gases;
        bool atLeastOnePositive = false;

        for (uint i = 0; i < DEXES_COUNT; ++i) {
            uint256[] memory rets;
            (rets, gases[i]) = reserves[i](fromToken, destToken, amount, parts, flags);

            // Prepend zero and sub gas
            int256 gas = int256(gases[i].mul(destTokenBNBPriceTimesGasPrice));
            matrix[i] = new int256[](parts + 1);
            for (uint j = 0; j < rets.length; j++) {
                matrix[i][j + 1] = int256(rets[j]) - gas;
                atLeastOnePositive = atLeastOnePositive || (matrix[i][j + 1] > 0);
            }
        }

        if (!atLeastOnePositive) {
            for (uint i = 0; i < DEXES_COUNT; i++) {
                for (uint j = 1; j < parts + 1; j++) {
                    if (matrix[i][j] == 0) {
                        matrix[i][j] = VERY_NEGATIVE_VALUE;
                    }
                }
            }
        }

        (, distribution) = _findBestDistribution(parts, matrix);

        (returnAmount, estimateGasAmount) = _getReturnAndGasByDistribution(
            Args({
                fromToken: fromToken,
                destToken: destToken,
                amount: amount,
                parts: parts,
                flags: flags,
                destTokenBNBPriceTimesGasPrice: destTokenBNBPriceTimesGasPrice,
                distribution: distribution,
                matrix: matrix,
                gases: gases,
                reserves: reserves
            })
        );
        return (returnAmount, estimateGasAmount, distribution);
    }

    function getExpectedReturn(
        IBEP20 fromToken,
        IBEP20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    ) public view returns(uint256 returnAmount, uint256[] memory distribution) {
        (returnAmount, , distribution) = getExpectedReturnWithGas(fromToken, destToken, amount, parts, flags, 0);
    }
}
