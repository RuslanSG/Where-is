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
        view.labels.forEach { $0.textColor = appearance.textColor }
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
        view.frame.size = CGSize(width: messageViewWidth, height: messageViewHeight)
        view.center = cellsContainerView.center
        
        view.titleLabel.textColor = appearance.textColor
        view.titleLabel.font = UIFont.systemFont(ofSize: appearance.numbersFontSize)
        view.titleLabel.text = Strings.StartButtonText
        
        view.detailLabel.textColor = appearance.textColor
        view.detailLabel.font = UIFont.boldSystemFont(ofSize: appearance.numbersFontSize / 2.2)
        view.detailLabel.text = "Цель: \(game.goal)"
        
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
    
    internal let necessaryNumberOfEvents = 3
    private var needsToShowTips: Bool {
        return showSettingsEventCounter <= necessaryNumberOfEvents && stopGameEventConunter <= necessaryNumberOfEvents
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
    
    /// Setups UI element colors
    internal func setupColors() {
        /// Sets background color
        self.view.backgroundColor = appearance.mainViewColor
        
        /// Sets status bar color
        self.setNeedsStatusBarAppearanceUpdate()
        
        /// Sets result view color
        resultsView.blur = appearance.blur
        resultsView.labels.forEach { $0.textColor = appearance.textColor }
        resultsView.actionButton.backgroundColor = appearance.userInterfaceColor
        
        /// Sets message view color
        messageView.blur = appearance.blur
        messageView.effect = appearance.blur
        messageView.titleLabel.textColor = game.colorfulCellsMode ? .white : appearance.textColor
        messageView.detailLabel.textColor = game.colorfulCellsMode ? .white : appearance.textColor
        
        /// Sets cells color
        updateCellsColorsFromModel()
        
        /// Sets tips label color
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
//        /// Stores last pressed cell
//        self.lastPressedCell = sender
//
//        /// Runs cell compression animation
//        sender.compress(numberFeedback: !game.winkNumbersMode && !game.shuffleNumbersMode && !game.swapNumbersMode)
//
//        /// Stores if selected number is right
//        self.selectedNumberIsRight = game.selectedNumberIsRight(sender.tag)
//
//        /// Ends game and runs cell uncomression animation on pressed cell if user tapped last number
//        if selectedNumberIsRight && sender.tag == game.maxNumber {
            endGame()
            sender.uncompress(hapticFeedback: selectedNumberIsRight, hiddenNumber: true)
            return
//        }
//
//        /// Says to the model that number was selected
//        game.numberSelected(sender.tag)
    }
    
    @objc func cellReleased(sender: CellView) {
        /// If user tapped the wrong number it plays error visual feedback
        if !self.selectedNumberIsRight {
            feedbackView.playErrorFeedback()
        }
        
        /// Shuffles numbers or colors under appropriate modes
        if game.inGame {
            if game.shuffleNumbersMode {
                game.shuffleNumbers()
                setNumbers(animated: true)
            }
            if game.shuffleColorsMode {
                updateCellsColorsFromModel()
            }
        }
        
        /// Runs cell uncompression animation
        sender.uncompress(hapticFeedback: self.selectedNumberIsRight)
    }
    
    private let sensetiveRect: CGRect = {
        let x = UIScreen.main.bounds.minX
        let y = UIScreen.main.bounds.minY
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height - 50.0
        return CGRect(x: x, y: y, width: width, height: height)
    }()
    
    @objc func userSwipedUp(_ sender: UISwipeGestureRecognizer) {
        let point = sender.location(in: self.view)
        if sensetiveRect.contains(point) {
            self.performSegue(withIdentifier: "showSettings", sender: sender)
            showSettingsEventCounter += 1
        }
        
        if let lastPressedCell = self.lastPressedCell {
            lastPressedCell.uncompress(hiddenNumber: true)
        }
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
    
    func levelChanged(to level: Int) {
        messageView.detailLabel.text = "Цель: \(game.goal)"
    }
    
    // MARK: - RelusltsViewDelegate
    
    func resultsViewWillHide() {
        if needsToUpdateCellColors {
            needsToUpdateCellColors = false
            prepareForColorfulCellsMode()
        }
        if needsToUpdateCellsCount {
            needsToUpdateCellsCount = false
            updateCellsCount(animated: true) {
                self.prepareForNewGame()
            }
        } else {
            prepareForNewGame()
        }
        resultsIsShowing = false
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
        if !resultsIsShowing && game.inGame {
            prepareForNewGame()
        }
    }
    
    // MARK: - Notifications
    
    @objc private func willResignActive() {
        if let cellToUncompress = lastPressedCell {
            cellToUncompress.uncompress()
        }
        if !resultsIsShowing && game.inGame {
            prepareForNewGame()
        }
    }
    
    @objc func darkModeStateChangedNotification(notification: Notification) {
        setupColors()
    }
    
    // MARK: - Helping methods
    
    private func showGreetingsViewController() {
        self.performSegue(withIdentifier: "showGrettings", sender: nil)
    }
        
}


