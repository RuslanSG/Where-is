//
//  ViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 07.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, GameDelegate, ResultsViewDelegate, MessageViewDelegate {
    
    internal enum Strings {
        static let StartButtonText = NSLocalizedString("Старт", comment: "Начать игру")
        static let StartButtonGoalText = NSLocalizedString("Цель:", comment: "За сколько времени нужно пройти уровень")
        static let StartButtonInfinityModeText = NSLocalizedString("Цель: ∞", comment: "За сколько времени нужно пройти уровень")
        static let SwipeUpTipLabelText = NSLocalizedString("↑ Смахните вверх, чтобы открыть настройки", comment: "Открыть настройки") 
        static let SwipeDownTipLabelText = NSLocalizedString("↓ Смахните вниз, чтобы остановить", comment: "Остановить игру")
        static let CongratulationsTitle = NSLocalizedString("Поздравляю!🎂", comment: "Поздарвление")
        static let CongratulationsText = NSLocalizedString("Вы прошли все %d уровней! Отличная работа! Это наверняка была нелегкая задача, но Вы справились и сильно развили свою внимательность.\n\nТеперь стал доступен '∞' уровень, который позволит Вам и дальше совершенствовать свои навыки. После нахождения число будет заменено на новое. У Вас есть 5 сек на поиски каждого. Старайтесь найти как можно больше чисел и достигайте новых вершин! Удачи!\n\nПоставьте, пожалуйста, оценку моему приложению и оставьте отзыв. Для меня очень важно знать Ваше мнение.", comment: "")
    }
    
    // MARK: -
    
    internal lazy var feedbackView = FeedbackView(frame: self.view.frame)
    
    internal lazy var cellsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    internal lazy var resultsView: ResultsView = {
        let view = ResultsView(frame: self.view.frame)
        view.blur = appearance.blur
        view.labels.forEach { $0.textColor = appearance.textColor }
        view.actionButton.alpha = 0.0
        view.actionButton.backgroundColor = appearance.userInterfaceColor
        view.actionButton.layer.cornerRadius = appearance.cornerRadius
        view.delegate = self
        return view
    }()
    
    internal lazy var messageView: MessageView = {
        let view = MessageView(frame: self.view.frame)
        view.blur = appearance.blur
        view.labels.forEach { $0.textColor = appearance.textColor }
        view.actionButton.alpha = 0.0
        view.actionButton.backgroundColor = appearance.userInterfaceColor
        view.actionButton.layer.cornerRadius = appearance.cornerRadius
        view.delegate = self
        return view
    }()
    
    internal lazy var startGameView: StartGameView = {
        let view = StartGameView()
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
        view.detailLabel.text = game.infinityMode ? Strings.StartButtonInfinityModeText : Strings.StartButtonGoalText + " " + String(game.goal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(startGame))
        view.addGestureRecognizer(tap)
        
        return view
    }()
    
    internal lazy var tipsLabel: RGAnimatedLabel? = {
        if !needsToShowTips { return nil }
        let label = RGAnimatedLabel()
        label.font = UIFont.boldSystemFont(ofSize: 15.0)
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    internal var timeLabel: RGAnimatedLabel = {
        let label = RGAnimatedLabel()
        var fontSize: CGFloat = {
            switch UIDevice.current.platform {
            case .iPhoneX: return 15.0
            case .iPhoneXR: return 16.0
            case .iPhoneXSMax: return 16.0
            default: return 12.0
            }
        }()
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.textAlignment = .center
        label.alpha = 0.0
        label.textColor = .red
        return label
    }()
    
    internal lazy var swipeUp: UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(userSwipedUp(_:)))
        swipe.direction = .up
        return swipe
    }()
    
    internal lazy var swipeDown: UISwipeGestureRecognizer = {
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
    
    internal let necessaryNumberOfEvents = 5
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
    
    internal var lastPressedCell: CellView?
    
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
            
            /// Tips label constraints
            let tipsLabelInset: CGFloat = 5.0
            let tipsLabelHeight: CGFloat = 30.0
            let margins = self.view.layoutMarginsGuide
            
            tipsLabel.translatesAutoresizingMaskIntoConstraints = false
            tipsLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
            tipsLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
            tipsLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -tipsLabelInset).isActive = true
            tipsLabel.heightAnchor.constraint(equalToConstant: tipsLabelHeight).isActive = true
        }
        
        /// Setups timeLabel
        self.view.addSubview(timeLabel)
        
        let timeLabelTopInset: CGFloat = {
            switch UIDevice.current.platform {
            case .iPhoneX: return 13.0
            case .iPhoneXR: return 15.0
            case .iPhoneXSMax: return 12.5
            default: return 0.0
            }
        }()
        
        let timeLabelLeadingInset: CGFloat? = {
            switch UIDevice.current.platform {
            case .iPhoneX: return 21.5
            case .iPhoneXR: return 26.5
            case .iPhoneXSMax: return 32.0
            default: return nil
            }
        }()
        
        let timeLabelHeight: CGFloat = 20.0
        let timeLabelWidth: CGFloat = 50.0
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        if UIDevice.current.hasLiquidRetina {
            timeLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: timeLabelLeadingInset ?? 0.0).isActive = true
            timeLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: timeLabelTopInset).isActive = true
        } else {
            timeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0.9).isActive = true
            timeLabel.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        }
        
        timeLabel.heightAnchor.constraint(equalToConstant: timeLabelHeight).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: timeLabelWidth).isActive = true
    }
    
    /// Setups UI element colors
    internal func setupColors() {
        /// Sets background color
        self.view.backgroundColor = appearance.mainViewColor
        
        /// Sets status bar color
        self.setNeedsStatusBarAppearanceUpdate()
        
        /// Sets resultsView color
        resultsView.blur = appearance.blur
        resultsView.labels.forEach { $0.textColor = appearance.textColor }
        resultsView.actionButton.backgroundColor = appearance.userInterfaceColor
        resultsView.levelLabel.backgroundColor = appearance.userInterfaceColor
        
        /// Sets messageView color
        messageView.blur = appearance.blur
        messageView.labels.forEach { $0.textColor = appearance.textColor }
        messageView.leaveFeedbackButton.setTitleColor(appearance.userInterfaceColor, for: .normal)
        messageView.actionButton.backgroundColor = appearance.userInterfaceColor
        
        /// Sets startGameView color
        startGameView.blur = appearance.blur
        startGameView.effect = appearance.blur
        startGameView.titleLabel.textColor = game.colorfulCellsMode ? .white : appearance.textColor
        startGameView.detailLabel.textColor = game.colorfulCellsMode ? .white : appearance.textColor
        
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
        /// Stores last pressed cell
        self.lastPressedCell = sender

        /// Runs cell compression animation
        let numberFeedback = !game.winkNumbersMode && !game.shuffleNumbersMode && !game.swapNumbersMode && !game.infinityMode
        sender.compress(numberFeedback: numberFeedback)

        /// Stores if selected number is right
        self.selectedNumberIsRight = game.selectedNumberIsRight(sender.tag)

        /// Ends game and runs cell uncomression animation on pressed cell if user tapped last number
        if selectedNumberIsRight && sender.tag == game.maxNumber, !game.infinityMode {
            endGame(levelPassed: true)
            sender.uncompress(hiddenNumber: true)
            return
        }

        /// Says to the model that number was selected
        game.numberSelected(sender.tag)
    }
    
    private var counter: CGFloat = 0.0
    
    @objc func cellReleased(sender: CellView) {
        /// If user tapped the wrong number it plays error visual feedback
        if !self.selectedNumberIsRight {
            feedbackView.playErrorFeedback()
            if self.timeLabel.isAnimaing {
                counter += 1.0
                self.timeLabel.stopAnimation()
                self.timeLabel.alpha = 1.0
            } else {
                counter = 1.0
            }
            
            self.timeLabel.showAndHideText("+" + String(format: "%.02f", counter), duration: 1.0)
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
            /// Runs cell uncompression animation
            sender.uncompress(hapticFeedback: self.selectedNumberIsRight)
        }
        
        if game.infinityMode, self.selectedNumberIsRight {
            sender.setNumber(game.infinityModeMaxNumber, animated: true)
        }
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
        if sensetiveRect.contains(point), !self.resultsIsShowing {
            self.performSegue(withIdentifier: "showSettings", sender: sender)
            showSettingsEventCounter += 1
            
        }
        if let lastPressedCell = self.lastPressedCell {
            lastPressedCell.uncompress(hiddenNumber: true)
        }
    }
    
    @objc func userSwipedDown(_ sender: UISwipeGestureRecognizer) {
        if !self.resultsIsShowing {
            guard let lastPressedCell = self.lastPressedCell else { return }
            lastPressedCell.uncompress(hiddenNumber: true)
            stopGame()
        }
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
        startGameView.detailLabel.text = game.infinityMode ? Strings.StartButtonInfinityModeText : Strings.StartButtonGoalText + " " + String(game.goal)
    }
    
    func timeIsOut() {
        endGame(levelPassed: false)
    }
    
    // MARK: - RelusltsViewDelegate
    
    func resultsViewWillHide() {
        completeNewGamePreparations()
    }
    
    // MARK: - MessageViewDelegate
    
    func messageViewWillHide() {
        completeNewGamePreparations()
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
    
    private func completeNewGamePreparations() {
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
        
}


