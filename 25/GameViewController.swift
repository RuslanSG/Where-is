//
//  ViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 07.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit
import AudioToolbox.AudioServices

class GameViewController: UIViewController, SettingsTableViewControllerDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    // MARK: -
    
    lazy var feedbackView: UIView = {
        let view = UIView(frame: self.view.frame)
        view.backgroundColor = .clear
        view.alpha = 0.25
        return view
    }()
    
    lazy var buttonsContainerView: UIView = {
        let view = UIView(frame: buttonsFieldFrame)
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Message view
    
    lazy var messageView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blur)
        let offset: CGFloat = 2.0
        view.frame = self.view.frame
        view.alpha = 0.0
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: label.font.fontName, size: 45)
        return label
    }()
    
    let detailsLabel: UILabel = {
        let label = UILabel()
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        label.textAlignment = .left
        label.font = UIFont(name: label.font.fontName, size: 15)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 250.0, height: 100.0))
        label.text = "140.00"
        label.center = messageView.center
        label.textAlignment = .center
        label.font = UIFont(name: label.font.fontName, size: 90)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = userInterfaceColor
        button.layer.cornerRadius = cornerRadius
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.addTarget(self, action: #selector(startButtonPressed(sender:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: -
    
    var cornerRadius: CGFloat {
        if self.view.traitCollection.horizontalSizeClass == .regular, self.view.traitCollection.verticalSizeClass == .regular {
            return 12.0
        } else {
            return 7.0
        }
    }
    
    var numbersFontSize: CGFloat {
        return self.view.bounds.width / 10
    }
    
    var gridInset: CGFloat {
        return self.view.bounds.width / 200
    }
    
    private var buttonsFieldFrame: CGRect {
        let height = self.view.bounds.width / CGFloat(game.colums) * CGFloat(game.rows)
        let pointY = self.view.bounds.midY - height / 2 - 38
        let staturBarHeight = UIApplication.shared.statusBarFrame.height
        let startButtonFrameY = startButton.frame.minY
        let maxAlllowedButtonsContainerViewHeight = startButtonFrameY - staturBarHeight - gridInset
        return CGRect(
            x: gridInset,
            y: pointY > 0 ? pointY : staturBarHeight,
            width: self.view.bounds.width - gridInset * 2,
            height: height < maxAlllowedButtonsContainerViewHeight ? height : maxAlllowedButtonsContainerViewHeight
        )
    }
    
    // MARK: -
    
    lazy var game = Game()
    var gameFinished = false {
        didSet {
            startButton.isEnabled = gameFinished
            startButton.alpha = startButton.isEnabled ? 1.0 : 0.3
            newGameButton.isEnabled = !gameFinished
        }
    }
    
    var grid: Grid {
        return Grid(layout: .dimensions(rowCount: game.rows, columnCount: game.colums), frame: buttonsContainerView.bounds)
    }
    var buttons = [UIButton]() {
        didSet {
            buttonsContainerView.frame = buttonsFieldFrame
        }
    }
    
    var timer = Timer()
    
    // MARK: - Colors
    
    let defaultCellsColor = #colorLiteral(red: 0.2203874684, green: 0.2203874684, blue: 0.2203874684, alpha: 1)
    let defaultNumbersColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    private let colorSets = [[#colorLiteral(red: 0.03137254902, green: 0.3058823529, blue: 0.4941176471, alpha: 1), #colorLiteral(red: 0.06666666667, green: 0.4823529412, blue: 0.462745098, alpha: 1), #colorLiteral(red: 0.05098039216, green: 0.4392156863, blue: 0.05882352941, alpha: 1)],
                             [#colorLiteral(red: 0.9921568627, green: 0.5764705882, blue: 0.1490196078, alpha: 1), #colorLiteral(red: 0.7019607843, green: 0.1019607843, blue: 0.06274509804, alpha: 1), #colorLiteral(red: 0.5921568627, green: 0.1176470588, blue: 0.368627451, alpha: 1)],
                             [#colorLiteral(red: 0.5738074183, green: 0.5655357838, blue: 0, alpha: 1), #colorLiteral(red: 0.5787474513, green: 0.3215198815, blue: 0, alpha: 1), #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)]]
    lazy var randomColorSet = colorSets[colorSets.count.arc4random]
    
    var randomColor: UIColor {
        let randomColor = randomColorSet[randomColorSet.count.arc4random]
        return randomColor
    }
    
    private lazy var userInterfaceColor = randomColor
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        setupInputComponents()
        prepareForNewGame()
    }
    
    // MARK: - Setup UI
    
    func setupInputComponents() {
        startButton.backgroundColor = userInterfaceColor
        newGameButton.tintColor     = userInterfaceColor
        settingsButton.tintColor    = userInterfaceColor
        
        startButton.layer.cornerRadius = cornerRadius
        
        self.view.addSubview(messageView)
        self.view.addSubview(feedbackView)
        self.view.addSubview(buttonsContainerView)
        
        addButtons(count: game.numbers.count)
        updateButtonsFrames()
        
        self.view.sendSubview(toBack: buttonsContainerView)
        self.view.sendSubview(toBack: feedbackView)
        
        messageView.contentView.addSubview(titleLabel)
        messageView.contentView.addSubview(timeLabel)
        messageView.contentView.addSubview(actionButton)
        
        messageView.addConstraintsWithFormat(format: "H:|-30-[v0]-30-|", views: titleLabel)
        messageView.addConstraintsWithFormat(format: "V:|-100-[v0(35)]", views: titleLabel)
        
        let currentDeviceIsIPhoneX = UIScreen.main.nativeBounds.height == 2436
        messageView.addConstraintsWithFormat(format: "H:|-\(gridInset * 2)-[v0]-\(gridInset * 2)-|", views: actionButton)
        messageView.addConstraintsWithFormat(format: currentDeviceIsIPhoneX ? "V:[v0(40)]-76-|" : "V:[v0(40)]-42-|", views: actionButton)
    }
    
    // MARK: - Actions
    
    @objc func buttonPressed(sender: UIButton) {
        let selectedNumberIsRight = game.selectedNumberIsRight(sender.tag)
        if selectedNumberIsRight && sender.tag == game.maxNumber {
            // User tapped the last number
            game.finishGame()
            showResults(time: game.elapsedTime, maxNumber: game.maxNumber, level: game.level - 1)
            prepareForNewGame(hideMessageLabel: false)
            playNotificationHapticFeedback(notificationFeedbackType: .success)
            return
        }
        if game.shuffleNumbersMode {
            game.shuffleNumbers()
            updateNumbers(animated: true)
        } else {
            sender.titleLabel?.alpha = 0.2
        }
        if game.shuffleColorsMode {
            shuffleCellColors(animated: true)
        }
        if selectedNumberIsRight {
            // User tapped the right number
            feedbackSelection(isRight: true)
            playImpactHapticFeedback(needsToPrepare: true, style: .medium)
        } else {
            // User tapped the wrong number
            feedbackSelection(isRight: false)
            playNotificationHapticFeedback(notificationFeedbackType: .error)
        }
        game.numberSelected(sender.tag)
    }
    
    @objc func buttonResign(sender: UIButton) {
        if !gameFinished, !game.shuffleNumbersMode {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.1,
                delay: 0.0,
                options: [],
                animations: {
                    sender.titleLabel?.alpha = 1.0
            })
        }
    }
    
    @IBAction func startButtonPressed(sender: UIButton) {
        hideResults()
        showNumbers(animated: true)
        game.startGame()
        gameFinished = false
        
        impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator?.prepare()
        
        if game.winkNumbersMode || game.winkColorsMode {
            timer = Timer.scheduledTimer(
                timeInterval: game.winkColorsMode ? 0.1 : 0.2,
                target: self,
                selector: #selector(timerSceduled),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    @IBAction func newGameButtonPressed(sender: UIButton) {
        prepareForNewGame()
    }
    
    // MARK: - SettingsTableViewControllerDelegate
    
    func shuffleNumbersModeStateChanged(to state: Bool) {
        game.shuffleNumbersMode = state
        prepareForNewGame()
    }
    
    func colorfulNumbersModeStateChanged(to state: Bool) {
        game.colorfulNumbersMode = state
        prepareForNewGame()
        if state == false {
            removeNumberColors(animated: false)
        }
    }
    
    func winkNumbersModeStateChanged(to state: Bool) {
        game.winkNumbersMode = state
        prepareForNewGame()
    }
    
    
    func colorfulCellsModeStateChanged(to state: Bool) {
        game.colorfulCellsMode = state
        prepareForNewGame()
        if state == false {
            removeCellColors(animated: false)
            removeNumberColors(animated: false)
        }
    }
    
    func shuffleColorsModeStateChanged(to state: Bool) {
        prepareForNewGame()
        game.shuffleColorsMode = state
    }
    
    func winkColorsModeStateChanged(to state: Bool) {
        prepareForNewGame()
        game.winkColorsMode = state
    }

    
    func levelChanged(to level: Int) {
        prepareForNewGame()
        game.level = level
        if level == game.minLevel {
            removeCellColors(animated: false)
        } else if level > game.minLevel {
            shuffleCellColors(animated: false)
        }
    }
    
    func maxNumberChanged(to maxNumber: Int) {
        if buttons.count < maxNumber {
            game.rows += 1
            addButtons(count: maxNumber - buttons.count)
        } else {
            game.rows -= 1
            removeButtons(count: buttons.count - maxNumber)
        }
        prepareForNewGame()
        updateButtonsFrames()
        hideResults()
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  let nav = segue.destination as? UINavigationController,
            let svc = nav.topViewController as? SettingsTableViewController {
            svc.delegate = self
            
            svc.userInterfaceColor = userInterfaceColor
            
            svc.shuffleNumbersMode = game.shuffleNumbersMode
            svc.colorfulNumbersMode = game.colorfulNumbersMode
            svc.winkNumbersMode = game.winkNumbersMode

            svc.colorfulCellsMode = game.colorfulCellsMode
            svc.shuffleColorsMode = game.shuffleColorsMode
            svc.winkColorsMode = game.winkColorsMode
            
            svc.level = game.level
            svc.maxNumber = game.maxNumber
            
            svc.maxLevel = game.maxLevel
            svc.minLevel = game.minLevel
            svc.maxPossibleNumber = game.maxPossibleNumber
            svc.minPossibleNumber = game.minPossibleNumber
        }
    }
    
    // MARK: - Haptic Feedback
    
    private enum FeedbackGenerator {
        case notificationFeedbackGenerator
        case impactFeedbackGenerator
    }
    
    private var notificationFeedbackGenerator: UINotificationFeedbackGenerator? = nil
    private var impactFeedbackGenerator: UIImpactFeedbackGenerator? = nil
    
    private func playNotificationHapticFeedback(notificationFeedbackType: UINotificationFeedbackType) {
        if UIDevice.current.hasHapticFeedback {
            notificationFeedbackGenerator = UINotificationFeedbackGenerator()
            notificationFeedbackGenerator?.notificationOccurred(notificationFeedbackType)
        } else if UIDevice.current.hasTapticEngine, notificationFeedbackType == .error {
            let cancelled = SystemSoundID(1521)
            AudioServicesPlaySystemSound(cancelled)
        } else if notificationFeedbackType == .error {
            let cancelled = SystemSoundID(kSystemSoundID_Vibrate)
            AudioServicesPlaySystemSound(cancelled)
        }
        notificationFeedbackGenerator = nil
    }
    
    private func playImpactHapticFeedback(needsToPrepare: Bool, style: UIImpactFeedbackStyle) {
        if UIDevice.current.hasHapticFeedback {
            impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style)
            impactFeedbackGenerator?.impactOccurred()
            if needsToPrepare {
                impactFeedbackGenerator?.prepare()
            }
        } else if UIDevice.current.hasTapticEngine {
            let peek = SystemSoundID(1519)
            AudioServicesPlaySystemSound(peek)
        }
    }
    
}


