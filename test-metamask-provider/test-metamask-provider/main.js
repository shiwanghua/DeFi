var Web3 = require("web3")
var net = require("net")
var http = require("http")


const express = require('express');
const app = new express();
const ejs = require('ejs');
const path = require('path');
app.set('views',path.join(__dirname,'views'));
app.engine('.html',ejs.__express);
app.set('view engine','html');

app.use(express.static(path.join(__dirname,'public')));//放css\js等文件


const createMetaMaskProvider = require('metamask-extension-provider')

// const provider = createMetaMaskProvider()
console.log(provider)
provider.on('error', (error) => {
  // Failed to connect to MetaMask, fallback logic.
  console.log(error)
  alert("no provider !")
})
if (typeof web3 !== 'undefined') {
  web3 = new Web3(web3.currentProvider);
  alert('web3-currentProvider')
} else {
  // set the provider you want from Web3.providers
  web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  alert('web3-local-8545')
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


var server = app.listen(8081,function(){
	var host = server.address().address;
	var port = server.address().port;
	console.log("应用实例，访问地址为  %s:%s",host,port);

	    // 调用智能合约方法
		// var helloResult = helloContract.methods.getz().call().then(function(result){
		// 	console.log("返回值:" + result);
		// 	// 发送 HTTP 头部 
		// 	// HTTP 状态值: 200 : OK
		// 	// 内容类型: text/plain
		// 	response.writeHead(200, {'Content-Type': 'text/plain'});
			
		// 	// 发送响应数据
		// 	response.end(result);
		// });
});

app.get('/', function(req, res){
  	res.render('index');
});