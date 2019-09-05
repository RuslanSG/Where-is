//
//  GameViewController.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/2/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    internal var cellsGrid: CellsGrid!
    private var lastPressedCell: CellView?
    internal var cellsUnderSettingsButton = [CellView]()
    internal var startGameButton: StartGameView!
    internal var settingsButton: UIButton!
    private var swipeDownGestureRecognizer: UISwipeGestureRecognizer!
    
    private let game = Game()
    private lazy var cellsManager = CellsManager(with: cellsGrid.cells, game: game)
    
    private var feedbackView = FeedbackView()
    private var feedbackGenerator = FeedbackGenerator()
    private var gameFinishingReason: GameFinishingReason!
    
    private lazy var stopGameHintLabel: HintLabel? = {
        let stopGameHintNeeded = UserDefaults.standard.bool(forKey: UserDefaults.Key.stopGameHintNeeded)
        
        if stopGameHintNeeded {
            let label = HintLabel()
            
            label.text = "↓ Swipe down to stop"
            label.font = UIFont.boldSystemFont(ofSize: 15)
            
            return label
        }
        
        return nil
    }()
    
    private lazy var findNumberHintLabels: (title: HintLabel, details: HintLabel)? = {
        if findNumberHintNeeded {
            let titleLabel = HintLabel()
            let detailsLabel = HintLabel()
                    
            titleLabel.text = "Find 1"
            titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
            
            detailsLabel.text = ""
            detailsLabel.font = UIFont.systemFont(ofSize: 17)
            
            return (title: titleLabel, details: detailsLabel)
        }
        
        return nil
    }()

    
    internal let rowSize = 5
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
            return (UIScreen.main.bounds.width - globalCellInset) / CGFloat(rowSize)
        } else {
            return (UIScreen.main.bounds.height - globalCellInset) / CGFloat(rowSize)
        }
    }
    
    private weak var timer: Timer?
    private var startTime = 0.0
    private var timeLeft = 0.0
    private var time = 0.0
    
    private var stopGameHintNeeded: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.Key.stopGameHintNeeded)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Key.stopGameHintNeeded)
        }
    }
    
    private var findNumberHintNeeded: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.Key.findNumberHintNeeded)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Key.findNumberHintNeeded)
        }
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showTutorialIfNeeded()
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
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
        
        if orientation == .portrait {
            (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
                        
            if stopGameHintNeeded {
                stopGameHintLabel?.show(animated: true)
            }
                        
            if findNumberHintNeeded {
                findNumberHintLabels?.title.show(animated: true)
                findNumberHintLabels?.details.show(animated: true)
                startTimer()
            }
        } else {
            (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .landscape
        }
    }
    
    @objc func swipeDown() {
        prepareForNewGame()
        UserDefaults.standard.set(false, forKey: UserDefaults.Key.stopGameHintNeeded)
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
        cellsUnderSettingsButton.forEach { $0.uncompress(showNumber: false) }
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
        setupHintLabels()
    }
    
    private func prepareForNewGame() {
        game.newGame()
        
        cellsManager.stopWinking()
        cellsManager.stopSwapping()
        cellsManager.disableCells()
        cellsManager.updateNumbers(with: game.numbers, animated: false)
        cellsManager.hideNumbers(animated: false)
        
        swipeDownGestureRecognizer.isEnabled = false
        
        startGameButton.show()
        
        stopGameHintLabel?.hide(animated: true)
        findNumberHintLabels?.title.hide(animated: true)
        findNumberHintLabels?.title.text = "Find 1"
        findNumberHintLabels?.details.hide(animated: true)
        
        UIView.animate(withDuration: 0.2) {
            self.settingsButton.isHidden = false
        }
        
        lastPressedCell?.uncompress(showNumber: false)
        
        timer?.invalidate()
        
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .allButUpsideDown
    }
    
    private func freezeUI(for freezeTime: Double) {
        self.view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + freezeTime) {
            self.view.isUserInteractionEnabled = true
        }
    }
    
    private func showTutorialIfNeeded() {
        let userDefaults = UserDefaults.standard
        let tutorialNeeded = userDefaults.bool(forKey: UserDefaults.Key.firstTime)
        if tutorialNeeded {
            guard let instructionsViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: InstructionsViewController.self)) as? InstructionsViewController else { return }
            present(instructionsViewController, animated: true)
        }
    }
}

// MARK: - UI Managment

extension GameViewController {
    
