  pragma solidity >=0.6.6; // BurgerSwap


  // 本合约在BSC测试链地址：0x9bF2A252647432686052657cc21F5e353b47dd8c
  contract MoniSwap {

      function getAmountsOut(uint256 amountIn, address[] memory path) public pure returns (uint256[] memory amounts) {
          amounts=new uint[](2);
          amounts[0]=amountIn;
          amounts[1]=amountIn*2;
      }

  }

  // [
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
  // 		"name": "getAmountsOut",
  // 		"outputs": [
  // 			{
  // 				"internalType": "uint256[]",
  // 				"name": "amounts",
  // 				"type": "uint256[]"
  // 			}
  // 		],
  // 		"stateMutability": "pure",
  // 		"type": "function"
  // 	}
  // ]
