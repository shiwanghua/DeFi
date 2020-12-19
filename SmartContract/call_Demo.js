(async () => {
        try {
        const abi_Demo_Call_MoniSwap = [
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "amountIn",
				"type": "uint256"
			},
			{
				"internalType": "address[]",
				"name": "path",
				"type": "address[]"
			}
		],
		"name": "test_getAmountsOut",
		"outputs": [
			{
				"internalType": "uint256[]",
				"name": "amounts",
				"type": "uint256[]"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]
// ['0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c','0x55d398326f99059fF775485246999027B3197955']
// ['0x77d57b72d547035b51d1b722796bf23cd46b5186','0xae13d989dac2f0debff460ac112a837c89baa7cd']
            const contractAddress = '0xfcb3a08f50271e4c45c737d587e532766370e4c4'
            // let contract = new web3.eth.Contract(hello_abi, contractAddress)
            let contract = new web3.eth.Contract(abi_Demo_Call_MoniSwap,contractAddress)
            let name = await contract.methods.test_getAmountsOut(500,['0x77d57b72d547035b51d1b722796bf23cd46b5186','0xae13d989dac2f0debff460ac112a837c89baa7cd']).call()
            // let name =  await contract.methods.query_prices(500,['0x77d57b72d547035b51d1b722796bf23cd46b5186','0xae13d989dac2f0debff460ac112a837c89baa7cd']).call()
            // let name = await contract.methods.test_set_z(100).send({from:'0x344F14b0Ea7a1CFfd17D7887E007D482BB4320a5'})
            console.log(name)

        } catch (e) {
            console.log(e.message)
        }

    })()
