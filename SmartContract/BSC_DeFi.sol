pragma solidity >=0.4.22 <0.7.0;

// BurgerSwap 0x9FdC672a33f34675253041671abd214F2387b7aB
interface DemaxPlatform{
     function getAmountsOut(uint256 amountIn, address[] calldata path) external returns (uint256[] memory amounts);
}

// pancakeswap 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F
interface PancakeRouter{
    function getAmountsOut(uint amountIn, address[] calldata path) external returns (uint[] memory amounts);
}

// BakerySwap  0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F
interface BakerySwapRouter{
  function getAmountsOut(uint256 amountIn, address[] calldata path) external returns (uint256[] memory amounts);
}

// BSCswap 0xd954551853F55deb4Ae31407c423e67B1621424A
interface BSCswapRouter{
     function getAmountsOut(uint amountIn, address[] calldata path) external returns (uint[]memory amounts);
}

// CheeseSwap 0x3047799262d8D2EF41eD2a222205968bC9B0d895
interface CheeseSwapRouter{
     function getAmountsOut(uint amountIn, address[] calldata path) external returns (uint[] memory amounts);
    
}

// interface hello_original {
//     function get_z() view external returns (uint);
//     function set_z(uint) external returns (uint);
// }
// remix 本合约地址：
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
    
}