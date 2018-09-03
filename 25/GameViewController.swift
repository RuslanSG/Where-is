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
    
    lazy var resultsView: ResultsView = {
        let blur = UIBlurEffect(style: .light)
        let view = ResultsView(
            frame: self.view.frame,
            effect: blur,
            userInterfaceColor: userInterfaceColor,
            cornerRadius: cornerRadius,
            fontsColor: darkMode ? numbersColors.darkMode : numbersColors.lightMode
        )
        view.alpha = 0.0
        return view
    }()
        
    // MARK: -
    
    private let userDefaults = UserDefaults.standard
    private let darkModeKey = "darkMode"
    
    lazy var game = Game()
    var gameFinished = false {
        didSet {
            if gameFinished {
                self.view.bringSubview(toFront: resultsView)
            } else {
                self.view.sendSubview(toBack: resultsView)
            }
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
    
    var buttonFrameX: CGFloat!
    var buttonFrameY: CGFloat!
    var buttonFrameHeight: CGFloat!
    var buttonFrameWidth: CGFloat!
    
    var compressionRatio = 0.90
    
    var timer = Timer()
    
    // MARK: - Colors
    
    private let cellsColors     = (darkMode: #colorLiteral(red: 0.2203874684, green: 0.2203874684, blue: 0.2203874684, alpha: 1), lightMode: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    private let numbersColors   = (darkMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), lightMode: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    private let mainViewColors  = (darkMode: #colorLiteral(red: 0.09019607843, green: 0.09019607843, blue: 0.09019607843, alpha: 1), lightMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    
    private let colorSets = [[(light: #colorLiteral(red: 0.06666666667, green: 0.4666666667, blue: 0.7215686275, alpha: 1), dark: #colorLiteral(red: 0.03137254902, green: 0.3058823529, blue: 0.4941176471, alpha: 1)),
                              (light: #colorLiteral(red: 0.09803921569, green: 0.6588235294, blue: 0.6117647059, alpha: 1), dark: #colorLiteral(red: 0.06666666667, green: 0.4823529412, blue: 0.462745098, alpha: 1)),
                              (light: #colorLiteral(red: 0.1607843137, green: 0.6862745098, blue: 0.1137254902, alpha: 1), dark: #colorLiteral(red: 0.05098039216, green: 0.4392156863, blue: 0.05882352941, alpha: 1))],
                             
                             [(light: #colorLiteral(red: 0.968627451, green: 0.7254901961, blue: 0.168627451, alpha: 1), dark: #colorLiteral(red: 0.8057276114, green: 0.4694959764, blue: 0.1296572619, alpha: 1)),
                              (light: #colorLiteral(red: 0.9215686275, green: 0.1490196078, blue: 0.1215686275, alpha: 1), dark: #colorLiteral(red: 0.599486165, green: 0.08605109967, blue: 0.05797519395, alpha: 1)),
                              (light: #colorLiteral(red: 0.7882352941, green: 0.1843137255, blue: 0.4823529412, alpha: 1), dark: #colorLiteral(red: 0.5, green: 0.1014612427, blue: 0.3135548154, alpha: 1))],
                             
                             [(light: #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1), dark: #colorLiteral(red: 0.3025199942, green: 0.301058545, blue: 0.3039814435, alpha: 1)),
                              (light: #colorLiteral(red: 0.5787474513, green: 0.3215198815, blue: 0, alpha: 1), dark: #colorLiteral(red: 0.4634119638, green: 0.2628604885, blue: 0.05822089579, alpha: 1)),
                              (light: #colorLiteral(red: 0.5738074183, green: 0.5655357838, blue: 0, alpha: 1), dark: #colorLiteral(red: 0.4723546985, green: 0.4624517336, blue: 0.09191328908, alpha: 1))]]
    
    var defaultCellsColor: UIColor {
        return darkMode ? cellsColors.darkMode : cellsColors.lightMode
    }
    var defaultNumbersColor: UIColor {
        return darkMode || game.colorfulCellsMode ? numbersColors.darkMode : numbersColors.lightMode
    }
    var mainViewColor: UIColor {
        return darkMode ? mainViewColors.darkMode : mainViewColors.lightMode
    }

    lazy var randomColorSet = colorSets[colorSets.count.arc4random]

    var randomColor: UIColor {
        let randomColor = darkMode ? randomColorSet[randomColorSet.count.arc4random].dark :
                                     randomColorSet[randomColorSet.count.arc4random].light
        return randomColor
    }
    
    private var userInterfaceColor: UIColor! {
        didSet {
            newGameButton.tintColor = userInterfaceColor
            settingsButton.tintColor = userInterfaceColor
        }
    }
    
    var darkMode = false {
        didSet {
            self.view.backgroundColor = mainViewColor
            game.colorfulCellsMode ? shuffleCellColors(animated: false) : removeCellColors(animated: false)
            removeNumberColors(animated: false)
            UIApplication.shared.statusBarStyle = darkMode ? .lightContent : .default
            userInterfaceColor = randomColor
            
            resultsView.effect = darkMode ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
            resultsView.userInterfaceColor = userInterfaceColor
            resultsView.fontsColor = darkMode ? numbersColors.darkMode : numbersColors.lightMode
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        setupInputComponents()
        prepareForNewGame()
    }
    
    // MARK: - Setup UI
    
    func setupInputComponents() {
        userInterfaceColor = randomColor
        
        self.view.addSubview(resultsView)
        self.view.addSubview(feedbackView)
        self.view.addSubview(buttonsContainerView)
        
        addButtons(count: game.numbers.count)
        updateButtonsFrames()
        
        self.view.sendSubview(toBack: feedbackView)
        self.view.sendSubview(toBack: resultsView)
    }
    
    // MARK: - Actions
    
    @objc func buttonPressed(sender: UIButton) {
        if gameFinished {
            start()
            compressButton(sender)
            return
        }
        compressButton(sender)
        let selectedNumberIsRight = game.selectedNumberIsRight(sender.tag)
        if selectedNumberIsRight && sender.tag == game.maxNumber {
            // User tapped the last number
            game.finishGame()
            showResults(time: game.elapsedTime, maxNumber: game.maxNumber, level: game.level - 1)
            prepareForNewGame(hideMessageLabel: false)
            playNotificationHapticFeedback(notificationFeedbackType: .success)
            uncompressButton(sender)
            return
        }
        if selectedNumberIsRight {
            // User tapped the right number
            playImpactHapticFeedback(needsToPrepare: true, style: .medium)
        } else {
            // User tapped the wrong number
            feedbackSelection(isRight: false)
            playNotificationHapticFeedback(notificationFeedbackType: .error)
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
        game.numberSelected(sender.tag)
    }
    
    @objc func buttonResign(sender: UIButton) {
        if !gameFinished, !game.shuffleNumbersMode {
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
    
    internal func start() {
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
        removeNumberColors(animated: false)
        if state == false {
            removeCellColors(animated: false)
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
    }
    
    
    func darkModeStateChanged(to state: Bool) {
        darkMode = state
        prepareForNewGame()
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
            
            svc.darkMode = darkMode
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


