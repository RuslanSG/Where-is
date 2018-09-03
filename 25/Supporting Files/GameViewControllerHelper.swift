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
    
    var cornerRadius: CGFloat {
        if  self.view.traitCollection.horizontalSizeClass == .regular,
            self.view.traitCollection.verticalSizeClass == .regular {
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
    
    var buttonsFieldFrame: CGRect {
        let height = self.view.bounds.width / CGFloat(game.colums) * CGFloat(game.rows)
        let pointY = self.view.bounds.midY - height / 2
        let staturBarHeight = UIApplication.shared.statusBarFrame.height
        let newGameButtonFrameY = newGameButton.frame.minY
        let maxAlllowedButtonsContainerViewHeight = newGameButtonFrameY - staturBarHeight - gridInset
        return CGRect(
            x: gridInset,
            y: pointY > 0 ? pointY : staturBarHeight,
            width: self.view.bounds.width - gridInset * 2,
            height: height < maxAlllowedButtonsContainerViewHeight ? height : maxAlllowedButtonsContainerViewHeight
        )
    }
    
    // MARK: - Cells
    
    func updateButtonsFrames() {
        for i in buttons.indices {
            let button = buttons[i]
            if let viewFrame = grid[i]?.insetBy(dx: gridInset, dy: gridInset) {
                button.frame = viewFrame
            }
        }
    }
    
    func feedbackSelection(isRight: Bool) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.1,
            delay: 0.0,
            options: [],
            animations: {
                self.feedbackView.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.1490196078, blue: 0.1215686275, alpha: 1)
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
                button.titleLabel?.font = UIFont.systemFont(ofSize: numbersFontSize)
                button.titleLabel?.alpha = 0.0
                button.backgroundColor = game.colorfulCellsMode ? randomColor : defaultCellsColor
                button.setTitleColor(defaultNumbersColor, for: .normal)
                button.layer.cornerRadius = cornerRadius
                button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchDown)
                button.addTarget(self, action: #selector(buttonResign(sender:)), for: .touchUpInside)
                return button
            }()
            buttons.append(button)
            buttonsContainerView.addSubview(button)
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
    
    func compressButton(_ button: UIButton) {
        buttonFrameX = button.frame.minX
        buttonFrameY = button.frame.minY
        buttonFrameWidth = button.frame.width
        buttonFrameHeight = button.frame.height
        
        let newButtonFrameX = button.frame.minX + button.frame.width * CGFloat(1 - compressionRatio) / 2
        let newButtonFrameY = button.frame.minY + button.frame.height * CGFloat(1 - compressionRatio) / 2
        let newButtonFrameWidth = button.frame.width * CGFloat(compressionRatio)
        let newButtonFrameHeight = button.frame.height * CGFloat(compressionRatio)
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.05,
            delay: 0.0,
            options: [],
            animations: {
                button.frame = CGRect(
                    x: newButtonFrameX,
                    y: newButtonFrameY,
                    width: newButtonFrameWidth,
                    height: newButtonFrameHeight
                )
        })
    }
    
    func uncompressButton(_ button: UIButton) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.3,
            delay: 0.0,
            options: [],
            animations: {
                button.frame = CGRect(
                    x: self.buttonFrameX,
                    y: self.buttonFrameY,
                    width: self.buttonFrameWidth,
                    height: self.buttonFrameHeight
                )
        })
    }
    
    // MARK: - Numbers
    
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
    
    // MARK: - Colors
    
    func shuffleCellColors(animated: Bool) {
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
    
    func removeCellColors(animated: Bool) {
        buttons.forEach({ (button) in
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.backgroundColor = self.defaultCellsColor
                })
            } else {
                button.backgroundColor = defaultCellsColor
            }
        })
    }
    
    func winkCellColor(at button: UIButton) {
        let colorSet = randomColorSet.map { darkMode ? $0.dark : $0.light }
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0.0,
            options: [],
            animations: {
                if let color = self.getAnotherColor(for: button, from: colorSet) {
                    button.backgroundColor = color
                }
        })
    }
    
    func shuffleNumberColors(animated: Bool) {
        let colorSet = randomColorSet.map { darkMode ? $0.dark : $0.light }
        buttons.forEach({ (button) in
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.setTitleColor(self.getAnotherColor(for: button, from: colorSet), for: .normal)
                })
            } else {
                button.setTitleColor(getAnotherColor(for: button, from: colorSet), for: .normal)
            }
        })
    }
    
    func removeNumberColors(animated: Bool) {
        buttons.forEach({ (button) in
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.setTitleColor(self.defaultNumbersColor, for: .normal)
                })
            } else {
                button.setTitleColor(self.defaultNumbersColor, for: .normal)
            }
        })
    }
    
    // MARK: - Results
    
    func showResults(time: Double, maxNumber: Int, level: Int) {
        resultsView.titleLabel.text = time < 60.0 ? "Excellent!" : "Almost there!"
        resultsView.timeLabel.text = String(format: "%.02f", time)
        self.view.bringSubview(toFront: resultsView)
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.15,
            delay: 0.0,
            options: [],
            animations: {
                self.resultsView.alpha = 1.0
        })
    }
    
    func hideResults() {
        resultsView.titleLabel.text = nil
        resultsView.timeLabel.text = nil
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.15,
            delay: 0.0,
            options: [],
            animations: {
                self.resultsView.alpha = 0.0
        })
    }
    
    // MARK: - Helping Methods
    
    func prepareForNewGame(hideMessageLabel: Bool = true) {
        game.newGame()
        setNumbers()
        gameFinished = true
        if game.colorfulCellsMode {
            shuffleCellColors(animated: true)
        }
        if game.colorfulNumbersMode {
            shuffleNumberColors(animated: true)
        }
        if game.winkNumbersMode || game.winkColorsMode {
            timer.invalidate()
            buttons.forEach { $0.titleLabel?.layer.removeAllAnimations() }
        }
        hideNumbers(animated: false)
    }
    
    func getAnotherColor(for button: UIButton, from colorSet: [UIColor]) -> UIColor? {
        let buttonColor = button.backgroundColor
        var otherColors = colorSet
        if let buttonColor = buttonColor {
            let index = otherColors.index(of: buttonColor)
            if let index = index {
                otherColors.remove(at: index)
                return otherColors[otherColors.count.arc4random]
            }
        }
        return nil
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
            winkCellColor(at: button)
        }
    }

}
