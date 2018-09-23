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
        let view = ResultsView(frame: self.view.frame, appearance: appearance)
        let textColor: UIColor = appearance.darkMode ? .white : .black
        view.titleLabel.textColor = textColor
        view.timeLabel.textColor = textColor
        view.actionButton.alpha = 0.0
        view.actionButton.backgroundColor = appearance.userInterfaceColor
        view.actionButton.layer.cornerRadius = appearance.cornerRadius
        return view
    }()
    
    lazy var messageView: MessageView = {
        let view = MessageView(appearanceInfo: appearance, gameInfo: game)
        view.layer.cornerRadius = appearance.cornerRadius
        view.clipsToBounds = true
        return view
    }()
        
    // MARK: -
    
    internal lazy var appearance = Appearance(view: self.view)
    internal lazy var automaticDarkMode = AutomaticDarkMode(for: appearance)
    internal var game = Game()
    internal let feedbackGenerator = FeedbackGenerator()
    
    var firstTimeAppeared = true
    var resultsIsShowing = false
    
    var grid: Grid {
        return Grid(
            layout: .dimensions(
                rowCount: game.rows,
                columnCount: game.colums
            ),
            frame: buttonsContainerView.bounds
        )
    }
        
    var timer1 = Timer()
    var timer2 = Timer()
    
    // MARK: - Buttons
    
    var cells = [Cell]() {
        didSet {
            buttonsContainerView.frame = buttonsContainerViewFrame
            cellsNotAnimating = cells
        }
    }
    
    lazy var cellsNotAnimating = cells
    private var lastPressedCell: Cell!
    
    internal var buttonHeight: CGFloat? {
        if let button = cells.first {
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
            name: Notification.Name(NotificationName.darkModeStateDidChange.rawValue),
            object: nil
        )
    }
    
    // MARK: - Setup UI
    
    func setupInputComponents() {
        self.view.layoutSubviews()
        
        appearance.userInterfaceColor = appearance.randomColor
        
        self.view.addSubview(feedbackView)
        self.view.addSubview(buttonsContainerView)
        
        addCells(count: game.numbers.count)
        updateButtonsFrames()
        
        self.view.sendSubviewToBack(feedbackView)
        
        messageView.frame = CGRect(x: 0.0, y: 0.0, width: messageViewWidth, height: messageViewHeight)
        messageView.center = buttonsContainerView.center
    }
    
    func setupColors() {
        self.view.backgroundColor = appearance.mainViewColor
        stopButton.tintColor = appearance.userInterfaceColor
        settingsButton.tintColor = appearance.userInterfaceColor
        UIApplication.shared.statusBarStyle = appearance.darkMode ? .lightContent : .default
    }
    
    // MARK: - Actions
    
    @objc func cellPressed(sender: Cell) {
        lastPressedCell = sender
        sender.compress()
        if !game.inGame {
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
            sender.uncompress()
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
        }
        if game.shuffleColorsMode {
            cells.forEach { $0.updateBackgroundColor(animated: true) }
            if game.colorfulNumbersMode {
                cells.forEach { $0.updateNumberColor(animated: true) }
            }
        }
    }
    
    @objc func cellReleased(sender: Cell) {
        sender.uncompress()
    }
    
    @IBAction func stopButtonPressed(sender: UIButton) {
        prepareForNewGame()
    }
    
    @IBAction func settingsButtonPressed(sender: UIButton) {
        self.prepareForNewGame()
    }
    
    // MARK: - SettingsTableViewControllerDelegate
    
    func colorfulCellsModeStateChanged(to state: Bool) {
        cells.forEach { $0.updateBackgroundColor(animated: true) }
        if state == true {
            messageView.label.textColor = .white
        } else {
            messageView.label.textColor = appearance.textColor
        }
    }
    
    func maxNumberChanged(to maxNumber: Int) {
        if cells.count < maxNumber {
            game.rows += 1
            addCells(count: maxNumber - cells.count)
        } else {
            game.rows -= 1
            removeButtons(count: cells.count - maxNumber)
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
        if let cellToUncompress = lastPressedCell {
            cellToUncompress.uncompress()
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


