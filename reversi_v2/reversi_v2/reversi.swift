import Foundation

class ComputerPlayer {
  var difficulty: Int = 0
  var playerNum: Int = 1
  var gameField = Array<Array<Int>>()

  func CheckSquare(_ x: Int, _ y: Int) -> Bool {
      return (x >= 0) && (x <= 7) && (y >= 0) && (y < 7)  
  }

  func ScoreDirection(_ squarePoint: (x: Int, y: Int), _ vector: (x: Int, y: Int)) -> Int {
    var score = 0
    var square = squarePoint
    let defendPlayer = playerNum == 1 ? 2 : 1
    square.x += vector.x
    square.y += vector.y
    while CheckSquare(square.x, square.y) && gameField[square.x][square.y] == defendPlayer {
      if (square.x == 0) || (square.x == 7) || (square.y == 0) || (square.y == 7) {
        score += 2
      } else {
        score += 1
      }
      square.x += vector.x
      square.y += vector.y
    }
    if CheckSquare(square.x, square.y) && gameField[square.x][square.y] == playerNum && score > 0 {
      return score
    }
    else {
      return 0
    }
  }  

  func GetBestTurn(gameFieldCopy: Array<Array<Int>>, availableTurns: Array<(x: Int, y:Int)>) -> (x: Int, y: Int) {
    gameField = gameFieldCopy
    var scores: Array<Int> = Array<Int>() 
    let vectors = [(x: -1, y: -1), (x: -1, y: 0), (x: -1, y: 1), (x: 0, y: 1), (x: 1, y: 1), (x: 1, y: 0), (x: 1, y: -1), (x: 0, y: -1)]
    for square in availableTurns {
      var currentScore = 0
      for vec in vectors {
        currentScore += ScoreDirection(square, vec)
      }
      scores.append(currentScore)
    }
    return availableTurns[scores.firstIndex(of: scores.max()!)!]
  }
}

class Reversi {

    var gameField = Array<Array<Int>>()

    init() {
        for _ in 0...7 {
            var columnArray = Array<Int>()
            for _ in 0...7 {
                columnArray.append(0)
            }
            gameField.append(columnArray)
        }
        gameField[3][3] = 1
        gameField[4][4] = 1
        gameField[3][4] = 2
        gameField[4][3] = 2
    }

    func CheckSquare(_ x: Int, _ y: Int) -> Bool {
        return (x >= 0) && (x <= 7) && (y >= 0) && (y < 7)  
    }

    func CheckDirection(squarePoint: (x: Int, y: Int), vector: (x: Int, y: Int), attackPlayer: Int) -> (x: Int, y: Int) {
        var square = squarePoint
        let defendPlayer = attackPlayer == 1 ? 2 : 1
        var chipsCount = 0
        while CheckSquare(square.x, square.y) && gameField[square.x][square.y] == defendPlayer  {
            square.x += vector.x
            square.y += vector.y
            chipsCount += 1
        }
        if CheckSquare(square.x, square.y) && gameField[square.x][square.y] == 0 && chipsCount > 0 {
            return square
        }
        else {
            return (x: -1, y: -1)
        }
    }  

    func GetAvailableSquaresFromOne(x: Int, y: Int) -> Array<(x: Int, y:Int)> {
        var squares = Array<(x: Int, y:Int)>()
        if gameField[x][y] == 0 {
            return squares
        }
        let attackPlayer = gameField[x][y]
        let vectors = [(x: -1, y: -1), (x: -1, y: 0), (x: -1, y: 1), (x: 0, y: 1), (x: 1, y: 1), (x: 1, y: 0), (x: 1, y: -1), (x: 0, y: -1)]
        for vec in vectors {
            var dirResult = CheckDirection(squarePoint: (x: x + vec.x, y: y + vec.y), vector: vec, attackPlayer: attackPlayer)
            if dirResult.x != -1 && dirResult.y != -1 {
                squares.append(dirResult)
            }
        }
        return squares
    }

    func GetAvailableTurns(_ player: Int) -> Array<(x: Int, y:Int)> {
        var squares = Array<(x: Int, y:Int)>()
        for i in 0...7 {
            for j in 0...7 {
                if gameField[i][j] == player {
                    for square in GetAvailableSquaresFromOne(x: i, y: j) {
                        squares.append(square)
                    }
                }
            }
        }
        return squares
    }

    func EatDirection(initPoint: (x: Int, y: Int), vector: (x: Int, y: Int), attackPlayer: Int) {
        var square = initPoint
        square.x += vector.x
        square.y += vector.y
        let defendPlayer = attackPlayer == 1 ? 2 : 1
        var chipsCount = 0
        while CheckSquare(square.x, square.y) && gameField[square.x][square.y] == defendPlayer  {
            square.x += vector.x
            square.y += vector.y
            chipsCount += 1
        }
        if CheckSquare(square.x, square.y) && gameField[square.x][square.y] == attackPlayer && chipsCount > 0 {
            square = initPoint
            gameField[square.x][square.y] = attackPlayer
            square.x += vector.x
            square.y += vector.y
            print(square)
            while gameField[square.x][square.y] != attackPlayer {
                gameField[square.x][square.y] = attackPlayer
                square.x += vector.x
                square.y += vector.y
                print(square)
            }
        }
    }   

    func PlayerTurn(square: (x: Int, y: Int), player: Int) {
        let vectors = [(x: -1, y: -1), (x: -1, y: 0), (x: -1, y: 1), (x: 0, y: 1), (x: 1, y: 1), (x: 1, y: 0), (x: 1, y: -1), (x: 0, y: -1)]
        for vec in vectors {
            EatDirection(initPoint: square, vector: vec, attackPlayer: player)
        }
        for i in rev.gameField {
          print(i)
        }
    }
}

var rev : Reversi = Reversi()
var comp: ComputerPlayer = ComputerPlayer()

rev.PlayerTurn(square: comp.GetBestTurn(gameFieldCopy: rev.gameField, availableTurns: rev.GetAvailableTurns(1)), player: 1)
rev.PlayerTurn(square: (x: 4, y: 5), player: 2)
rev.PlayerTurn(square: comp.GetBestTurn(gameFieldCopy: rev.gameField, availableTurns: rev.GetAvailableTurns(1)), player: 1)
