//
//  GameViewController.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/2/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

enum Orientation {
    case portrait
    case landscape
}

var orientation: Orientation {
    return UIScreen.main.bounds.width < UIScreen.main.bounds.height ? .portrait : .landscape
}

class GameViewController: UIViewController {
    
    private var cells = [CellView]()
    
    private let game = Game()
    private var cellsGrid: CellsGrid!
    private lazy var cellsManager = CellsManager(with: cellsGrid.cells)
    private var feedbackView = FeedbackView()
    private var firstTime = true
    private var startGameView: StartGameView!
    private let rowSize = 5
    
    private var startGameViewEstimatedSize: CGSize {
        //        if cells.isEmpty { return .zero }
        //
        //        let cellHeight = cells.first!.frame.height
        //        let rows = cells.count / cellsGrid.rowsCount
        //        let height: CGFloat
        //        let width: CGFloat
        //
        //        switch (orientation, rows.isMultiple(of: 2)) {
        //        case (.portrait, true):
        //            height = cellHeight * 2 - cellInset * 2
        //            width = cellHeight * 3 - cellInset * 2
        //        case (.portrait, false), (.landscape, false):
        //            height = cellHeight - cellInset * 2
        //            width = cellHeight * 3 - cellInset * 2
        //        case (.landscape, true):
        //            height = cellHeight - cellInset * 2.5
        //            width = cellHeight * 2 - cellInset * 2.5
        //        }
        
        return .zero //CGSize(width: lroundf(Float(width)), height: lroundf(Float(height)))
    }
    
    private var cellStyle: CellView.Style {
        var style: CellView.Style
        
        switch (game.level.colorModeFor.cells, game.level.colorModeFor.numbers) {
        case (true, true):
            style = .colorfulWithColorfulNumber
        case (true, false):
            style = .colorfulWithWhiteNumber
        default:
            style = traitCollection.userInterfaceStyle == .light ? .defaultWithBlackNumber : .defaultWithWhiteNumber
        }
        
        return style
    }
    
    private var cellHeight: CGFloat {
        if orientation == .portrait {
            return (UIScreen.main.bounds.width - 2.0) / CGFloat(rowSize)
        } else {
            return (UIScreen.main.bounds.height - 2.0) / CGFloat(rowSize)
        }
        #warning("Replace cell inset (2.0)")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        prepareForNewGame()
        
        cellsManager.delegate = self
        cellsGrid.delegate = cellsManager
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstTime {
            cellsGrid.setOrientation(to: orientation)
            updateStartGameViewFrame()
            firstTime = false
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        cellsGrid.setOrientation(to: orientation)
        updateStartGameViewFrame()
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    // MARK: - Actions
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        print(cellsGrid.getCells(origin: CGPoint(x: 2, y: 3), width: 5, height: 2))
    }
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        game.newGame(numbers: cellsGrid.cells.count + rowSize)
        cellsGrid.addRows(count: 1, animated: true)
        cellsManager.setStyle(to: cellStyle, animated: false)
        cellsManager.setNumbers(game.numbers, animated: false)
    }
    
    @IBAction func minusButtonPressed(_ sender: UIButton) {
        game.newGame(numbers: cellsGrid.cells.count - rowSize)
        cellsGrid.removeRows(count: 1, animated: true)
        cellsManager.setNumbers(game.numbers, animated: false)
    }
    
    @objc private func startGame() {
        game.startGame()
        startGameView.hide()
        cells.forEach { $0.showNumber(animated: true) }
        if game.level.winkMode { cellsManager.startWinking() }
        if game.level.swapMode { cellsManager.startSwapping() }
        freezeUI(for: 0.2)
    }
    
    @objc func swipeUp() {
        showSettings()
    }
    
    @objc func swipeDown() {
        prepareForNewGame()
    }
    
    @objc func swipeRight() {
        print("Swipe Right")
    }
    
    @objc func swipeLeft() {
        print("Swipe Left")
    }
    
    // MARK: - Helper Methods
    
    private func setupUI() {
        setupFeedbackView()
        setupCellsGrid()
        setupStartGameView()
        setupGestureRecognizers()
    }
    
