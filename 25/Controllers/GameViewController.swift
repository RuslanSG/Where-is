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
        return view
    }()
    
    lazy var messageView: MessageView = {
        let view = MessageView()
        view.blur = appearance.blur
        view.layer.cornerRadius = appearance.cornerRadius
        view.clipsToBounds = true
        view.label.textColor = appearance.textColor
        view.label.font = UIFont.systemFont(ofSize: appearance.numbersFontSize)
        view.frame.size = CGSize(width: messageViewWidth, height: messageViewHeight)
        view.center = cellsContainerView.center
        return view
    }()
    
    // MARK: -
    
    internal lazy var appearance = Appearance()
    internal var game = Game()
    
    internal let feedbackGenerator = FeedbackGenerator()
    
    var firstTimeAppeared = true
    var resultsIsShowing = false
    
    private var selectedNumberIsRight: Bool?
    
    var grid: Grid {
        return Grid(
            layout: .dimensions(
                rowCount: game.rows,
                columnCount: game.colums
            ),
            frame: cellsContainerView.bounds
        )
    }
        
    var timer1 = Timer()
    var timer2 = Timer()
    
    // MARK: - Buttons
    
    var cells = [CellView]() {
        didSet {
            cellsContainerView.frame = buttonsContainerViewFrame
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
        self.view.layoutSubviews()
                
        self.view.addSubview(feedbackView)
        self.view.addSubview(cellsContainerView)
        
        addCells(count: game.numbers.count)
        
        self.view.sendSubviewToBack(feedbackView)
    }
    
    internal func setupColors() {
        // Background color
        self.view.backgroundColor = appearance.mainViewColor
        
        // Control buttons color
        stopButton.tintColor = appearance.userInterfaceColor
        settingsButton.tintColor = appearance.userInterfaceColor
                
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
    }
    
    // MARK: - Actions
    
    @objc func cellPressed(sender: CellView) {
        lastPressedCell = sender
        sender.compress(numberFeedback: !game.winkNumbersMode && !game.shuffleNumbersMode)
        if !game.inGame {
            startGame()
            messageView.hide()
            feedbackGenerator.playSelectionHapticFeedback()
            self.selectedNumberIsRight = true
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
            feedbackGenerator.playSelectionHapticFeedback()
            self.selectedNumberIsRight = true
        } else {
            // User tapped the wrong number
            feedbackView.feedbackSelection(isRight: false)
            feedbackGenerator.playNotificationHapticFeedback(notificationFeedbackType: .error)
        }
        game.numberSelected(sender.tag)
        if game.shuffleNumbersMode {
            game.shuffleNumbers()
            updateNumbers(animated: true)
        }
        if game.shuffleColorsMode {
            updateCellsColorsFromModel()
        }
    }
    
    @objc func cellReleased(sender: CellView) {
        sender.uncompress()
        if let selectedNumberIsRight = self.selectedNumberIsRight, selectedNumberIsRight == true {
            feedbackGenerator.playSelectionHapticFeedback()
            self.selectedNumberIsRight = nil
        }
    }
    
    @IBAction func stopButtonPressed(sender: UIButton) {
        prepareForNewGame()
    }
    
    @IBAction func settingsButtonPressed(sender: UIButton) {
        self.prepareForNewGame()
    }
    
    // MARK: - SettingsTableViewControllerDelegate
    
    func colorfulCellsModeStateChanged(to state: Bool) {
        messageView.label.textColor = state ? .white : .black
        for cell in cells {
            let newCellBackgroundColor = state ? appearance.randomColor : appearance.defaultCellsColor
            cell.setBackgroundColor(to: newCellBackgroundColor, animated: true)
        }
    }
    
    func maxNumberChanged(to maxNumber: Int) {
        if cells.count < maxNumber {
            game.rows += 1
            addCells(count: maxNumber - cells.count)
        } else {
            game.rows -= 1
            removeCells(count: cells.count - maxNumber)
        }
        
        updateCellFrames()
        prepareForNewGame()
        messageView.frame = CGRect(x: 0.0, y: 0.0, width: messageViewWidth, height: messageViewHeight)
        messageView.center = cellsContainerView.center
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: UINavigationController.self) {
            let nvc = segue.destination as! UINavigationController
            let svc = nvc.topViewController as! SettingsTableViewController
            svc.delegate = self
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
        #warning ("Move identifier to the constants")
    }
        
}


