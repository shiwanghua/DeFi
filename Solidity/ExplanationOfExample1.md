# Contract Source Code Explanation

## interface: IBEP20

* 声明了一些函数
* totalSupply
* decimals
* symbol
* ......

## library: SafeMath 
* add
* sub
* mul
* div
* mod

## contract: Context

* _msgSender
* _msgData

## contract: Ownable is Context

* 通过地址的形式来处理合约所有权的问题
* 合约所有者的地址为“_owner”，数据类型是“address private”
* 构造函数：先调用Context的_msgSender函数得到调用合约的用户地址，初始化合约内部的所有者地址_owner，触发一个事件“OwnershipTransferred”通知前端合约所有者地址已经转移成功
* onlyOwner函数：判断调用函数的用户是不是合约所有者，是modifier类型的，可以用来修饰函数，调用被修饰函数前先调用onlyOwner进行权限判断
* renounceOwnership：当前用户放弃自己对合约的所有权，并触发所有权转移事件，新地址为0，表示该合约目前没有所有者了
* _transferOwnership：转移合约的所有权，新所有者地址不能为0，触发所有权转移事件

## contract: BEP20Token is Context, IBEP20, Ownable

* 实现 IBEP20 接口里的函数

* transfer 转移资产

* approve通过某个补助(Allowance)设置事件

* Allowance加减功能

* mint增加货币总供应，_burnFrom减少货币总供应，并且会减少allowance


