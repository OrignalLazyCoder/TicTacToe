Steps to run Tic-Tac-Toe Game.
Pre-requisites:
1.	Ganache
2.	Truffle-cli
3.	Solc compiler

Function available to user with parameters
1.	buyToken()
a.	User has to send a certain amount of ether to smart contract to buy tokens to play the game
b.	Price : 0.1 eth = 1 Token
2.	convertTokenToEther()
a.	User can redeem earned tokens and convert them back the eth
3.	createNewGame()
a.	A new game can be created by this function and user will receive the gameId so he can play it and share it
4.	joinAGame(uint256 _gameId)
a.	To join a game, a user must know the gameId 
5.	makeAMove(uint256 _gameId, uint _x,uint _y)
a.	To make a move, a gameId, x and y co-ordinates are required of the board like [(0,0) to (2,2)] in 15 seconds from the last player’s move
6.	playerTokenCount(address): Check tokens in users account

Steps required to be performed to play the game on truffle-CLI
1.	Go to projects root directory and open terminal
2.	Run the following commands:
•	truffle console
•	let inst = await TicTacToe.deployed()
•	let accounts = await web3.eth.getAccounts()
•	res = await inst.buyTokens({from:accounts[0],value:100000000000000000})
•	res = await inst.buyToken({from:accounts[1],value:100000000000000000})  
•	res = await inst.createNewGame({from:accounts[0]})
•	res = await inst.joinAGame(1,{from:accounts[0]})  
•	res = await inst.joinAGame(1,{from:accounts[1]})  
•	res = await inst.makeAMove(1,0,0,{from:accounts[0]})
•	res = await inst.makeAMove(1,1,0,{from:accounts[1]})  
•	res = await inst.makeAMove(1,0,1,{from:accounts[0]})  
•	res = await inst.makeAMove(1,1,1,{from:accounts[1]})    
•	res = await inst.makeAMove(1,0,2,{from:accounts[0]})
3.	User can convert tokens back to ether by following command
•	Check number of tokens
i.	inst.playerTokenCount(accounts[0])
•	Convert back to ether
i.	res = await inst.convertTokenToEther()  
Note:
	Run “res.logs” after any command to check for logs


