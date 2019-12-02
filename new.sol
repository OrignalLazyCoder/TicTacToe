pragma solidity ^0.5.1;

contract TicTacToe{

    //TODO : Do proper comments
    
    
    //enum contains all possible values of Winner and Players
    enum Player { none, playerOne, playerTwo }
    enum Winner { none, playerOne, playerTwo, draw }
    
    //Data structure of Game which will be created by user
    struct Game{
        address playerOne;
        address playerTwo;
        Winner winner;
        Player playerTurn;
        Player[3][3] board;
        bool assignedPlayerOne;
        uint lastMove;
        bool isGameStarted;
    }
    
    //we have to create a mapping to store all active and created games
    mapping(uint256 => Game) private games;
    
    //totalNumberOfGames contains  index of Games
    uint256 totalNumberOfGames;
    
    //Buy tokens first
    mapping(address => uint) public playerTokenCount;
    
    function buyToken() public payable{
        require(msg.value > 0 && msg.value >= 100000000000000000, "Please send some valid number of ether to buy tokens(greater than 0.1)");
        //let price be 1 token for 0.1 eth
        // number of token = eth sent * 10
        playerTokenCount[msg.sender] = playerTokenCount[msg.sender] + (msg.value/100000000000000000);
        emit BoughtTokens(msg.value);
    }
    
    //This function is responsible to convert the token which a user a bought
    //into ether which can be stored in ethereum wallet
    function convertTokenToEther() public{
        require(playerTokenCount[msg.sender] > 0 ,"You need to have some tokens first");
        msg.sender.transfer(playerTokenCount[msg.sender]*100000000000000000);
        playerTokenCount[msg.sender] = 0;
        emit WithdrawMoney(msg.sender);
    }
    
    //Use tokens to enter the game
    function createNewGame() hasTicCredits public returns(uint256){
        //creation of Game is free of tokens
        Game memory game;
        game.winner = Winner.none;
        game.playerTurn = Player.playerOne;
        game.assignedPlayerOne = false;
        game.isGameStarted = false;
        totalNumberOfGames = totalNumberOfGames + 1;
        games[totalNumberOfGames] = game;
        emit GameCreated(totalNumberOfGames, msg.sender);
        return totalNumberOfGames;
    }
    
    //Join a game by knowing the gameId of the game
    function joinAGame(uint256 _gameId) hasTicCredits public returns(bool,string memory){
        //First check if game exist or not
        if(_gameId > totalNumberOfGames){
            return (false, "No such game exist");
        }
        //if Game exist but was finished then return false
        if(games[_gameId].winner != Winner.none){
            return (false , "Game has already finished");
        }
        //assign position to players
        //check for empty slots as playerOne or playerTwo
        if(games[_gameId].assignedPlayerOne && games[_gameId].playerTwo == address(0)){
            games[_gameId].playerTwo = msg.sender;
            emit JoinedGame(_gameId, msg.sender,"Player Two");
            return (true, "Joined as player two");
        }
        if(games[_gameId].playerOne == address(0) && games[_gameId].assignedPlayerOne == false){
            games[_gameId].playerOne = msg.sender;
            emit JoinedGame(_gameId,msg.sender,"Player One");
            games[_gameId].assignedPlayerOne = true;
            return (true, "Joined as Player One");
        }
        //if both slots are taken then return false
        return (false,"Both slots are already Taken");
    }
    
    function makeAMove(uint256 _gameId, uint _x, uint _y) public returns(bool,string memory){
        
        //check if all players are assigned or not
        if(games[_gameId].playerOne == address(0) || games[_gameId].playerTwo == address(0)){
            emit Message("All players are not assigned yet");
            return (false, "All players are not assigned yet");
        }
        
        //check if game has ended or not
        if(games[_gameId].winner != Winner.none){
            emit Message("Game has ended");
            return (false, "Game has ended!");
        }
        
        //get current player and check if it is player's turn or not
        if(msg.sender != checkPlayerTurn(_gameId)){
            emit Message("Not your turn buddy");
            return (false, "Not your turn buddy!");
        }

        if(games[_gameId].isGameStarted == false || (games[_gameId].isGameStarted == true && (games[_gameId].lastMove+15) <= now)){
            
            games[_gameId].isGameStarted = true;
            //Check if desired cell is already used or not
            if(games[_gameId].board[_x][_y] != Player.none){
                emit Message("The desired cell is already taken ");
                return (false, "The desired cell is already taken");
            }
            
            //add player marker to the cell in board
            games[_gameId].board[_x][_y] = games[_gameId].playerTurn;
            games[_gameId].lastMove = now;
            emit PlayerMoved(_gameId, _x, _y);
            
            //check for Winner
            Winner  winner = calculateWinner(_gameId);
            if(winner != Winner.none){
                games[_gameId].winner = winner;
                //decrease one token from the loser accounts and add it to the winners account
                if(winner == Winner.playerOne){
                    playerTokenCount[games[_gameId].playerOne]++;
                    playerTokenCount[games[_gameId].playerTwo]--;
                    emit Message("Player one has won");
                    emit GameOver(_gameId,"Player one has won");
                }
                if(winner == Winner.playerTwo){
                    playerTokenCount[games[_gameId].playerOne]--;
                    playerTokenCount[games[_gameId].playerTwo]++;
                    emit Message("Player two has won");
                    emit GameOver(_gameId,"Player two has won");
                }
                else{
                    emit GameOver(_gameId,"Draw");
                    emit Message("Draw");
                    return(false,"Draw Game");
                }
                return (true, "Congratulations. You have won 2 ticTokens");
            }
            
            nextPlayer(_gameId);
            
            emit Message("Wait for apponents turn");
            return (true, "Your move has been recorded. Please wait for another player to make a move");
        }
        else{
            emit Message("Your session has expired! Another player has won the match");
            if(games[_gameId].playerTurn == Player.playerOne){
                playerTokenCount[games[_gameId].playerOne]++;
                playerTokenCount[games[_gameId].playerTwo]--;
            }else{
                playerTokenCount[games[_gameId].playerOne]--;
                playerTokenCount[games[_gameId].playerTwo]++;
            }
            return (false,"Game has ended as one player failed to make a move in given Time");
        }
        
    }
    
    //check whose turns is it to make the move
    function checkPlayerTurn(uint256 _gameId) private returns(address){
        if(games[_gameId].playerTurn == Player.playerOne ){
            return games[_gameId].playerOne;
        }
        
        if(games[_gameId].playerTurn == Player.playerTwo){
            return games[_gameId].playerTwo;
        }
        
        return address(0);
    }
    
    //after a making a move, this function will change the player who will make the move.
    function nextPlayer(uint256 _gameId) private{
        if(games[_gameId].playerTurn == Player.playerOne){
            games[_gameId].playerTurn = Player.playerTwo;
        }else{
            games[_gameId].playerTurn = Player.playerOne;
        }
    }
    

    function calculateWinner(uint256 _gameId) private returns(Winner){
        
        //First check if the any row combination is being made up or not
        Player player = winnerInRow(_gameId);
        if(player == Player.playerOne){
            return Winner.playerOne;
        } if(player == Player.playerTwo){
            return Winner.playerTwo;
        }
        
        //Check if any column combination is being made up or not
        player = winnerInColumn(_gameId);
        if(player == Player.playerOne){
            return Winner.playerOne;
        } if(player == Player.playerTwo){
            return Winner.playerTwo;
        }
        

        //check if any diagonal combination is being made up or not
        player = winnerInDiagnal(_gameId);
        if(player == Player.playerOne){
            return Winner.playerOne;
        } if(player == Player.playerTwo){
            return Winner.playerTwo;
        }
        
        //check if board is full or not. If yes then set status as Draw game
        if(isBoardFull(_gameId)){
            return Winner.draw;
        }
        
        return Winner.none;
    }
    
    function winnerInRow(uint256 _gameId) private returns(Player){
        for (uint8 x = 0; x < 3; x++) {
            if (
                games[_gameId].board[x][0] == games[_gameId].board[x][1]
                && games[_gameId].board[x][1]  == games[_gameId].board[x][2]
                && games[_gameId].board[x][0] != Player.none
            ) {
                return games[_gameId].board[x][0];
            }
        }
        return Player.none;
    }
    
    function winnerInColumn(uint256 _gameId) private returns(Player){
        for (uint8 y = 0; y < 3; y++) {
            if (
                games[_gameId].board[0][y] == games[_gameId].board[1][y]
                && games[_gameId].board[1][y] == games[_gameId].board[2][y]
                && games[_gameId].board[0][y] != Player.none
            ) {
                return games[_gameId].board[0][y];
            }
        }
        return Player.none;
    }
    
    function winnerInDiagnal(uint256 _gameId) private returns(Player){
         if (
            games[_gameId].board[0][0] == games[_gameId].board[1][1]
            && games[_gameId].board[1][1] == games[_gameId].board[2][2]
            && games[_gameId].board[0][0] != Player.none
        ) {
            return games[_gameId].board[0][0];
        }

        if (
            games[_gameId].board[0][2] == games[_gameId].board[1][1]
            && games[_gameId].board[1][1] == games[_gameId].board[2][0]
            && games[_gameId].board[0][2] != Player.none
        ) {
            return games[_gameId].board[0][2];
        }
        
        return Player.none;
    }
    
    function isBoardFull(uint256 _gameId) private returns(bool){
        uint count = 0;
        for(uint8 x = 0; x < 3 ; x++){
            for(uint8 y = 0; y < 3;y++){
                if(games[_gameId].board[x][y]==Player.playerOne || games[_gameId].board[x][y] == Player.playerTwo){
                    count = count + 1;
                }
            }
        }
        if(count == 9){
            return true;
        }
        
        return false;
    }
    
    //modifier
    modifier hasTicCredits{
        require(playerTokenCount[msg.sender] > 0, "You need to buy tokens first");
        _;
    }
    
    //events
    event BoughtTokens(uint value);
    event WithdrawMoney(address player);
    event GameCreated(uint256 gameId, address gameCreator);
    event JoinedGame(uint gameId,address player,string playerID);
    event GameOver(uint gameId, string winStatus);
    event PlayerMoved(uint gameId, uint x,uint y);
    event Message(string message);
}