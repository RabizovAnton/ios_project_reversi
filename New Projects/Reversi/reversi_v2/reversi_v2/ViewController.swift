//
//  ViewController.swift
//  Reversi_v1
//
//  Created by Stepan Bryantsev on 15.03.2020.
//  Copyright © 2020 Stepan Bryantsev. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var game: ReversiGame = ReversiGame()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StartPajeInit()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var whiteScore: NSTextField!
    @IBOutlet weak var blackScore: NSTextField!
    @IBOutlet weak var whiteImage: NSImageView!
    @IBOutlet weak var blackImage: NSImageView!
    @IBOutlet weak var turnLabel: NSTextField!
    @IBOutlet weak var reversiLabel: NSTextField!
    
    @IBOutlet weak var easyGameBtn: NSButton!
    @IBOutlet weak var hardGameBtn: NSButton!
    @IBOutlet weak var twoPlayersBtn: NSButton!
    @IBOutlet weak var restartBtn: NSButton!
    @IBOutlet weak var mainMenuBtn: NSButton!
    
    @IBOutlet weak var gridView: NSGridView!
    
    override var representedObject: Any? {
        didSet {
            
        }
    }
    
    func StartPajeInit() {
        mainMenuBtn.isHidden = true
        restartBtn.isHidden = true
        reversiLabel.isHidden = false
        turnLabel.isHidden = true
        
        gridView.isHidden = true
        
        easyGameBtn.isHidden = false
        hardGameBtn.isHidden = false
        twoPlayersBtn.isHidden = false
        
        whiteScore.isHidden = true
        blackScore.isHidden = true
        whiteImage.isHidden = true
        blackImage.isHidden = true
        
        gridView.layer?.borderColor = NSColor.gray.cgColor
        gridView.layer?.borderWidth = 2
        gridView.layer?.masksToBounds = true
        
        for i in 1...7 {
            gridView.addSubview(NSBox(frame: NSRect(x: 58 * i - 4, y: 0, width: 2, height: 522)))
        }
        
        for i in 1...7 {
            gridView.addSubview(NSBox(frame: NSRect(x: 0, y: 58 * i - 6, width: 522, height: 2)))
        }
    }
    
    func InitGame() {
        easyGameBtn.isHidden = true
        hardGameBtn.isHidden = true
        twoPlayersBtn.isHidden = true
        restartBtn.isHidden = false
        mainMenuBtn.isHidden = false
        reversiLabel.isHidden = true
        turnLabel.isHidden = false
        DisplayPlayerTurnLabel()
        
        gridView.wantsLayer = true
        gridView.layer?.borderColor = NSColor.gray.cgColor
        gridView.layer?.borderWidth = 2
        gridView.layer?.masksToBounds = true
        gridView.isHidden = false
        
        
        whiteScore.isHidden = false
        blackScore.isHidden = false
        whiteImage.isHidden = false
        blackImage.isHidden = false
        whiteScore.cell?.title = "2"
        blackScore.cell?.title = "2"
        
        
    }
    @IBAction func EasyGameWithComputer(_ sender: Any) {
        game = ReversiGame(hardMode: false, gameAgainsComputer: true)
        InitGame()
        DisplayAllChips()
        Turn()
    }
    
    @IBAction func HardGameWithComputer(_ sender: Any) {
        game = ReversiGame(hardMode: true, gameAgainsComputer: true)
        InitGame()
        DisplayAllChips()
        Turn()
    }
    
    @IBAction func TwoPlayersGame(_ sender: Any) {
        game = ReversiGame(hardMode: false, gameAgainsComputer: false)
        InitGame()
        DisplayAllChips()
        Turn()
    }
    
    @IBAction func RestartGame(_ sender: Any) {
        if !game.isComputerTurn {
            game.CleanField()
            game.playerTurn = 1
            game.isComputerTurn = false
            DisplayAllChips()
            SetScore()
            Turn()
        }
    }
    @IBAction func ExitMainMenu(_ sender: Any) {
        StartPajeInit()
        turnLabel.cell?.title = "Reversi"
    }
    
    func DisplayAnimationTurn(playerNum: Int, squares: Array<(x: Int, y: Int)>) {
        var delay: Double = 0.0
        for square in squares {
            let chip = NSImageView()
            if playerNum == 1 {
                chip.image = NSImage(named: "white")
            }
            else if playerNum == 2 {
                chip.image = NSImage(named: "black")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.gridView.cell(atColumnIndex: square.x, rowIndex: square.y).contentView?.removeFromSuperview()
                self.gridView.cell(atColumnIndex: square.x, rowIndex: square.y).contentView = chip
            }
            delay += 0.3
        }
        SetScore()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.6) {
            self.game.CulculateTurn()
            self.DisplayPlayerTurnLabel()
            self.Turn()
        }
    }
    
    func Turn() {
        if game.GetAvailableTurns(1).count > 0 || game.GetAvailableTurns(2).count > 0 {
            if game.isComputerTurn {
                DisplayAllChips()
                DisplayAnimationTurn(playerNum: game.computer.computerNum, squares: game.ComputerTurn())
            }
            else {
                DisplayPlayerAvailableTurns()
            }
        }
        else {
            turnLabel.cell?.title =  game.PlayerScore(1) > game.PlayerScore(2) ? "White wins" : game.PlayerScore(1) < game.PlayerScore(2) ? "Black wins" : "Draw"
            game.isComputerTurn = false
            
        }
    }
    
    func SetScore() {
        whiteScore.cell?.title = String(game.PlayerScore(1))
        blackScore.cell?.title = String(game.PlayerScore(2))
    }
    
    @objc @IBAction func PlayerChoose(_ sender: NSButton) {
        DisplayAllChips()
        let cell: NSGridCell = sender.accessibilityParent()! as! NSGridCell
        let x: Int = gridView.index(of: cell.row!)
        let y: Int = gridView.index(of: cell.column!)
        DisplayAnimationTurn(playerNum: game.playerTurn, squares: game.PlayerTurn(square: (x: y, y: x)))
    }
    
    func DisplayAllChips() {
        for i in 0...7 {
            for j in 0...7 {
                if game.gameField[i][j] == 1 {
                    let chip = NSImageView(image: NSImage(named: "white")!)
                    gridView.cell(atColumnIndex: i, rowIndex: j).contentView?.removeFromSuperview()
                    gridView.cell(atColumnIndex: i, rowIndex: j).contentView = chip
                }
                else if game.gameField[i][j] == 2 {
                    let chip = NSImageView(image: NSImage(named: "black")!)
                    gridView.cell(atColumnIndex: i, rowIndex: j).contentView?.removeFromSuperview()
                    gridView.cell(atColumnIndex: i, rowIndex: j).contentView = chip
                }
                else if game.gameField[i][j] == 0 {
                    gridView.cell(atColumnIndex: i, rowIndex: j).contentView?.removeFromSuperview()
                }
            }
        }
    }
    
    func DisplayPlayerAvailableTurns() {
        for availableSquare in game.GetAvailableTurns(game.playerTurn) {
            let btn: NSButton = NSButton()
            btn.setAccessibilityParent(gridView.cell(atColumnIndex: availableSquare.x, rowIndex: availableSquare.y))
            let image = NSImage(named: "green")
            image?.size = NSSize(width: 54, height: 54)
            btn.image = image
            btn.wantsLayer = true
            btn.layer?.backgroundColor = CGColor(gray: 1, alpha: 0.0001)
            btn.target = self
            btn.action = #selector(self.PlayerChoose)
            gridView.cell(atColumnIndex: availableSquare.x, rowIndex: availableSquare.y).contentView?.removeFromSuperview()
            gridView.cell(atColumnIndex: availableSquare.x, rowIndex: availableSquare.y).contentView = btn
        }
    }
    
    func DisplayPlayerTurnLabel() {
        turnLabel.cell?.title = game.playerTurn == 1 ? "White turn" : "Black turn"
    }
}

