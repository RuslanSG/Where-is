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
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    private var buttonsFieldFrame: CGRect {
        let height = view.bounds.width / CGFloat(game.colums) * CGFloat(game.rows)
        let pointY = view.bounds.midY - height / 2 - 38
        return CGRect(x: 0.0, y: pointY, width: view.bounds.width, height: height)
    }
    
    lazy var game = Game()
    
    var grid: Grid {
        return Grid(layout: .dimensions(rowCount: game.rows, columnCount: game.colums), frame: buttonsFieldFrame)
    }
    var buttons = [UIButton]()
    
    private let colorSets = [[#colorLiteral(red: 0.03137254902, green: 0.3058823529, blue: 0.4941176471, alpha: 1), #colorLiteral(red: 0.06666666667, green: 0.4823529412, blue: 0.462745098, alpha: 1), #colorLiteral(red: 0.05098039216, green: 0.4392156863, blue: 0.05882352941, alpha: 1)],
                             [#colorLiteral(red: 0.9921568627, green: 0.5764705882, blue: 0.1490196078, alpha: 1), #colorLiteral(red: 0.7019607843, green: 0.1019607843, blue: 0.06274509804, alpha: 1), #colorLiteral(red: 0.5921568627, green: 0.1176470588, blue: 0.368627451, alpha: 1)]]
    private lazy var randomColorSet = colorSets[colorSets.count.arc4random]
    var randomColor: UIColor {
        let randomColor = randomColorSet[randomColorSet.count.arc4random]
        return randomColor
    }
    private lazy var userInterfaceColor = randomColor
    
    var timer = Timer()
    
    override func viewDidLoad() {
        startButton.backgroundColor = userInterfaceColor
        newGameButton.tintColor = userInterfaceColor
        settingsButton.tintColor = userInterfaceColor
        addButtons(count: game.numbers.count)
        prepareForNewGame()
        updateButtonsFrames()
    }
    
    // MARK: - Actions
    
    @objc func buttonPressed(sender: UIButton) {
        if game.nextNumberToTap < game.maxNumber {
            let selectedNumberIsRight = game.selectedNumberIsRight(sender.tag)
            game.numberSelected(sender.tag)
            if selectedNumberIsRight {
                // User tapped the right number
                showMessage(on: self.label, text: "Good!")
                playImpactHapticFeedback(needsToPrepare: true, style: .medium)
            } else {
                // User tapped the wrong number
                showMessage(on: self.label, text: "Miss!")
                playNotificationHapticFeedback(notificationFeedbackType: .error)
            }
            if game.shuffleNumbersMode {
                game.shuffleNumbers()
                updateNumbers(animated: true)
            } else {
                sender.titleLabel?.alpha = 0.2
            }
            if game.shuffleColorsMode {
                shuffleColors(animated: true)
            }
        } else {
            // User tapped the last number
            game.finishGame()
            showMessage(on: label, text: String(format: "%.02f", game.elapsedTime), disappear: false)
            prepareForNewGame(hideMessageLabel: false)
            playNotificationHapticFeedback(notificationFeedbackType: .success)
        }
    }
    
    @objc func buttonResign(sender: UIButton) {
        if sender.tag < game.maxNumber, !game.shuffleNumbersMode {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.2,
                delay: 0.0,
                options: [],
                animations: {
                    sender.titleLabel?.alpha = 1.0
            })
        }
    }
    
    @IBAction func startButtonPressed(sender: UIButton) {
        showNumbers(animated: true)
        label.text = nil
        game.startGame()
        
        impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator?.prepare()
        
        if game.winkMode {
            timer = Timer.scheduledTimer(
                timeInterval: 0.2,
                target: self,
                selector: #selector(winkNumbers),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    @IBAction func newGameButtonPressed(sender: UIButton) {
        prepareForNewGame()
    }
    
    // MARK: - SettingsTableViewControllerDelegate
    
    func colorfulCellsModeStateChanged(to state: Bool) {
        prepareForNewGame()
        game.colorfulCellsMode = state
        if state == true {
            buttons.forEach { $0.backgroundColor = randomColor }
        } else {
            buttons.forEach { $0.backgroundColor = .lightGray }
        }
    }
    
    func levelChanged(to level: Int) {
        prepareForNewGame()
        game.level = level
        if level == game.minLevel {
            removeColors(animated: false)
        } else if level > game.minLevel {
            shuffleColors(animated: false)
        }
    }
    
    func maxNumberChanged(to maxNumber: Int) {
        prepareForNewGame()
        if buttons.count < maxNumber {
            game.rows += 1
            addButtons(count: maxNumber - buttons.count)
        } else {
            game.rows -= 1
            removeButtons(count: buttons.count - maxNumber)
        }
        updateButtonsFrames()
    }
    
    func shuffleColorsModeStateChanged(to state: Bool) {
        prepareForNewGame()
        game.shuffleColorsMode = state
    }
    
    func shuffleNumbersModeStateChanged(to state: Bool) {
        game.shuffleNumbersMode = state
        prepareForNewGame()
    }
    
    func winkModeStateChanged(to state: Bool) {
        prepareForNewGame()
        game.winkMode = state
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let svc = nav.topViewController as? SettingsTableViewController {
            svc.delegate = self
            svc.userInterfaceColor = userInterfaceColor
            svc.colorfulCellsMode = game.colorfulCellsMode
            svc.shuffleColorsMode = game.shuffleColorsMode
            svc.shuffleNumbersMode = game.shuffleNumbersMode
            svc.winkMode = game.winkMode
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


