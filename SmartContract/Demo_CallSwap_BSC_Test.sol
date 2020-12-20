pragma solidity >=0.6.6;// BurgerSwap

interface MoniSwapInterface {
  //  function get_z() view external returns (uint);
  //  function set_z(uint) external returns (uint);
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
    // function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
}

// pancakeswap: 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F
// BakerySwap:  0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F
// BSCswap:     0xd954551853F55deb4Ae31407c423e67B1621424A

// remix 测试网部署合约：0x9bF2A252647432686052657cc21F5e353b47dd8c
//       测试网调用合约: 0xfcb3a08f50271e4c45c737d587e532766370e4c4
contract Demo_Call_MoniSwap {

    MoniSwapInterface moniSwapDeployed=MoniSwapInterface(0x9bF2A252647432686052657cc21F5e353b47dd8c);
    PancakeSwapInterface pancakeSwapDeployed = PancakeSwapInterface(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);
    bakerySwapInterface bakerySwapDeployed = bakerySwapInterface(0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F);
    bscSwapInterface bscSwapDeployed = bscSwapInterface(0xd954551853F55deb4Ae31407c423e67B1621424A);

    // function test_set_z(uint a) external returns(uint){
    //     return helloDeployed.set_z(a);
    // }

    // function test_get_z() public view returns(uint){
    //     return helloDeployed.get_z();
    // }

    //     function test_if(uint swapi)public returns (uint a){
    //     if(swapi==1) return swapi*10;
    //     else if (swapi==2) return swapi*100;
    //     else return swapi*1000;
    // }

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
        // amounts_return = bscSwapDeployed.swapExactTokensForTokens(amountIn,amountOutMin,path,to,deadline);
        amounts_return = bscSwapDeployed.swapExactBNBForTokens(amountOutMin,path,to,deadline);
    }


}
