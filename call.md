### 调用uniswap接口以获得询价数据

* getAmountsOut: 询价

  * function getAmountsOut(uint amountIn, address[] memory path) internal view returns (uint[] memory amounts);(源码里还有个address factory参数，文档里漏了)

  * input:
    * amountIn: 想交易的数量
    * path: 一系列Token地址组成的数组（会检测数组长度必须>=2)
  * output:
    * amounts: 
      * amounts[0]是初始货币amountIn，币种是path中第一个和第二个数值中较小的那个token
      * 设i>=1, $a_i$表示第 i-1个货币和第 i 个货币中地址较小的那个货币，$b_i$表示第i-1个货币和第i个货币中地址较大的那个货币
      * amount[i] 表示用 amount[i-1] 个 $a_i$ 货币可以换 $b_i$ 货币的个数，每次要交换的货币个数都不相同
  * call(内部先后会调用的函数):
    * getReserves(Library): 对path数组中每相邻两个token组成的pair(没有实际组成pair对象)都调用一次Library中的getReserves函数
    * getAmountOut: 将getReserves输出作为getAmountOut的输入，即每相邻两个token做一次询价

* getReserves(Library):

  * function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB);
  * UniswapV2Library 合约里的函数
  * input:
    * factory: 工厂地址（？）
    * tokenA、tokenB: 想交易的两种货币的地址
  * output: 
    * 将factory、tokenA、tokenB组成一个IUniswapV2Pair对象，调用这个对象的getReserves得到A、B按地址排序的储备量$r_A,r_B$
    * 如果tokenA<tokenB, 返回$r_A,r_B$
    * 如果tokenA>tokenB,返回$r_B,r_A$
    * tokenA=tokenB时会报错: 'UniswapV2Library: IDENTICAL_ADDRESSES'
  * call: getReserves(Pair)

* getReserves(Pair):

  * function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

  * UniswapV2Pair 合约里的函数

  * output:

    * 一个pair里两种token的储备量（就是一个简单的get私有数据函数）

    * blockTimestampLast: 最后一个进行A换B交易的block的时间戳(mod 2**32)

* getAmountOut:

  * function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut);
  * 伪代码：（恒定乘积做市商）
    * amountIn$<=0$ 则报错: 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT'
    * reserveIn、reserveOut都要大于0，否则报错: 'UniswapV2Library: INSUFFICIENT_LIQUIDITY'
    * amountInWithFee=amountIn*997（0.3%的交易费）
    * numerator=amountInWithFee*reserveOut
    * denominator=reserveIn*1000+amountInWithFee
    * 输出amountOut=numerator/denominator
  * 恒定乘积做市商model…
  * output: 
    * amountOut：amountIn个A币可以换B币的个数

* swap: 进行交易
  * function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