    private func setupCellsGrid() {
        cellsGrid = CellsGrid(rowSize: 5, rowHeight: cellHeight)
        
        view.addSubview(cellsGrid)
        
        cellsGrid.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = view.layoutMarginsGuide
        cellsGrid.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        cellsGrid.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        cellsGrid.topConstraint = cellsGrid.topAnchor.constraint(greaterThanOrEqualTo: margins.topAnchor, constant: globalCellInset)
        cellsGrid.leftConstraint = cellsGrid.leftAnchor.constraint(greaterThanOrEqualTo: margins.leftAnchor)
        
        cellsGrid.addRows(count: game.numbers.count / rowSize, animated: false)
        cellsManager.setStyle(to: cellStyle, palette: .hot, animated: false)
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
        startGameButton = StartGameView()
        
        self.view.addSubview(startGameButton)
        
        startGameButton.layer.cornerRadius = globalCornerRadius
        startGameButton.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(startGame))
        startGameButton.addGestureRecognizer(tap)
    }
    
    private func setupSettingsButton() {
        let gearImage = UIImage(named: "gear")?.withRenderingMode(.alwaysTemplate)
        
        settingsButton = UIButton()
        settingsButton.setImage(gearImage, for: .normal)
        settingsButton.imageView?.contentMode = .scaleAspectFit
        settingsButton.imageEdgeInsets = UIEdgeInsets(top: 17.0, left: 17.0, bottom: 17.0, right: 17.0)
        settingsButton.backgroundColor = cellsUnderSettingsButton.first?.backgroundColor
        settingsButton.layer.cornerRadius = globalCornerRadius
        settingsButton.addTarget(self, action: #selector(settingsButtonPressed), for: .touchDown)
        settingsButton.addTarget(self, action: #selector(settingsButtonReleased), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsButtonReleased), for: .touchUpOutside)
        
        view.addSubview(settingsButton)
    }
    
    private func setupGestureRecognizers() {
        swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        swipeDownGestureRecognizer.direction = .down
        swipeDownGestureRecognizer.cancelsTouchesInView = false
        swipeDownGestureRecognizer.isEnabled = false
        
        self.view.addGestureRecognizer(swipeDownGestureRecognizer)
    }
    
    private func setupHintLabels() {
        if let stopGameHintLabel = stopGameHintLabel {
            view.addSubview(stopGameHintLabel)
            
            stopGameHintLabel.translatesAutoresizingMaskIntoConstraints = false
            stopGameHintLabel.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -7.0).isActive = true
            stopGameHintLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 7.0).isActive = true
            stopGameHintLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -7.0).isActive = true
        }
        
        if let findNumberTipLabels = findNumberHintLabels {
            let vStackView = UIStackView(arrangedSubviews: [findNumberTipLabels.title, findNumberTipLabels.details])
            vStackView.axis = .vertical
            vStackView.spacing = 10
            
            view.addSubview(vStackView)
            
            let margins = view.layoutMarginsGuide
            vStackView.translatesAutoresizingMaskIntoConstraints = false
            vStackView.bottomAnchor.constraint(equalTo: cellsGrid.topAnchor, constant: -16).isActive = true
            vStackView.leftAnchor.constraint(equalTo: margins.leftAnchor).isActive = true
            vStackView.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
            vStackView.topAnchor.constraint(greaterThanOrEqualTo: margins.topAnchor, constant: 16).isActive = true
        }
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
        settingsButton.tintColor = cellsUnderSettingsButton.first?.titleLabel?.textColor
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        startTime = Date().timeIntervalSinceReferenceDate
        timeLeft = game.level.interval
        
        guard let countdownLabel = findNumberHintLabels?.details else { return }
        let timeString = String(format: "%.2f", game.level.interval)
        countdownLabel.text = timeString
        
        timer = Timer.scheduledTimer(timeInterval: 0.05,
                                     target: self,
                                     selector: #selector(advaneTimer(_:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc private func advaneTimer(_ timer: Timer) {
        time = Date().timeIntervalSinceReferenceDate - startTime
        startTime = Date().timeIntervalSinceReferenceDate
        timeLeft -= time

        if timeLeft >= 0 {
            let timeString = String(format: "%.2f", timeLeft)

            guard let countdownLabel = findNumberHintLabels?.details else { return }
            countdownLabel.text = timeString
        } else {
            timer.invalidate()
        }
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
        
        feedbackGenerator.playSelectionHapticFeedback()
        
        if game.numberSelected(cell.number) {
            if let findNumberHintLabels = findNumberHintLabels {
                let newText = findNumberHintLabels.title.text!.components(separatedBy: CharacterSet.decimalDigits).joined() + String(game.nextNumber)
                findNumberHintLabels.title.text = newText
                timer?.invalidate()
                startTimer()
            }
            
            if game.level.shuffleMode {
                game.shuffleNumbers()
                cellsManager.updateNumbers(with: game.numbers, animated: true)
            } else {
                cell.setNumber(game.numberToSet, animateIfNeeded: false)
            }
                    
            if game.nextNumber == 11 {
                UserDefaults.standard.set(false, forKey: UserDefaults.Key.findNumberHintNeeded)
            }
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
        cellsUnderSettingsButton.forEach { $0.uncompress(showNumber: false) }
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
