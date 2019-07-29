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
    
    private enum StartGameViewAcpectRatio {
        case threeToOne
        case threeToTwo
        case twoToOne
    }
    
    private let game = Game()
    private var cellsGrid: CellsGrid!
    private lazy var cellsManager = CellsManager(with: cellsGrid.cells, game: game)
    private var feedbackView = FeedbackView()
    private var feedbackGenerator = FeedbackGenerator()
    private var firstTime = true
    private var startGameView: StartGameView!
    private let rowSize = 5
    private var lastPressedCell: CellView?
    private var gameFinishingReason: GameFinishingReason!
    private var numbersFound = 0
    private var swipeUpGestureRecognizer: UISwipeGestureRecognizer!
    private var swipeDownGestureRecognizer: UISwipeGestureRecognizer!
    
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
        
        game.delegate = self
        cellsManager.delegate = self
        cellsGrid.delegate = cellsManager
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstTime {
            cellsGrid.layoutIfNeeded()
            updateStartGameViewFrame()
            firstTime = false
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.cellsGrid.setOrientation(to: orientation)
            self.cellsGrid.layoutIfNeeded()
            self.updateStartGameViewFrame()
        })
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    // MARK: - Actions
    
    @objc private func startGame() {
        game.startGame()
        startGameView.hide()
        cellsManager.showNumbers(animated: true)
        if game.level.winkMode { cellsManager.startWinking() }
        if game.level.swapMode { cellsManager.startSwapping() }
        freezeUI(for: 0.2)
        swipeUpGestureRecognizer.isEnabled = false
        swipeDownGestureRecognizer.isEnabled = true
    }
    
    @objc func swipeUp() {
        performSegue(withIdentifier: "ShowSettings", sender: nil)
        lastPressedCell?.uncompress()
        prepareForNewGame()
    }
    
    @objc func swipeDown() {
        prepareForNewGame()
        lastPressedCell?.uncompress(hiddenNumber: true)
    }
    
    // MARK: - Helper Methods
    
    private func setupUI() {
        setupFeedbackView()
        setupCellsGrid()
        cellsGrid.setOrientation(to: orientation)
        setupStartGameView()
        setupGestureRecognizers()
    }
    
    private func prepareForNewGame() {
        game.newGame()
        
        if game.level.winkMode {
            cellsManager.stopWinking()
        }
        
        if game.level.swapMode {
            cellsManager.stopSwapping()
        }
        
        cellsManager.hideNumbers(animated: false)
        cellsManager.updateNumbers(with: game.numbers, animated: false)
        
        swipeUpGestureRecognizer.isEnabled = true
        swipeDownGestureRecognizer.isEnabled = false
        
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
        
        let margins = view.layoutMarginsGuide
        cellsGrid.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        cellsGrid.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        cellsGrid.topConstraint = cellsGrid.topAnchor.constraint(greaterThanOrEqualTo: margins.topAnchor, constant: 2.0)
        cellsGrid.leftConstraint = cellsGrid.leftAnchor.constraint(greaterThanOrEqualTo: margins.leftAnchor)
        #warning("Insets!")
        
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
        let style: StartGameView.Style = .light
        
        startGameView = StartGameView(interval: 5.0, style: style)
        
        self.view.addSubview(startGameView)
        
        startGameView.layer.cornerRadius = 7.0
        startGameView.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(startGame))
        view.addGestureRecognizer(tap) // TODO: Check if it works with swipe up
    }
    
    private func startGameViewRect(aspectRatio: StartGameViewAcpectRatio) -> CGRect {
        let origin: CGPoint
        let size: CGSize
        
        switch aspectRatio {
        case .threeToOne:
            if orientation == .portrait {
                origin = CGPoint(x: 2, y: cellsGrid.cells.count / 5 / 2 + 1)
            } else {
                origin = CGPoint(x: cellsGrid.cells.count / 5 / 2, y: 3)
            }
            size = CGSize(width: 3, height: 1)
        case .threeToTwo:
            if orientation == .portrait {
                origin = CGPoint(x: 2, y: cellsGrid.cells.count / 5 / 2)
            } else {
                origin = CGPoint(x: cellsGrid.cells.count / 5 / 2, y: 2)
            }
            size = CGSize(width: 3, height: 2)
        case .twoToOne:
            if orientation == .portrait {
                origin = CGPoint(x: 2, y: cellsGrid.cells.count / 5 / 2 + 1)
            } else {
                origin = CGPoint(x: cellsGrid.cells.count / 5 / 2, y: 3)
            }
            size = CGSize(width: 2, height: 1)
        }
        
        guard let centralCells = cellsGrid.getCells(origin: origin, size: size) else {
            return .zero
        }
                
        var rect: CGRect = .zero
        
        for cell in centralCells {
            let cellFrame = self.view.convert(cell.bounds, from: cell)
            if rect == .zero {
                rect = cellFrame
            } else {
                rect = rect.union(cellFrame)
            }
        }
        
        #warning("Insets!")
        return rect.inset(by: UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0))
    }
    
    private func setupGestureRecognizers() {
        swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp))
        swipeUpGestureRecognizer.direction = .up
        swipeUpGestureRecognizer.cancelsTouchesInView = false
        
        swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        swipeDownGestureRecognizer.direction = .down
        swipeDownGestureRecognizer.cancelsTouchesInView = false
        swipeDownGestureRecognizer.isEnabled = false
        
        self.view.addGestureRecognizer(swipeUpGestureRecognizer)
        self.view.addGestureRecognizer(swipeDownGestureRecognizer)
    }
    
    private func updateStartGameViewFrame() {
        let aspectRatio: StartGameViewAcpectRatio
        
        switch (orientation, cellsGrid.cells.count.isMultiple(of: 10)) {
        case (.portrait, true):
            aspectRatio = .threeToTwo
        case (.portrait, false), (.landscape, false):
            aspectRatio = .threeToOne
        case (.landscape, true):
            aspectRatio = .twoToOne
        }
       
        startGameView.frame = startGameViewRect(aspectRatio: aspectRatio)
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
        lastPressedCell = cell
        feedbackGenerator.playSelectionHapticFeedback()
        freezeUI(for: 0.17)
    }
    
    internal func cellReleased(_ cell: CellView) {
        if !game.isRunning { return }
        
        game.numberSelected(cell.number)

        if game.selectedNumberIsRight {
            cell.setNumber(cell.number + game.numbers.count, animated: false)
            feedbackGenerator.playSelectionHapticFeedback()
        } else {
            feedbackView.playErrorFeedback()
            feedbackGenerator.playVibrationFeedback()
        }
        
        if game.level.shuffleMode {
            game.shuffleNumbers()
            cellsManager.updateNumbers(with: game.numbers, animated: true)
        }
    }
}

// MARK: - GameDelegate

extension GameViewController: GameDelegate {
    
    internal func gameFinished(reason: GameFinishingReason, numbersFound: Int) {
        gameFinishingReason = reason
        self.numbersFound = numbersFound
        prepareForNewGame()
        performSegue(withIdentifier: "ShowResults", sender: nil)
    }
}

// MARK: - Navigation

extension GameViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSettings" {
            let navigationController = segue.destination as! UINavigationController
            let settingsViewContoller = navigationController.viewControllers.first! as! SettingsViewController
            settingsViewContoller.game = game
        } else if segue.identifier == "ShowResults" {
            let resultsViewController = segue.destination as! ResultsViewController
            resultsViewController.numbersFound = numbersFound
            resultsViewController.gameFinishingReason = gameFinishingReason
        }
    }
    
}

