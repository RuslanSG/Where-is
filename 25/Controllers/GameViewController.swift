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
    
    private var cells = [CellView]()
    
    private let game = Game()
    private var cellsGrid: CellsGrid!
    private lazy var cellsManager = CellsManager(with: cellsGrid.cells)
    private var feedbackView = FeedbackView()
    private var firstTime = true
    private var startGameView: StartGameView!
    private let rowSize = 5
    
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
            cellsGrid.layoutIfNeeded()
            updateStartGameViewFrame(animated: false)
            firstTime = false
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.cellsGrid.setOrientation(to: orientation)
            self.cellsGrid.layoutIfNeeded()
            self.updateStartGameViewFrame(animated: false)
        })
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    // MARK: - Actions
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        game.newGame(numbers: cellsGrid.cells.count + rowSize)
        cellsGrid.addRows(count: 1, animated: true)
        cellsManager.setStyle(to: cellStyle, animated: false)
        cellsManager.setNumbers(game.numbers, animated: false)
        updateStartGameViewFrame(animated: true)
    }
    
    @IBAction func minusButtonPressed(_ sender: UIButton) {
        game.newGame(numbers: cellsGrid.cells.count - rowSize)
        cellsGrid.removeRows(count: 1, animated: true)
        cellsManager.setNumbers(game.numbers, animated: false)
        updateStartGameViewFrame(animated: true)
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
        cellsGrid.setOrientation(to: orientation)
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
        
        print(centralCells)
        
        var rect: CGRect = .zero
        
        for cell in centralCells {
            let cellFrame = self.view.convert(cell.bounds, from: cell)
            if rect == .zero {
                rect = cellFrame
            } else {
                rect = rect.union(cellFrame)
            }
        }
        
        return rect.inset(by: UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0))
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
    
    private func updateStartGameViewFrame(animated: Bool) {
        let aspectRatio: StartGameViewAcpectRatio
        
        switch (orientation, cellsGrid.cells.count.isMultiple(of: 10)) {
        case (.portrait, true):
            aspectRatio = .threeToTwo
        case (.portrait, false), (.landscape, false):
            aspectRatio = .threeToOne
        case (.landscape, true):
            aspectRatio = .twoToOne
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.startGameView.frame = self.startGameViewRect(aspectRatio: aspectRatio)
            }
        } else {
            startGameView.frame = startGameViewRect(aspectRatio: aspectRatio)
        }
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

