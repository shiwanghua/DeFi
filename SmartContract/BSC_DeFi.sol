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
// 本合约在BSC测试链地址：
//  5次：0x74508F87ec6E34A148bD592Cf6700a38a56e89a4
//  只查询BSCSwap:  0xc393c707fffe86283a2e2f314c63067a1088e933

// 5个交易所都支持的pair：['0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c','0x55d398326f99059fF775485246999027B3197955']

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


// [
// 	{
// 		"inputs": [],
// 		"stateMutability": "nonpayable",
// 		"type": "constructor"
// 	},
// 	{
// 		"inputs": [
// 			{
// 				"internalType": "uint256",
// 				"name": "amountIn",
// 				"type": "uint256"
// 			},
// 			{
// 				"internalType": "address[]",
// 				"name": "path",
// 				"type": "address[]"
// 			}
// 		],
// 		"name": "query_prices",
// 		"outputs": [
// 			{
// 				"internalType": "uint256[]",
// 				"name": "amounts",
// 				"type": "uint256[]"
// 			}
// 		],
// 		"stateMutability": "nonpayable",
// 		"type": "function"
// 	}
// ]
