//
//  Reversi.swift
//  Reversi_v1
//

import Foundation

// Computer game class
class ComputerPlayer : ReversiLogic {
    let BORDER_SQUARE_WEIGHT = 0.4
    let ANGLE_SQUARE_WEIGHT = 0.8
    
    
    var hardMode: Bool
    var computerNum: Int = 1
    
    init(isHardMode: Bool = false, computerNumber: Int = 1) {
        hardMode = isHardMode
        computerNum = computerNumber
        
        super.init()
    }

    func ScoreDirection(_ squarePoint: (x: Int, y: Int), _ vector: (x: Int, y: Int), player: Int) -> Double {
        var score: Double = 0
        var square = squarePoint
        let defendPlayer = player == 1 ? 2 : 1
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
        if CheckSquare(square.x, square.y) && gameField[square.x][square.y] == computerNum && score > 0 {
            return score
        }
        else {
            return 0
        }
    }
    
    func ComputerTurn(gameFieldCopy: Array<Array<Int>>) -> (x: Int, y: Int) {
        gameField = gameFieldCopy
        if hardMode {
            return GetBestTurnHard()
        }
        else {
            return GetBestTurn(player: computerNum).point
        }
    }
    

    func GetBestTurn(player: Int) -> (point: (x: Int, y: Int), score: Double) {
        let availableTurns = GetAvailableTurns(player)
        var scores: Array<Double> = Array<Double>()
        for square in availableTurns {
            var currentScore: Double = 0
            for vec in DIRECTION_VECTORS {
                currentScore += ScoreDirection(square, vec, player: player)
            }
            if ((square.x == 0) || (square.x == 7)) && ((square.y == 0) || (square.y == 7)) {
                currentScore += ANGLE_SQUARE_WEIGHT
            }
            else if (square.x == 0) || (square.x == 7) || (square.y == 0) || (square.y == 7) {
                currentScore += BORDER_SQUARE_WEIGHT
            }
            scores.append(currentScore)
        }
        if scores.count > 0 {
            return (point: (x: availableTurns[scores.firstIndex(of: scores.max()!)!].x, y: availableTurns[scores.firstIndex(of: scores.max()!)!].y), score: scores.max()!)
        }
        return (point: (x: -1, y: -1), score: -1)
    }
    
    func GetBestTurnHard() -> (x: Int, y: Int) {
        let gameFieldCopy = gameField
        let availableTurns = GetAvailableTurns(computerNum)
        var scores: Array<Double> = Array<Double>()
        let enemyPlayer = computerNum == 1 ? 2 : 1
        for square in availableTurns {
            var currentScore: Double = 0
            gameField = gameFieldCopy
            for vec in DIRECTION_VECTORS {
                currentScore += ScoreDirection(square, vec, player: computerNum)
            }
            if ((square.x == 0) || (square.x == 7)) && ((square.y == 0) || (square.y == 7)) {
                currentScore += ANGLE_SQUARE_WEIGHT
            }
            else if (square.x == 0) || (square.x == 7) || (square.y == 0) || (square.y == 7) {
                currentScore += BORDER_SQUARE_WEIGHT
            }
            PlayerTurn(square: square, player: computerNum)
            currentScore -= GetBestTurn(player: enemyPlayer).score
            scores.append(currentScore)
        }
        if scores.count > 0 {
            return availableTurns[scores.firstIndex(of: scores.max()!)!]
        }
        return (x: -1, y: -1)
    }
}

class ReversiLogic {
    var DIRECTION_VECTORS = [(x: -1, y: -1), (x: -1, y: 0), (x: -1, y: 1), (x: 0, y: 1), (x: 1, y: 1), (x: 1, y: 0), (x: 1, y: -1), (x: 0, y: -1)]
    
    var gameField = Array<Array<Int>>()

    init() {
        CleanField()
    }
    
    func CleanField() {
        gameField = Array<Array<Int>>()
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
        return (x >= 0) && (x <= 7) && (y >= 0) && (y <= 7)
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
        for vec in DIRECTION_VECTORS {
            let dirResult = CheckDirection(squarePoint: (x: x + vec.x, y: y + vec.y), vector: vec, attackPlayer: attackPlayer)
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

    func EatDirection(initPoint: (x: Int, y: Int), vector: (x: Int, y: Int), attackPlayer: Int) -> Array<(x: Int, y:Int)> {
        var returnList : Array<(x: Int, y: Int)> = Array<(x: Int, y: Int)>()
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
            while gameField[square.x][square.y] != attackPlayer {
                gameField[square.x][square.y] = attackPlayer
                returnList.append(square)
                square.x += vector.x
                square.y += vector.y
            }
        }
        return returnList
    }
    
    func PlayerTurn(square: (x: Int, y: Int), player: Int) -> Array<(x: Int, y:Int)> {
        var returnList : Array<(x: Int, y: Int)> = Array<(x: Int, y: Int)>()
        returnList.append(square)
        for vec in DIRECTION_VECTORS {
            for square in EatDirection(initPoint: square, vector: vec, attackPlayer: player) {
                returnList.append(square)
            }
        }
        return returnList
    }
}

class ReversiGame : ReversiLogic {
    let computer: ComputerPlayer
    let againstComputer: Bool
    
    var isComputerTurn: Bool
    var playerTurn: Int = 1
    
    init(hardMode: Bool = false, gameAgainsComputer: Bool = true) {
        againstComputer = gameAgainsComputer
        computer = ComputerPlayer(isHardMode: hardMode, computerNumber: 2)
        isComputerTurn = computer.computerNum == 1
        playerTurn = 1
        super.init()
    }
    
    func PlayerScore(_ player: Int) -> Int {
        var score = 0
        for i in 0...7 {
            for j in 0...7 {
                if gameField[i][j] == player {
                    score += 1
                }
            }
        }
        return score
    }
    
    func ComputerTurn(hardMode: Bool = false) -> Array<(x: Int, y:Int)> {
        if GetAvailableTurns(computer.computerNum).count > 0 {
            return PlayerTurn(square: computer.ComputerTurn(gameFieldCopy: gameField), player: computer.computerNum)
        }
        return Array<(x: Int, y:Int)>()
    }
    
    func PlayerTurn(square: (x: Int, y: Int)) -> Array<(x: Int, y: Int)> {
        if (square.x >= 0) && (square.x <= 7) && (square.y >= 0) && (square.y <= 7) {
            if (gameField[square.x][square.y] == 0) {
                return super.PlayerTurn(square: square, player: playerTurn)
            }
        }
        return Array<(x: Int, y: Int)>()
    }
    
    func CulculateTurn() {
        if GetAvailableTurns(playerTurn % 2 + 1).count > 0 {
            playerTurn = playerTurn % 2 + 1
            if againstComputer {
                isComputerTurn = !isComputerTurn
            }
        }
    }
}
