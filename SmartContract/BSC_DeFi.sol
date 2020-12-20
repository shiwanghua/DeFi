pragma solidity >=0.6.6;

// BurgerSwap 0x9FdC672a33f34675253041671abd214F2387b7aB
interface DemaxPlatform{
     function getAmountsOut(uint256 amountIn, address[] calldata path) external returns (uint256[] memory amounts);
     function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
}

// pancakeswap 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F
interface PancakeRouter{
    function getAmountsOut(uint amountIn, address[] calldata path) external returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
}

// BakerySwap  0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F
interface BakerySwapRouter{
  function getAmountsOut(uint256 amountIn, address[] calldata path) external returns (uint256[] memory amounts);
  function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
}

// BSCswap 0xd954551853F55deb4Ae31407c423e67B1621424A
interface BSCswapRouter{
     function getAmountsOut(uint amountIn, address[] calldata path) external returns (uint[]memory amounts);
     function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
     //function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
}

// CheeseSwap 0x3047799262d8D2EF41eD2a222205968bC9B0d895
interface CheeseSwapRouter{
     function getAmountsOut(uint amountIn, address[] calldata path) external returns (uint[] memory amounts);
     function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
}

// interface hello_original {
//     function get_z() view external returns (uint);
//     function set_z(uint) external returns (uint);
// }

// 5个交易所都支持的pair：['0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c','0x55d398326f99059fF775485246999027B3197955']

//
contract BSC_Defi {

    DemaxPlatform burgerSwap = DemaxPlatform(0x9FdC672a33f34675253041671abd214F2387b7aB);
    PancakeRouter pancakeSwap = PancakeRouter(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);
    BakerySwapRouter bakerySwap = BakerySwapRouter(0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F);
    BSCswapRouter bscSwap = BSCswapRouter(0xd954551853F55deb4Ae31407c423e67B1621424A);
    CheeseSwapRouter cheeseSwap = CheeseSwapRouter(0x3047799262d8D2EF41eD2a222205968bC9B0d895);

    constructor( ) public {

    }

    function query_prices(uint amountIn, address[] memory path) public returns(uint[] memory amounts ){
        amounts=new uint[](5);

        amounts[0]=burgerSwap.getAmountsOut(amountIn,path)[1];
        amounts[1]=pancakeSwap.getAmountsOut(amountIn,path)[1];
        amounts[2]=bakerySwap.getAmountsOut(amountIn,path)[1];
        amounts[3]=bscSwap.getAmountsOut(amountIn,path)[1];
        amounts[4]=cheeseSwap.getAmountsOut(amountIn,path)[1];

    }

    function swapExactTokensForTokensInASwap(uint swapID, uint amountIn, uint amountOutMin, address[] memory path, address to, uint deadline) public payable returns (uint[] memory amounts_return){
      amounts_return = new uint[](path.length);
      // amounts_return = bscSwapDeployed.swapExactBNBForTokens(amountIn,amountOutMin,path,to,deadline);
      if(swapID==1)
          amounts_return = burgerSwap.swapExactTokensForTokens(amountIn, amountOutMin,path,to,deadline);
      else if(swapID==2)
          amounts_return = pancakeSwap.swapExactTokensForTokens(amountIn, amountOutMin,path,to,deadline);
      else if(swapID==3)
          amounts_return = bakerySwap.swapExactTokensForTokens(amountIn, amountOutMin,path,to,deadline);
      else if(swapID==4)
          amounts_return = bscSwap.swapExactTokensForTokens(amountIn, amountOutMin,path,to,deadline);
      else
          amounts_return = cheeseSwap.swapExactTokensForTokens(amountIn, amountOutMin,path,to,deadline);

   }
}
