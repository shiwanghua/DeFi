pragma solidity >=0.4.22 <0.7.0;

interface hello_original {
    function get_z() view external returns (uint);
    function set_z(uint) external returns (uint);
    function getAmountsOut(uint256 amountIn, address[] calldata path) external returns (uint256[] memory amounts);
}
// remix 测试网部署合约：0x443C61Ee7B9B100c544b2154bdCB44afa8488CAe  
//       测试网调用合约: 0xfbdea2632f1bf938ac2780c0795b2c0a4549e436    
contract Hello2 {

    hello_original helloDeployed=hello_original(0x443C61Ee7B9B100c544b2154bdCB44afa8488CAe);
    constructor( ) public {

    }

    function test_set_z(uint a) external returns(uint){
        return helloDeployed.set_z(a);
    }
    
    function test_get_z() public view returns(uint){
        return helloDeployed.get_z();
    }
    
    function test_getAmountsOut(uint amountIn, address[] memory path) public returns(uint[] memory amounts ){
        amounts=new uint[](5);
        amounts[0]=0;
        amounts[1]=amountIn;
        amounts[2]=helloDeployed.getAmountsOut(amountIn,path)[1];   
        amounts[3]=amountIn*3;
        amounts[4]=amountIn*4;
    }

}


//ABI:
// [
// 	{
// 		"constant": false,
// 		"inputs": [
// 			{
// 				"name": "a",
// 				"type": "uint256"
// 			}
// 		],
// 		"name": "test_set_z",
// 		"outputs": [
// 			{
// 				"name": "",
// 				"type": "uint256"
// 			}
// 		],
// 		"payable": false,
// 		"stateMutability": "nonpayable",
// 		"type": "function"
// 	},
// 	{
// 		"constant": false,
// 		"inputs": [
// 			{
// 				"name": "amountIn",
// 				"type": "uint256"
// 			},
// 			{
// 				"name": "path",
// 				"type": "address[]"
// 			}
// 		],
// 		"name": "test_getAmountsOut",
// 		"outputs": [
// 			{
// 				"name": "amounts",
// 				"type": "uint256[]"
// 			}
// 		],
// 		"payable": false,
// 		"stateMutability": "nonpayable",
// 		"type": "function"
// 	},
// 	{
// 		"constant": true,
// 		"inputs": [],
// 		"name": "test_get_z",
// 		"outputs": [
// 			{
// 				"name": "",
// 				"type": "uint256"
// 			}
// 		],
// 		"payable": false,
// 		"stateMutability": "view",
// 		"type": "function"
// 	},
// 	{
// 		"inputs": [],
// 		"payable": false,
// 		"stateMutability": "nonpayable",
// 		"type": "constructor"
// 	}
// ]