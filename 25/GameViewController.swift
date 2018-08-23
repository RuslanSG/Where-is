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
    
    private lazy var game = Game()
    
    private lazy var grid = Grid(layout: .dimensions(rowCount: game.rows, columnCount: game.colums), frame: buttonsFieldFrame)
    private var buttons = [UIButton]()
    
    private let colorSets = [[#colorLiteral(red: 0.03137254902, green: 0.3058823529, blue: 0.4941176471, alpha: 1), #colorLiteral(red: 0.06666666667, green: 0.4823529412, blue: 0.462745098, alpha: 1), #colorLiteral(red: 0.05098039216, green: 0.4392156863, blue: 0.05882352941, alpha: 1)],
                             [#colorLiteral(red: 0.9921568627, green: 0.5764705882, blue: 0.1490196078, alpha: 1), #colorLiteral(red: 0.7019607843, green: 0.1019607843, blue: 0.06274509804, alpha: 1), #colorLiteral(red: 0.5921568627, green: 0.1176470588, blue: 0.368627451, alpha: 1)]]
    private lazy var randomColorSet = colorSets[colorSets.count.arc4random]
    private var randomColor: UIColor {
        let randomColor = randomColorSet[randomColorSet.count.arc4random]
        return randomColor
    }
    private lazy var userInterfaceColor = randomColor
    
    private var timer = Timer()
    private var animator = UIViewPropertyAnimator()
    
    override func viewDidLoad() {
        startButton.backgroundColor = userInterfaceColor
        newGameButton.tintColor = userInterfaceColor
        settingsButton.tintColor = userInterfaceColor
        addButtons(count: game.numbers.count)
        updateViewFromModel()
    }
    
    // MARK: - Actions
    
    @objc private func buttonPressed(sender: UIButton) {
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
    
    // MARK: - UI Management
    
    private var isNewGame = true
    
    private func updateViewFromModel() {
        for i in buttons.indices {
            let button = buttons[i]
            if let viewFrame = grid[i]?.insetBy(dx: 2.0, dy: 2.0) {
                button.frame = viewFrame
            }
            if isNewGame {
                setNumbers()
            }
        }
        isNewGame = false
    }
    
    // MARK: - SettingsTableViewControllerDelegate
    
    func colorfulCellsModeStateChanged(to state: Bool) {
        game.colorfulCellsMode = state
        if state == true {
            buttons.forEach { $0.backgroundColor = randomColor }
        } else {
            buttons.forEach { $0.backgroundColor = .lightGray }
        }
    }
    
    func levelChanged(to level: Int) {
        game.level = level
        if level == 0 {
            removeColors(animated: false)
        } else if level > 0 {
            shuffleColors(animated: false)
        }
    }
    
    func maxNumberChanged(to maxNumber: Int) {
        if buttons.count < maxNumber {
            game.rows += 1
            addButtons(count: maxNumber - buttons.count)
            grid = Grid(layout: .dimensions(rowCount: game.rows, columnCount: game.colums), frame: buttonsFieldFrame)
            prepareForNewGame()
        }
    }
    
    func shuffleColorsModeStateChanged(to state: Bool) {
        game.shuffleColorsMode = state
    }
    
    func shuffleNumbersModeStateChanged(to state: Bool) {
        game.shuffleNumbersMode = state
    }
    
    func winkModeStateChanged(to state: Bool) {
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
            svc.maxPossibleNumber = game.maxPossibleNumber
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
    
    // MARK: - Helping Methods
    
    private func showMessage(on label: UILabel, text: String, disappear: Bool = true) {
        label.text = text
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: 0.0,
            options: [],
            animations: {
                label.alpha = 1.0
        }) { (position) in
            if disappear {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.2,
                    delay: 0.5,
                    options: [],
                    animations: {
                        label.alpha = 0.0
                })
            }
        }
    }
    
    private func addButtons(count: Int) {
        assert(count % 5 == 0, "Reason: invalid number of buttons to add. Provide a multiple of five number.")
        for _ in 0..<count {
            let button: UIButton = {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                button.titleLabel?.font = UIFont.systemFont(ofSize: 35)
                button.titleLabel?.alpha = 0.0
                button.backgroundColor = game.colorfulCellsMode ? randomColor : .lightGray
                button.layer.cornerRadius = 5
                button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchDown)
                button.isEnabled = false
                return button
            }()
            buttons.append(button)
            view.addSubview(button)
        }
    }
    
//    private func removeButtons(count: Int) {
//        assert(count % 5 == 0, "Reason: invalid number of buttons to remove. Provide a multiple of five number.")
//        for i in 0..<count {
//
//            buttons.removeLast()
//
//        }
//    }
    
    private func showNumbers(animated: Bool) {
        buttons.forEach({ (button) in
            button.isEnabled = true
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.2,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.titleLabel?.alpha = 1.0
                })
            } else {
                button.titleLabel?.alpha = 1.0
            }
        })
    }
    
    private func hideNumbers(animated: Bool) {
        buttons.forEach({ (button) in
            button.isEnabled = false
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.2,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.titleLabel?.alpha = 0.0
                })
            } else {
                button.titleLabel?.alpha = 0.0
            }
        })
    }
    
    private func setNumbers() {
        for i in buttons.indices {
            let number = game.numbers[i]
            let button = buttons[i]
            button.setTitle(String(number), for: .normal)
            button.tag = number
        }
    }
    
    private func updateNumbers(animated: Bool) {
        for i in buttons.indices {
            let number = game.numbers[i]
            let button = buttons[i]
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.titleLabel?.alpha = 0.0
                }) { (position) in
                    button.setTitle(String(number), for: .normal)
                    button.tag = number
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.1,
                        delay: 0.0,
                        options: [],
                        animations: {
                            button.titleLabel?.alpha = 1.0
                    })
                }
            } else {
                button.setTitle(String(number), for: .normal)
                button.tag = number
            }
        }
    }
    
    private func removeColors(animated: Bool) {
        buttons.forEach({ (button) in
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.backgroundColor = .lightGray
                })
            } else {
                button.backgroundColor = .lightGray
            }
        })
    }
    
    private func shuffleColors(animated: Bool) {
        buttons.forEach({ (button) in
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.backgroundColor = self.randomColor
                })
            } else {
                button.backgroundColor = randomColor
            }
        })
    }
    
    private func prepareForNewGame(hideMessageLabel: Bool = true) {
        game.newGame()
        isNewGame = true
        hideNumbers(animated: false)
        if hideMessageLabel {
            label.text = nil
        }
        if game.colorfulCellsMode {
            shuffleColors(animated: true)
        }
        updateViewFromModel()
    }
    
    @objc private func winkNumbers() {
        if game.inGame {
            let button = buttons[buttons.count.arc4random]
            print("wink \(button.titleLabel!.text!)")
            winkNumber(at: button)
        } else {
            timer.invalidate()
            animator.stopAnimation(false)
            animator.finishAnimation(at: .end)
            animator.stopAnimation(false)
            animator.finishAnimation(at: .start)
        }
    }
    
    private func winkNumber(at button: UIButton) {
        animator = UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.3,
            delay: 0.0,
            options: [],
            animations: {
                button.titleLabel?.alpha = 0.0
        }) { (position) in
            self.animator = UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.3,
                delay: 1.0,
                options: [],
                animations: {
                    button.titleLabel?.alpha = 1.0
            })
        }
    }
    
}


