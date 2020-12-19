
// var Web3 = require('web3');

// if (typeof web3 !== 'undefined') {
//   web3 = new Web3(web3.currentProvider);
// } else {
//   // set the provider you want from Web3.providers
//   web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
// }

// var from = web3.eth.accounts[0];
// //部署合约的发布地址
// /*合约内容如下
// pragma solidity ^0.4.0;

// contract Calc{
//   function add(uint a, uint b) returns (uint){
//     return a + b;
//   }
// }
//、 */
// var to = "0xa4b813d788218df688d167102e5daff9b524a8bc";

// //要发送的数据
// //格式说明见： http://me.tryblockchain.org/Solidity-call-callcode-delegatecall.html
// var data = "0x771602f700000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002";

// var result = web3.eth.call({
//   from : from,
//   to : to,
//   data : data
// });

// //返回结果32字长的结果3
// console.log(result);

// 引入依赖模块
var express = require("express")
var Web3 = require("web3")
var net = require("net")
var http = require("http")

const createMetaMaskProvider = require('metamask-extension-provider')
const provider = createMetaMaskProvider()

provider.on('error', (error) => {
//   // Failed to connect to MetaMask, fallback logic.
  alert("no provider !")
})


//const web3 = new Web3(window.web3.currentProvider);//use NOKIA card
//web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));
// var web3;
// // 创建web3对象并连接到以太坊节点
if (typeof web3 !== 'undefined') {
  web3 = new Web3(web3.currentProvider);
} else {
  // set the provider you want from Web3.providers
  web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
}
// 合约ABI
const abi =[
	{
		"constant": false,
		"inputs": [],
		"name": "get_z",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [ 
			{
				"name": "input",
				"type": "uint256"
			}
		],
		"name": "set_z",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"name": "input",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	}
]// 合约地址
var address = "0x4554d052b9fb31f423B5d08AE9d42E82a8AeD003";
// 通过ABI和地址获取已部署的合约对象
var helloContract = new web3.eth.Contract(abi,address);
 
http.createServer(function (request, response) {
    
    // 调用智能合约方法
    var helloResult = helloContract.methods.getz().call().then(function(result){
    console.log("返回值:" + result);
    // 发送 HTTP 头部 
    // HTTP 状态值: 200 : OK
    // 内容类型: text/plain
    response.writeHead(200, {'Content-Type': 'text/plain'});
    
    // 发送响应数据
    response.end(result);
});
    
}).listen(8888);
 
// 终端打印如下信息
console.log('Server running at http://127.0.0.1:8888/');