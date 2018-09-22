//
//  ViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 07.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit
import CoreLocation

let UserInterfaceColorDidChangeNotification = "UserInterfaceColorDidChangeNotification"
let UserInterfaceColorStateUserInfoKey = "UserInterfaceColorStateUserInfoKey"

class GameViewController: UIViewController, SettingsTableViewControllerDelegate {

    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    // MARK: -
    
    lazy var feedbackView: UIView = {
        let view = UIView(frame: self.view.frame)
        view.backgroundColor = .clear
        view.alpha = 0.25
        return view
    }()
    
    lazy var buttonsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var resultsView: ResultsView = {
        let view = ResultsView(frame: self.view.frame, darkMode: darkMode)
        let textColor: UIColor = darkMode ? .white : .black
        view.titleLabel.textColor = textColor
        view.timeLabel.textColor = textColor
        view.actionButton.alpha = 0.0
        view.actionButton.backgroundColor = userInterfaceColor
        view.actionButton.layer.cornerRadius = cornerRadius
        return view
    }()
    
    lazy var messageView: MessageView = {
        let tapRecogrizer = UITapGestureRecognizer(target: self, action: #selector(messageViewTapped(sender:)))
        let view = MessageView(style: darkMode ? .dark : .light)
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        view.addGestureRecognizer(tapRecogrizer)
        return view
    }()
        
    // MARK: -
    
    private let userDefaults = UserDefaults.standard
    private let darkModeKey = "darkMode"
    private let automaticDarkModeKey = "automaticDarkModeKey"
    let sunriseKey = "sunrise"
    let sunsetKey = "sunset"
    
    let calendar = Calendar.current
    
    var game = Game() {
        didSet {
            print("didSet")
        }
    }
    
    var gameFinished = false {
        didSet {
            
            stopButton.isEnabled = !gameFinished
        }
    }
    
    var firstTimeAppeared = true
    var resultsIsShowing = false
    
    var grid: Grid {
        return Grid(layout: .dimensions(rowCount: game.rows, columnCount: game.colums), frame: buttonsContainerView.bounds)
    }
    
    let cellCompressionRatio = 0.90
    
    var timer1 = Timer()
    var timer2 = Timer()
    
    let feedbackGenerator = FeedbackGenerator()
    let locationManager = CLLocationManager()
    
    private var messageViewHeight: CGFloat {
        if let buttonHeight = buttonHeight {
            let height = buttons.count % 10 == 0 ? buttonHeight * 2 + gridInset * 2 : buttonHeight
            return height
        }
        return 0.0
    }
    
    private var messageViewWidth: CGFloat {
        if let button = buttons.first {
            let width = button.bounds.width * 3 + gridInset * 4
            return width
        }
        return 0.0
    }
    
    // MARK: - Buttons
    
    var buttons = [UIButton]() {
        didSet {
            buttonsContainerView.frame = buttonsContainerViewFrame
            buttonsNotAnimating = buttons
        }
    }
    
    lazy var buttonsNotAnimating = buttons
    private var lastPressedButton: UIButton!
    
    var buttonFrameX: CGFloat?
    var buttonFrameY: CGFloat?
    var buttonFrameHeight: CGFloat?
    var buttonFrameWidth: CGFloat?
    
    private var buttonHeight: CGFloat? {
        if let button = buttons.first {
            return button.bounds.height
        }
        return 0.0
    }
    
    
    
    // MARK: - Dark Mode / Light Mode
    
    var darkMode: Bool {
        set {
            userDefaults.set(newValue, forKey: darkModeKey)
            setupColors()
            setNeedsStatusBarAppearanceUpdate()
        }
        get {
            return userDefaults.bool(forKey: darkModeKey)
        }
    }
    
    var automaticDarkMode: Bool {
        set {
            userDefaults.set(newValue, forKey: automaticDarkModeKey)
        }
        get {
            return userDefaults.bool(forKey: automaticDarkModeKey)
        }
    }
    
    var sunrise: Date? {
        set {
            userDefaults.set(newValue, forKey: sunriseKey)
        }
        get {
            return userDefaults.value(forKey: sunriseKey) as? Date
        }
    }
    
    var sunset: Date? {
        set {
            userDefaults.set(newValue, forKey: sunsetKey)
        }
        get {
            return userDefaults.value(forKey: sunsetKey) as? Date
        }
    }
    
    var isDay: Bool? {
        if let sunrise = self.sunrise, let sunset = self.sunset {
            let currentTime = calendar.date(byAdding: .hour, value: 3, to: Date())!
            return currentTime > sunrise && currentTime < sunset
        } else {
            return nil
        }
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return darkMode ? .lightContent : .default
//    }
    
    // MARK: - Location
    
    var currentLocation: CLLocationCoordinate2D? = nil {
        didSet {
            if currentLocation != nil {
                getSunTimeInfo(with: currentLocation!)
                if automaticDarkMode {
                    setDarkModeByCurrentTime()
                }
            }
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        setupInputComponents()
        setupColors()
        prepareForNewGame()
        getUserLocation()
//        setNeedsStatusBarAppearanceUpdate()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(darkModeStateChangedNotification(notification:)),
            name: Notification.Name(DarkModeStateDidChangeNotification),
            object: nil
        )
    }
    
    // MARK: - Setup UI
    
    func setupInputComponents() {
        self.view.layoutSubviews()
        
        userInterfaceColor = randomColor
        
        self.view.addSubview(feedbackView)
        self.view.addSubview(buttonsContainerView)
        
        addButtons(count: game.numbers.count)
        updateButtonsFrames()
        
        self.view.sendSubviewToBack(feedbackView)
        
        let height = messageViewHeight
        if let button = buttons.first {
            let width = button.bounds.width * 3 + gridInset * 4
            messageView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            messageView.center = buttonsContainerView.center
        }
    }
    
    func setupColors() {
        self.view.backgroundColor = mainViewColor
        removeNumberColors(animated: false)
        UIApplication.shared.statusBarStyle = darkMode ? .lightContent : .default
        userInterfaceColor = randomColor
        
        buttons.forEach { (button) in
            if game.colorfulCellsMode {
                currentColorSet.forEach { (color) in
                    if darkMode, button.backgroundColor == color.light {
                        button.backgroundColor = color.dark
                    } else if !darkMode, button.backgroundColor == color.dark {
                        button.backgroundColor = color.light
                    }
                }
            } else {
                button.backgroundColor = defaultCellsColor
            }
        }
        
        messageView.label.textColor = textColor
    }
    
    // MARK: - Actions
    
    @objc func buttonPressed(sender: UIButton) {
        lastPressedButton = sender
        compressButton(sender)
        if gameFinished {
            startGame()
            messageView.hide()
            feedbackGenerator.playImpactHapticFeedback(needsToPrepare: true, style: .medium)
            return
        }
        let selectedNumberIsRight = game.selectedNumberIsRight(sender.tag)
        if selectedNumberIsRight && sender.tag == game.maxNumber {
            // User tapped the last number
            game.finishGame()
            let time = game.elapsedTime
            feedbackGenerator.playNotificationHapticFeedback(notificationFeedbackType: .success)
            uncompressButton(sender)
            prepareForNewGame()
            self.view.addSubview(resultsView)
            resultsView.show(withTime: time ?? 0.0)
            resultsIsShowing = true
            return
        }
        if selectedNumberIsRight {
            // User tapped the right number
            feedbackGenerator.playImpactHapticFeedback(needsToPrepare: true, style: .medium)
        } else {
            // User tapped the wrong number
            feedbackSelection(isRight: false)
            feedbackGenerator.playNotificationHapticFeedback(notificationFeedbackType: .error)
        }
        game.numberSelected(sender.tag)
        if game.shuffleNumbersMode {
            game.shuffleNumbers()
            updateNumbers(animated: true)
        } else {
            if !game.winkNumbersMode {
                sender.titleLabel?.alpha = 0.2
            }
        }
        if game.shuffleColorsMode {
            shuffleCellsColors(animated: true)
            if game.colorfulNumbersMode {
                shuffleNumbersColors(animated: true)
            }
        }
    }
    
    @objc func buttonReleased(sender: UIButton) {
        if !gameFinished, !game.shuffleNumbersMode, !game.winkNumbersMode {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.3,
                delay: 0.0,
                options: [],
                animations: {
                    sender.titleLabel?.alpha = 1.0
            })
        }
        uncompressButton(sender)
    }
    
    @IBAction func stopButtonPressed(sender: UIButton) {
        prepareForNewGame()
    }
    
    @IBAction func settingsButtonPressed(sender: UIButton) {
        self.prepareForNewGame()
    }
    
    @objc private func messageViewTapped(sender: UITapGestureRecognizer) {
        startGame()
        messageView.hide()
        feedbackGenerator.playImpactHapticFeedback(needsToPrepare: true, style: .medium)
    }
    
    // MARK: - SettingsTableViewControllerDelegate
    
    func colorfulNumbersModeStateChanged(to state: Bool) {
        if state == false {
            removeNumberColors(animated: false)
        }
        prepareForNewGame()
    }
    
    func colorfulCellsModeStateChanged(to state: Bool) {
        if state == false {
            removeCellColors(animated: false)
            removeNumberColors(animated: false)
        } else {
            shuffleCellsColors(animated: false)
        }
        buttons.forEach { $0.setTitleColor(textColor, for: .normal) }
        messageView.label.textColor = textColor
        prepareForNewGame()
    }
    
    func maxNumberChanged(to maxNumber: Int) {
        if buttons.count < maxNumber {
            game.rows += 1
            addButtons(count: maxNumber - buttons.count)
        } else {
            game.rows -= 1
            removeButtons(count: buttons.count - maxNumber)
        }
        
        updateButtonsFrames()
        prepareForNewGame()
        messageView.frame = CGRect(x: 0.0, y: 0.0, width: messageViewWidth, height: messageViewHeight)
        messageView.center = buttonsContainerView.center
    }
    
    func automaticDarkModeStateChanged(to state: Bool) {
        automaticDarkMode = state
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  let nav = segue.destination as? UINavigationController,
            let svc = nav.topViewController as? SettingsTableViewController {
            svc.delegate = self
            svc.game = game
            svc.isDay = isDay
            svc.userInterfaceColor = userInterfaceColor
            svc.darkMode = darkMode
            svc.automaticDarkMode = automaticDarkMode
        }
    }
    
    // MARK: - Notifications
    
    @objc private func willResignActive() {
        if let buttonToUncompress = lastPressedButton {
            uncompressButton(buttonToUncompress)
        }
        prepareForNewGame()
    }
    
    @objc private func didBecomeActive() {
        if !firstTimeAppeared && automaticDarkMode {
            setDarkModeByCurrentTime()
        }
        firstTimeAppeared = false
    }
    
    @objc func darkModeStateChangedNotification(notification: Notification) {
        let darkModeNewState = notification.userInfo?[DarkModeStateUserInfoKey] as! Bool
        if darkMode != darkModeNewState {
            darkMode = darkModeNewState
        }
    }
        
}