    private func prepareForNewGame() {
        game.newGame(numbers: cells.count)
        
        if game.level.winkMode {
            cellsManager.stopWinking()
        }
        
        if game.level.swapMode {
            cellsManager.stopSwapping()
        }
        
        cellsManager.updateNumbers(with: game.numbers, animated: false)
        
        for cell in cells {
            #warning("Fix animation on Swap Mode")
            if game.level.winkMode || game.level.swapMode { cell.stopAnimations() }
            cell.hideNumber(animated: false)
        }
        
        startGameView.show()
    }
    
    private func freezeUI(for freezeTime: Double) {
        self.view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + freezeTime) {
            self.view.isUserInteractionEnabled = true
        }
    }
    
}

// MARK: - UI Managment

extension GameViewController {
    
    private func setupCellsGrid() {
        cellsGrid = CellsGrid(rowSize: 5, rowHeight: cellHeight)
        self.view.addSubview(cellsGrid)
        cellsGrid.translatesAutoresizingMaskIntoConstraints = false
        cellsGrid.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        cellsGrid.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        cellsGrid.addRows(count: game.numbers.count / rowSize, animated: false)
        cellsManager.setStyle(to: cellStyle, animated: false)
    }
    
    private func setupFeedbackView() {
        self.view.addSubview(feedbackView)
        feedbackView.translatesAutoresizingMaskIntoConstraints = false
        feedbackView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        feedbackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        feedbackView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        feedbackView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
    
    private func setupStartGameView() {
        let style: StartGameView.Style
        if game.level.colorModeFor.cells {
            style = .lightWithWhiteText
        } else {
            style = .lightWithBlackText
        }
        
        startGameView = StartGameView(goal: 166.2, style: style)
        
        self.view.addSubview(startGameView)
        
        startGameView.layer.cornerRadius = 7.0
        startGameView.clipsToBounds = true
        startGameView.translatesAutoresizingMaskIntoConstraints = false
        startGameView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        startGameView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        startGameView.heightConstraint = startGameView.heightAnchor.constraint(equalToConstant: startGameViewEstimatedSize.height)
        startGameView.widthConstraint = startGameView.widthAnchor.constraint(equalToConstant: startGameViewEstimatedSize.width)
        
        startGameView.heightConstraint?.isActive = true
        startGameView.widthConstraint?.isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(startGame))
        view.addGestureRecognizer(tap) // TODO: Check if it works with swipe up
    }
    
    private func setupGestureRecognizers() {
        let up = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp))
        up.direction = .up
        
        let down = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        down.direction = .down
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        right.direction = .right
        
        let left = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        left.direction = .left
        
        self.view.addGestureRecognizer(up)
        self.view.addGestureRecognizer(down)
        self.view.addGestureRecognizer(right)
        self.view.addGestureRecognizer(left)
    }
    
    private func updateStartGameViewFrame() {
        startGameView.widthConstraint?.constant = startGameViewEstimatedSize.width
        startGameView.heightConstraint?.constant = startGameViewEstimatedSize.height
    }
}

// MARK: - CellsManagerDelegate

extension GameViewController: CellsManagerDelegate {
    
    internal func cellPressed(_ cell: CellView) {
        if cell.number == game.numbers.max() {
            game.finishGame()
            prepareForNewGame()
            return
        }
        freezeUI(for: 0.17)
    }
    
    internal func cellReleased(_ cell: CellView) {
        if !game.isRunning { return }
        
        if cell.number != game.nextNumber {
            feedbackView.playErrorFeedback()
        }
        
        game.numberSelected(cell.number)
        
        if game.level.shuffleMode {
            game.shuffleNumbers()
            cellsManager.updateNumbers(with: game.numbers, animated: true)
        }
    }
}

// MARK: - Navigation

extension GameViewController {
    
    private func showSettings() {
        performSegue(withIdentifier: "ShowSettings", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSettings" {
            let navigationController = segue.destination as! UINavigationController
            let settingsViewContoller = navigationController.viewControllers.first! as! SettingsViewController
            settingsViewContoller.game = game
        }
    }
    
}

