//
//  ViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 07.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, GameDelegate, ResultsViewDelegate {
    
    internal enum Strings {
        static let StartButtonText = "Старт"
        static let SwipeUpTipLabelText = "↑ Смахните вверх, чтобы открыть настройки"
        static let SwipeDownTipLabelText = "↓ Смахните вниз, чтобы начать новую игру"
    }
    
    // MARK: -
    
    lazy var feedbackView = FeedbackView(frame: self.view.frame)
    
    lazy var cellsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var resultsView: ResultsView = {
        let view = ResultsView(frame: self.view.frame)
        view.blur = appearance.blur
        view.titleLabel.textColor = appearance.textColor
        view.timeLabel.textColor = appearance.textColor
        view.actionButton.alpha = 0.0
        view.actionButton.backgroundColor = appearance.userInterfaceColor
        view.actionButton.layer.cornerRadius = appearance.cornerRadius
        view.delegate = self
        return view
    }()
    
    lazy var messageView: MessageView = {
        let view = MessageView()
        view.blur = appearance.blur
        view.layer.cornerRadius = appearance.cornerRadius
        view.clipsToBounds = true
        view.label.textColor = appearance.textColor
        view.label.font = UIFont.systemFont(ofSize: appearance.numbersFontSize)
        view.label.text = Strings.StartButtonText
        view.frame.size = CGSize(width: messageViewWidth, height: messageViewHeight)
        view.center = cellsContainerView.center
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(startGame))
        view.addGestureRecognizer(tap)
        
        return view
    }()
    
    lazy var tipsLabel: UILabel? = {
        if !needsToShowTips { return nil }
        let height: CGFloat = 30.0
        let label = UILabel(frame: CGRect(
            x: UIScreen.main.bounds.maxX - height,
            y: UIScreen.main.bounds.minY,
            width: UIScreen.main.bounds.width,
            height: height)
        )
        label.font = UIFont.boldSystemFont(ofSize: 15.0)
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var swipeUp: UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(userSwipedUp(_:)))
        swipe.direction = .up
        return swipe
    }()
    
    lazy var swipeDown: UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(userSwipedDown(_:)))
        swipe.direction = .down
        return swipe
    }()
    
    // MARK: -
    
    internal lazy var appearance = Appearance()
    internal lazy var game: Game = {
        let game = Game()
        game.delegate = self
        return game
    }()
    
    internal let feedbackGenerator = FeedbackGenerator()
    
    var firstTimeAppeared = true
    var resultsIsShowing = false
    
    internal let requiredNumberOfEvents = 3
    private var needsToShowTips: Bool {
        return showSettingsEventCounter <= requiredNumberOfEvents && stopGameEventConunter <= requiredNumberOfEvents
    }
    internal var showSettingsEventCounter: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Key.ShowSettingsEventCount)
        }
        get {
            guard let count = UserDefaults.standard.value(forKey: UserDefaults.Key.ShowSettingsEventCount) as? Int else { return 0 }
            return count
        }
    }
    internal var stopGameEventConunter: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Key.StopGameEventCount)
        }
        get {
            guard let count = UserDefaults.standard.value(forKey: UserDefaults.Key.StopGameEventCount) as? Int else { return 0 }
            return count
        }
    }
    
    internal var selectedNumberIsRight = true
    
    var grid: Grid {
        return Grid(
            layout: .dimensions(
                rowCount: game.rows,
                columnCount: game.colums
            ),
            frame: cellsContainerView.bounds
        )
    }
        
    var winkNumberTimer = Timer()
    var swapNumberTimer = Timer()
    
    // MARK: - Cells
    
    var cells = [CellView]() {
        didSet {
            cellsNotAnimating = cells
        }
    }
    
    lazy var cellsNotAnimating = cells
    
    private var lastPressedCell: CellView!
    
    internal var buttonHeight: CGFloat? {
        if let button = cells.first {
            return button.bounds.height
        }
        return 0.0
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        setupInputComponents()
        setupColors()
        prepareForNewGame()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(darkModeStateChangedNotification(notification:)),
            name: Notification.Name.DarkModeStateDidChange,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let firstLaunch = !UserDefaults.standard.bool(forKey: UserDefaults.Key.NotFirstLaunch)
        if firstLaunch {
            showGreetingsViewController()
            UserDefaults.standard.set(true, forKey: UserDefaults.Key.NotFirstLaunch)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup UI
    
    internal func setupInputComponents() {
        self.view.addSubview(feedbackView)
        self.view.addSubview(cellsContainerView)
        
        self.view.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeDown)
        
        addCells(count: game.numbers.count)
        updateCellFrames(animated: false)
        
        if let tipsLabel = tipsLabel {
            self.view.addSubview(tipsLabel)
            // Tips label constraints
            let margins = self.view.layoutMarginsGuide
            tipsLabel.translatesAutoresizingMaskIntoConstraints = false
            let trailingConstraint = tipsLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
            let leadingConstraint = tipsLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor)
            let bottomContstraint = tipsLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -5.0)
            let heightConstraint = tipsLabel.heightAnchor.constraint(equalToConstant: 30.0)
            NSLayoutConstraint.activate([trailingConstraint, leadingConstraint, bottomContstraint, heightConstraint])
        }
    }
    
    internal func setupColors() {
        // Background color
        self.view.backgroundColor = appearance.mainViewColor
        
        // Status bar color
        self.setNeedsStatusBarAppearanceUpdate()
        
        // Result view color
        resultsView.blur = appearance.blur
        resultsView.titleLabel.textColor = appearance.textColor
        resultsView.timeLabel.textColor = appearance.textColor
        resultsView.actionButton.backgroundColor = appearance.userInterfaceColor
        
        // Message view color
        messageView.blur = appearance.blur
        messageView.effect = appearance.blur
        messageView.label.textColor = game.colorfulCellsMode ? .white : appearance.textColor
        
        // Cells color
        updateCellsColorsFromModel()
        
        // Tips label color
        tipsLabel?.textColor = appearance.textColor
    }
    
    // MARK: - Status Bar
    
    var statusBarIsHidden: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.2) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return appearance.darkMode ? .lightContent : .default
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarIsHidden
    }
    
    // MARK: - Actions
    
    @objc func cellPressed(sender: CellView) {
        self.lastPressedCell = sender
        sender.compress(numberFeedback: !game.winkNumbersMode && !game.shuffleNumbersMode && !game.swapNumbersMode)
        self.selectedNumberIsRight = game.selectedNumberIsRight(sender.tag)

        if selectedNumberIsRight && sender.tag == game.maxNumber {
            // User tapped the last number
            game.finishGame()
            
            let time = game.elapsedTime
            self.view.addSubview(resultsView)
            resultsView.show(withTime: time ?? 0.0)
            resultsIsShowing = true
            
            feedbackGenerator.playNotificationHapticFeedback(notificationFeedbackType: .success)
            sender.uncompress()
            
            game.changeLevel()
            stopAnimations()
            return
        }

        feedbackGenerator.playSelectionHapticFeedback()
        game.numberSelected(sender.tag)
    }
    
    @objc func cellReleased(sender: CellView) {
        if self.selectedNumberIsRight {
            feedbackGenerator.playSelectionHapticFeedback()
        } else {
            // User tapped the wrong number
            feedbackView.feedbackSelection(isRight: false)
            feedbackGenerator.playNotificationHapticFeedback(notificationFeedbackType: .error)
        }
        if game.inGame {
            if game.shuffleNumbersMode {
                game.shuffleNumbers()
                setNumbers(animated: true)
            }
            if game.shuffleColorsMode {
                updateCellsColorsFromModel()
            }
        }
        sender.uncompress()
    }
    
    @objc func userSwipedUp(_ sender: UISwipeGestureRecognizer) {
        if let lastPressedCell = self.lastPressedCell {
            lastPressedCell.uncompress(hiddenNumber: true)
        }
        prepareForNewGame()
        self.performSegue(withIdentifier: "showSettings", sender: sender)
        showSettingsEventCounter += 1
    }
    
    @objc func userSwipedDown(_ sender: UISwipeGestureRecognizer) {
        guard let lastPressedCell = self.lastPressedCell else { return }
        lastPressedCell.uncompress(hiddenNumber: true)
        stopGame()
    }
    
    // MARK: - GameDelegate
    
    private var needsToUpdateCellColors = false
    private var needsToUpdateCellsCount = false
    
    func colorfulCellsModeStateChanged(to state: Bool) {
        if resultsIsShowing {
            needsToUpdateCellColors = true
        } else {
            prepareForColorfulCellsMode()
        }
    }
    
    func maxNumberChanged(to maxNumber: Int) {
        if resultsIsShowing {
            needsToUpdateCellsCount = true
        } else {
            updateCellsCount(animated: false)
        }
    }
    
    // MARK: - RelusltsViewDelegate
    
    func doneButtonPressed(_ sender: UIButton) {
        resultsIsShowing = false
        if needsToUpdateCellColors {
            needsToUpdateCellColors = false
            prepareForColorfulCellsMode()
        }
        if needsToUpdateCellsCount {
            needsToUpdateCellsCount = false
            updateCellsCount(animated: true)
        }
        prepareForNewGame()
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: UINavigationController.self) {
            let nvc = segue.destination as! UINavigationController
            let svc = nvc.topViewController as! SettingsTableViewController
            svc.game = game
            svc.appearance = appearance
        } else if segue.destination.isKind(of: RootViewController.self) {
            let rvc = segue.destination as! RootViewController
            rvc.appearance = appearance
        }
    }
    
    // MARK: - Notifications
    
    @objc private func willResignActive() {
        if let cellToUncompress = lastPressedCell {
            cellToUncompress.uncompress()
        }
        prepareForNewGame()
    }
    
    @objc func darkModeStateChangedNotification(notification: Notification) {
        setupColors()
    }
    
    // MARK: - Helping methods
    
    private func showGreetingsViewController() {
        self.performSegue(withIdentifier: "showGrettings", sender: nil)
    }
        
}


