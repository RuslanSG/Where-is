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
        case threeToOne, threeToTwo, twoToOne
    }
    
    private enum SettingsButtonAspectRatio {
        case oneToOne, oneToTwo
    }
    
    private var cellsGrid: CellsGrid!
    private var lastPressedCell: CellView?
    private var cellsUnderSettingsButton = [CellView]()
    private var startGameButton: StartGameView!
    private var settingsButton: UIButton!
    private var swipeDownGestureRecognizer: UISwipeGestureRecognizer!
    
    private let game = Game()
    private lazy var cellsManager = CellsManager(with: cellsGrid.cells, game: game)
    private var feedbackView = FeedbackView()
    private var feedbackGenerator = FeedbackGenerator()
    private var gameFinishingReason: GameFinishingReason!
    
    private let rowSize = 5
    private var numbersFound = 0
    
    private var firstTime = true
    
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstTime {
            cellsGrid.layoutIfNeeded()
            updateStartGameViewFrame()
            updateSettingsButtonFrameAndBackgroundColor()
            firstTime = false
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.cellsGrid.setOrientation(to: orientation)
            self.cellsGrid.layoutIfNeeded()
            self.updateStartGameViewFrame()
            self.updateSettingsButtonFrameAndBackgroundColor()
        })
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    // MARK: - Actions
    
    @objc private func startGame() {
        game.startGame()
        startGameButton.hide()
        cellsManager.showNumbers(animated: true)
        cellsManager.enableCells()
        if game.level.winkMode { cellsManager.startWinking() }
        if game.level.swapMode { cellsManager.startSwapping() }
        freezeUI(for: 0.2)
        swipeDownGestureRecognizer.isEnabled = true
        feedbackGenerator.playSelectionHapticFeedback()
        
        UIView.animate(withDuration: 0.2) {
            self.settingsButton.isHidden = true
        }
    }
    
    @objc func swipeDown() {
        prepareForNewGame()
    }
    
    @objc func settingsButtonPressed() {
        UIView.animate(withDuration: 0.05) {
            self.settingsButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
        cellsUnderSettingsButton.forEach { $0.compress() }
        feedbackGenerator.playSelectionHapticFeedback()
    }

    @objc func settingsButtonReleased() {
        performSegue(withIdentifier: "ShowSettings", sender: nil)
        prepareForNewGame()
        UIView.animate(withDuration: 0.2) {
            self.settingsButton.transform = CGAffineTransform.identity
        }
        cellsUnderSettingsButton.forEach { $0.uncompress(hideNumber: true) }
        feedbackGenerator.playSelectionHapticFeedback()
    }
    
    // MARK: - Helper Methods
    
    private func setupUI() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        }
        setupFeedbackView()
        setupCellsGrid()
        cellsGrid.setOrientation(to: orientation)
        setupStartGameButton()
        setupSettingsButton()
        setupGestureRecognizers()
    }
    
    private func prepareForNewGame() {
        game.newGame()
        
        cellsManager.stopWinking()
        cellsManager.stopSwapping()
        cellsManager.disableCells()
        cellsManager.hideNumbers(animated: false)
        cellsManager.updateNumbers(with: game.numbers, animated: false)
        
        swipeDownGestureRecognizer.isEnabled = false
        
        startGameButton.show()
        
        UIView.animate(withDuration: 0.2) {
            self.settingsButton.isHidden = false
        }
        
        lastPressedCell?.uncompress(hideNumber: true)
    }
    
    private func freezeUI(for freezeTime: Double) {
        self.view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + freezeTime) {
            self.view.isUserInteractionEnabled = true
        }
    }
    
    private func getRectUnion(of cells: [CellView]) -> CGRect {
        var rect: CGRect = .zero
        
        for cell in cells {
            let cellFrame = self.view.convert(cell.bounds, from: cell)
            if rect == .zero {
                rect = cellFrame
            } else {
                rect = rect.union(cellFrame)
            }
        }
        
        return rect
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
        cellsManager.setStyle(to: cellStyle, palette: .cold, animated: false)
    }
    
    private func setupFeedbackView() {
        self.view.addSubview(feedbackView)
        feedbackView.translatesAutoresizingMaskIntoConstraints = false
        feedbackView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        feedbackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        feedbackView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        feedbackView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
    
    private func setupStartGameButton() {
        let style: StartGameView.Style = .light
        
        startGameButton = StartGameView(interval: 5.0, style: style)
        
        self.view.addSubview(startGameButton)
        
        startGameButton.layer.cornerRadius = 7.0
        startGameButton.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(startGame))
        startGameButton.addGestureRecognizer(tap)
    }
    
    private func setupSettingsButton() {
        let gearImage = UIImage(named: "gear")?.withRenderingMode(.alwaysTemplate)
        
        settingsButton = UIButton()
        settingsButton.setImage(gearImage, for: .normal)
        settingsButton.tintColor = .white
        settingsButton.imageView?.contentMode = .scaleAspectFit
        settingsButton.imageEdgeInsets = UIEdgeInsets(top: 17.0, left: 17.0, bottom: 17.0, right: 17.0)
        settingsButton.backgroundColor = cellsUnderSettingsButton.first?.backgroundColor
        settingsButton.layer.cornerRadius = 7.0
        #warning("Corner Radius!")
        settingsButton.addTarget(self, action: #selector(settingsButtonPressed), for: .touchDown)
        settingsButton.addTarget(self, action: #selector(settingsButtonReleased), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsButtonReleased), for: .touchUpOutside)
        
        view.addSubview(settingsButton)
    }
    
    private func startGameViewRect(aspectRatio: StartGameViewAcpectRatio) -> CGRect {
        let origin: CGPoint
        let size: CGSize
        
        switch aspectRatio {
        case .threeToOne:
            if orientation == .portrait {
                origin = CGPoint(x: 2,
                                 y: Int(ceilf(Float(cellsGrid.cells.count) / Float(rowSize) / 2)))
            } else {
                origin = CGPoint(x: cellsGrid.cells.count / rowSize / 2,
                                 y: 3)
            }
            size = CGSize(width: 3, height: 1)
        case .threeToTwo:
            if orientation == .portrait {
                origin = CGPoint(x: 2,
                                 y: cellsGrid.cells.count / rowSize / 2)
            } else {
                origin = CGPoint(x: cellsGrid.cells.count / rowSize / 2,
                                 y: 2)
            }
            size = CGSize(width: 3, height: 2)
        case .twoToOne:
            if orientation == .portrait {
                origin = CGPoint(x: 2,
                                 y: Int(ceilf(Float(cellsGrid.cells.count) / Float(rowSize) / 2)))
            } else {
                origin = CGPoint(x: cellsGrid.cells.count / rowSize / 2,
                                 y: 3)
            }
            size = CGSize(width: 2, height: 1)
        }
        
        guard let centralCells = cellsGrid.getCells(origin: origin, size: size) else {
            return .zero
        }
        
        #warning("Insets!")
        return getRectUnion(of: centralCells).inset(by: UIEdgeInsets(top: 2.0,
                                                                     left: 2.0,
                                                                     bottom: 2.0,
                                                                     right: 2.0))
    }
    
    private func settingsButtonRect(aspectRatio: SettingsButtonAspectRatio) -> CGRect {
        let origin: CGPoint
        let size: CGSize
        
        switch aspectRatio {
        case .oneToOne:
            if orientation == .portrait {
                origin = CGPoint(x: Int(ceilf(Float(rowSize) / 2)),
                                 y: cellsGrid.cells.count / rowSize)
            } else {
                origin = CGPoint(x: Int(ceilf(Float(cellsGrid.cells.count) / Float(rowSize) / 2)),
                                 y: rowSize)
            }
            size = CGSize(width: 1, height: 1)
        case .oneToTwo:
            origin = CGPoint(x: cellsGrid.cells.count / rowSize / 2,
                             y: rowSize)
            size = CGSize(width: 2, height: 1)
        }
        
        guard let targetCells = cellsGrid.getCells(origin: origin, size: size) else { return .zero }
        cellsUnderSettingsButton = targetCells
        
        return getRectUnion(of: targetCells).inset(by: UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0))
    }
    
    
    private func setupGestureRecognizers() {
        swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        swipeDownGestureRecognizer.direction = .down
        swipeDownGestureRecognizer.cancelsTouchesInView = false
        swipeDownGestureRecognizer.isEnabled = false
        
        self.view.addGestureRecognizer(swipeDownGestureRecognizer)
    }
    
    private func updateViewFromModel() {
        if cellsGrid.cells.count < game.level.numbers {
            let numberOfRowsToAdd = (game.level.numbers - cellsGrid.cells.count) / rowSize
            cellsGrid.addRows(count: numberOfRowsToAdd, animated: false)
            cellsGrid.layoutIfNeeded()
        } else if cellsGrid.cells.count > game.level.numbers {
            let numberOfRowsToRemove = (cellsGrid.cells.count - game.level.numbers) / rowSize
            cellsGrid.removeRows(count: numberOfRowsToRemove, animated: false)
            cellsGrid.layoutIfNeeded()
        }
        cellsManager.setStyle(to: cellStyle, palette: .hot, animated: false)
        cellsManager.setNumbers(game.numbers, animated: false)
        cellsManager.hideNumbers(animated: false)
        updateStartGameViewFrame()
        updateSettingsButtonFrameAndBackgroundColor()
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
       
        startGameButton.frame = startGameViewRect(aspectRatio: aspectRatio)
    }
    
    private func updateSettingsButtonFrameAndBackgroundColor() {
        let aspectRatio: SettingsButtonAspectRatio
        
        if orientation == .landscape && cellsGrid.cells.count.isMultiple(of: 10) {
            aspectRatio = .oneToTwo
        } else {
            aspectRatio = .oneToOne
        }
        
        settingsButton.frame = settingsButtonRect(aspectRatio: aspectRatio)
        settingsButton.backgroundColor = cellsUnderSettingsButton.first?.backgroundColor
    }
}

