//
//  ViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 07.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

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
        let view = ResultsView(frame: self.view.frame, darkMode: appearance.darkMode)
        let textColor: UIColor = appearance.darkMode ? .white : .black
        view.titleLabel.textColor = textColor
        view.timeLabel.textColor = textColor
        view.actionButton.alpha = 0.0
        view.actionButton.backgroundColor = appearance.userInterfaceColor
        view.actionButton.layer.cornerRadius = appearance.cornerRadius
        return view
    }()
    
    lazy var messageView: MessageView = {
        let tapRecogrizer = UITapGestureRecognizer(target: self, action: #selector(messageViewTapped(sender:)))
        let view = MessageView(style: appearance.darkMode ? .dark : .light)
        view.layer.cornerRadius = appearance.cornerRadius
        view.clipsToBounds = true
        view.addGestureRecognizer(tapRecogrizer)
        return view
    }()
        
    // MARK: -
    
    internal lazy var appearance = Appearance(view: self.view)
    internal lazy var automaticDarkMode = AutomaticDarkMode(for: appearance)
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
        
    var timer1 = Timer()
    var timer2 = Timer()
    
    let feedbackGenerator = FeedbackGenerator()
    
    private var messageViewHeight: CGFloat {
        if let buttonHeight = buttonHeight {
            let height = buttons.count % 10 == 0 ? buttonHeight * 2 + appearance.gridInset * 2 : buttonHeight
            return height
        }
        return 0.0
    }
    
    private var messageViewWidth: CGFloat {
        if let button = buttons.first {
            let width = button.bounds.width * 3 + appearance.gridInset * 4
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
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return darkMode ? .lightContent : .default
//    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        setupInputComponents()
        setupColors()
        prepareForNewGame()
        automaticDarkMode.getUserLocation()
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
        
        appearance.userInterfaceColor = appearance.randomColor
        
        self.view.addSubview(feedbackView)
        self.view.addSubview(buttonsContainerView)
        
        addButtons(count: game.numbers.count)
        updateButtonsFrames()
        
        self.view.sendSubviewToBack(feedbackView)
        
        let height = messageViewHeight
        if let button = buttons.first {
            let width = button.bounds.width * 3 + appearance.gridInset * 4
            messageView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            messageView.center = buttonsContainerView.center
        }
    }
    
    func setupColors() {
        self.view.backgroundColor = appearance.mainViewColor
        stopButton.tintColor = appearance.userInterfaceColor
        settingsButton.tintColor = appearance.userInterfaceColor
        removeNumberColors(animated: false)
        UIApplication.shared.statusBarStyle = appearance.darkMode ? .lightContent : .default
        
        buttons.forEach { (button) in
            if game.colorfulCellsMode {
                appearance.currentColorSet.forEach { (color) in
                    if appearance.darkMode, button.backgroundColor == color.light {
                        button.backgroundColor = color.dark
                    } else if !appearance.darkMode, button.backgroundColor == color.dark {
                        button.backgroundColor = color.light
                    }
                }
            } else {
                button.backgroundColor = appearance.defaultCellsColor
            }
        }
        
        messageView.label.textColor = appearance.textColor
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
        buttons.forEach { $0.setTitleColor(appearance.textColor, for: .normal) }
        messageView.label.textColor = appearance.textColor
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
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  let nav = segue.destination as? UINavigationController,
            let svc = nav.topViewController as? SettingsTableViewController {
            svc.delegate = self
            svc.game = game
            svc.appearance = appearance
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
        if !firstTimeAppeared && automaticDarkMode.isOn {
            automaticDarkMode.setDarkModeByCurrentTime()
        }
        firstTimeAppeared = false
    }
    
    @objc func darkModeStateChangedNotification(notification: Notification) {
        setupColors()
    }
        
}


