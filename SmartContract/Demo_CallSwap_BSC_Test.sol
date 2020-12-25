pragma solidity >=0.6.6;// BurgerSwap

interface MoniSwapInterface {
    function getAmountsOut(uint256 amountIn, address[] calldata path) external returns (uint256[] memory amounts);
}

interface PancakeSwapInterface {
  function getAmountsOut(uint amountIn, address[] calldata path) external returns (uint[] memory amounts);
}


interface bakerySwapInterface {
    function getAmountsOut(uint256 amountIn, address[] calldata path) external returns (uint256[] memory amounts);
}

interface bscSwapInterface {
    function getAmountsOut(uint256 amountIn, address[] calldata path) external returns (uint256[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function approve(address guy, uint wad) external returns (bool);
}

// pancakeswap: 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F
// BakerySwap:  0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F
// BSCswap:     0xd954551853F55deb4Ae31407c423e67B1621424A

contract Demo_Call_MoniSwap {

    MoniSwapInterface moniSwapDeployed=MoniSwapInterface(0x9bF2A252647432686052657cc21F5e353b47dd8c);
    PancakeSwapInterface pancakeSwapDeployed = PancakeSwapInterface(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);
    bakerySwapInterface bakerySwapDeployed = bakerySwapInterface(0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F);
    bscSwapInterface bscSwapDeployed = bscSwapInterface(0xd954551853F55deb4Ae31407c423e67B1621424A);

    function test_getAmountsOut(uint amountIn, address[] memory path) public returns(uint[] memory amounts ){
        amounts=new uint[](5);
        amounts[0]=amountIn;
        amounts[1]=moniSwapDeployed.getAmountsOut(amountIn,path)[1];
        amounts[2]=amountIn*2;
        amounts[3]=amountIn*3;
        // amounts[2]=pancakeSwapDeployed.getAmountsOut(amountIn,path)[1];
        // amounts[3]=bakerySwapDeployed.getAmountsOut(amountIn,path)[1];
        amounts[4]=bscSwapDeployed.getAmountsOut(amountIn,path)[1];
    }

    function test_bscSwap(uint amountIn, uint amountOutMin, address[] memory path, address to, uint deadline) public payable returns (uint[] memory amounts_return){
        amounts_return = new uint[](path.length);
        address p0 = path[0];
        bscSwapInterface(p0).approve(msg.sender, amountIn);
        amounts_return = bscSwapDeployed.swapExactTokensForTokens{value: msg.value}(amountIn,amountOutMin,path,to,deadline);

    }

    function test_swapExactBNBForTokens(uint amountOutMin, address[] memory path, address to, uint deadline)public payable returns (uint[] memory amounts_return){
        amounts_return = new uint[](path.length);
        amounts_return = bscSwapDeployed.swapExactBNBForTokens{value: msg.value}(amountOutMin,path,to,deadline);
    }
}