// MARK: - CellsManagerDelegate

extension GameViewController: CellsManagerDelegate {
    
    internal func cellPressed(_ cell: CellView) {
        lastPressedCell = cell
        feedbackGenerator.playSelectionHapticFeedback()
        freezeUI(for: 0.1)
    }
    
    internal func cellReleased(_ cell: CellView) {
        guard game.isRunning else { return }
        
        game.numberSelected(cell.number)
        
        if game.level.shuffleMode {
            game.shuffleNumbers()
            cellsManager.updateNumbers(with: game.numbers, animated: true)
        }
        
        feedbackGenerator.playSelectionHapticFeedback()

        guard game.selectedNumberIsRight else { return }
        
        if !game.level.shuffleMode {
            cell.setNumber(game.numberToSet, animateIfNeeded: false)
        }
    }
}

// MARK: - GameDelegate

extension GameViewController: GameDelegate {
    
    internal func gameFinished(reason: GameFinishingReason, numbersFound: Int) {
        gameFinishingReason = reason
        self.numbersFound = numbersFound
        feedbackGenerator.playVibrationFeedback()
        prepareForNewGame()
        performSegue(withIdentifier: "ShowResults", sender: nil)
    }
}

// MARK: - SettingsViewControllerDelegate

extension GameViewController: SettingsViewControllerDelegate {
    
    internal func levelDidChange(to level: Level) {
        game.newGame()
        updateViewFromModel()
    }
}

// MARK: - Notifications

extension GameViewController {
    
    @objc internal func applicationWillResignActive() {
        cellsUnderSettingsButton.forEach { $0.uncompress(hideNumber: true) }
        prepareForNewGame()
    }
}

// MARK: - Navigation

extension GameViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSettings" {
            let navigationController = segue.destination as! UINavigationController
            let settingsViewContoller = navigationController.viewControllers.first! as! SettingsViewController
            settingsViewContoller.game = game
            settingsViewContoller.delegate = self
        } else if segue.identifier == "ShowResults" {
            let resultsViewController = segue.destination as! ResultsViewController
            resultsViewController.numbersFound = numbersFound
            resultsViewController.gameFinishingReason = gameFinishingReason
        }
    }
    
}

