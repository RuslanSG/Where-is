//
//  GameViewControllerHelper.swift
//  25
//
//  Created by Ruslan Gritsenko on 22.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit
import QuartzCore

extension GameViewController {
    
    func updateButtonsFrames() {
        for i in buttons.indices {
            let button = buttons[i]
            if let viewFrame = grid[i]?.insetBy(dx: 2.0, dy: 2.0) {
                button.frame = viewFrame
            }
        }
    }
    
    func showResults(time: Double, maxNumber: Int, level: Int) {
        titleLabel.text = time < 60.0 ? "Excellent!" : "Almost there!"
        timeLabel.text = String(format: "%.02f", time)
        self.view.bringSubview(toFront: messageView)
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.15,
            delay: 0.0,
            options: [],
            animations: {
                self.messageView.alpha = 1.0
        })
    }
    
    func hideResults() {
        titleLabel.text = nil
        timeLabel.text = nil
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.15,
            delay: 0.0,
            options: [],
            animations: {
                self.messageView.alpha = 0.0
        })
    }
    
    func feedbackSelection(isRight: Bool) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.1,
            delay: 0.0,
            options: [],
            animations: {
                self.feedbackView.backgroundColor = isRight ? #colorLiteral(red: 0.3960784314, green: 0.8392156863, blue: 0.262745098, alpha: 1) : #colorLiteral(red: 0.9215686275, green: 0.1490196078, blue: 0.1215686275, alpha: 1)
        }) { (position) in
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.1,
                delay: 0.0,
                options: [],
                animations: {
                    self.feedbackView.backgroundColor = .clear
            })
        }
    }
    
    func addButtons(count: Int) {
        assert(count % 5 == 0, "Reason: invalid number of buttons to add. Provide a multiple of five number.")
        for _ in 0..<count {
            let button: UIButton = {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                button.titleLabel?.font = UIFont.systemFont(ofSize: 35)
                button.titleLabel?.alpha = 0.0
                button.backgroundColor = game.colorfulCellsMode ? randomColor : defaultCellColor
                button.layer.cornerRadius = 5
                button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchDown)
                button.addTarget(self, action: #selector(buttonResign(sender:)), for: .touchUpInside)
                button.isEnabled = false
                return button
            }()
            buttons.append(button)
            view.addSubview(button)
        }
    }
    
    func removeButtons(count: Int) {
        assert(count % 5 == 0, "Reason: invalid number of buttons to remove. Provide a multiple of five number.")
        for _ in 0..<count {
            let lastButton = buttons.last
            if let lastButton = lastButton {
                lastButton.removeFromSuperview()
            }
            buttons.removeLast()
        }
    }
    
    func showNumbers(animated: Bool) {
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
    
    func hideNumbers(animated: Bool) {
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
    
    func setNumbers() {
        for i in buttons.indices {
            let number = game.numbers[i]
            let button = buttons[i]
            button.setTitle(String(number), for: .normal)
            button.tag = number
        }
    }
    
    func updateNumbers(animated: Bool) {
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
    
    func removeColors(animated: Bool) {
        buttons.forEach({ (button) in
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.backgroundColor = self.defaultCellColor
                })
            } else {
                button.backgroundColor = defaultCellColor
            }
        })
    }
    
    func shuffleColors(animated: Bool) {
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
    
    func prepareForNewGame(hideMessageLabel: Bool = true) {
        game.newGame()
        setNumbers()
        gameFinished = true
        if game.colorfulCellsMode {
            shuffleColors(animated: true)
        }
        if game.winkNumbersMode || game.winkColorsMode {
            timer.invalidate()
            buttons.forEach { $0.titleLabel?.layer.removeAllAnimations() }
        }
        hideNumbers(animated: false)
    }
    
    enum CellPart {
        case number
        case color
    }
    
    @objc func timerSceduled() {
        if game.winkNumbersMode {
            wink(.number)
        }
        if game.winkColorsMode {
            wink(.color)
        }
    }
    
    func wink(_ cellPart: CellPart) {
        if cellPart == .number {
            let button = buttons[buttons.count.arc4random]
            winkNumber(at: button)
        }
        if cellPart == .color {
            let button = buttons[buttons.count.arc4random]
            winkColor(at: button)
        }
    }
    
    func winkNumber(at button: UIButton) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0.0,
            options: [],
            animations: {
                button.titleLabel?.alpha = 0.0
        }) { (position) in
            if self.game.inGame {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.5,
                    delay: 1.0,
                    options: [],
                    animations: {
                        button.titleLabel?.alpha = 1.0
                })
            }
        }
    }
    
    func winkColor(at button: UIButton) {
        let buttonColor = button.backgroundColor
        var otherColors = randomColorSet
        if let buttonColor = buttonColor {
            let index = otherColors.index(of: buttonColor)
            if let index = index {
                otherColors.remove(at: index)
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.5,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.backgroundColor = otherColors[otherColors.count.arc4random]
                })
            }
        }
    }
    
    func executionTimeInterval(block: () -> ()) -> CFTimeInterval {
        let start = CACurrentMediaTime()
        block();
        let end = CACurrentMediaTime()
        return end - start
    }

}
