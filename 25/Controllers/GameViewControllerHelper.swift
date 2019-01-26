//
//  GameViewControllerHelper.swift
//  25
//
//  Created by Ruslan Gritsenko on 22.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation

extension GameViewController: CLLocationManagerDelegate {
    
    var cellsContainerViewFrame: CGRect {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let bottomGap = tipsLabel?.frame.height ?? 0.0
        
        let minY = statusBarHeight + appearance.gridInset
        let maxY = screenHeight - bottomGap - appearance.gridInset
        let maxAlllowedHeight = maxY - minY
        
        let expectedHeight = screenWidth / CGFloat(game.colums) * CGFloat(game.rows)
        let expectedMinY = screenHeight / 2 - expectedHeight / 2
        let expectedMaxY = screenHeight / 2 + expectedHeight / 2
        
        let width = screenWidth - appearance.gridInset * 2
        var height: CGFloat {
            return expectedHeight < maxAlllowedHeight ? expectedHeight : maxAlllowedHeight
        }
        
        let x = appearance.gridInset
        var y: CGFloat {
            if expectedHeight < maxAlllowedHeight {
                if expectedMinY < minY && expectedMaxY < maxY {
                    return minY
                } else if expectedMinY > minY && expectedMaxY > maxY {
                    return expectedMinY - (expectedMaxY - maxY)
                } else {
                    return expectedMinY
                }
            } else {
                return minY
            }
        }
        
        return CGRect(
            x: x,
            y: y,
            width: width,
            height: height
        )
    }
    
    internal var messageViewWidth: CGFloat {
        if let cell = cells.first {
            let width = cell.bounds.width * 3 - appearance.gridInset * 2 + 1
            return width
        }
        return 0.0
    }
    
    internal var messageViewHeight: CGFloat {
        if let cellHeight = buttonHeight {
            let height = cells.count % 10 == 0 ? cellHeight * 2 - appearance.gridInset * 2 + 1 :
                                                 cellHeight - appearance.gridInset * 2 + 1
            return height
        }
        return 0.0
    }
    
    // MARK: - Cells
    
    func updateCellFrames(animated: Bool, completion: (() -> Void)? = nil) {
        /// Updates cell contariner view frame
        updateCellContainerViewFrame(animated: animated) {
            guard let completion = completion else { return }
            completion()
        }
        
        /// Updates cell frames
        for i in cells.indices {
            let cell = cells[i]
            if let cellFrame = grid[i] { // Gets new frame
                if animated {
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.2,
                        delay: 0.0,
                        options: .curveEaseInOut,
                        animations: {
                            cell.frame = cellFrame
                    }) { (position) in
                        if position == .end {
                            if cell.alpha < 1.0 {
                                UIViewPropertyAnimator.runningPropertyAnimator(
                                    withDuration: 0.7,
                                    delay: 0.0,
                                    options: .curveEaseInOut,
                                    animations: {
                                        cell.alpha = 1.0
                                })
                            }
                        }
                    }
                } else {
                    cell.frame = cellFrame
                    if cell.alpha < 1.0 {
                        cell.alpha = 1.0
                    }
                    
                }
            }
        }
    }
    
    func updateCellContainerViewFrame(animated: Bool, completion: (() -> Void)? = nil) {
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.5,
                delay: 0.0,
                options: .curveEaseInOut,
                animations: {
                    self.cellsContainerView.frame = self.cellsContainerViewFrame
            }) { (position) in
                guard let completion = completion else { return }
                completion()
            }
        } else {
            cellsContainerView.frame = cellsContainerViewFrame
        }
    }
    
    func addCells(count: Int) {
        assert(count % 5 == 0, "Reason: invalid number of buttons to add. Provide a multiple of five number.")
        for _ in 0..<count {
            let cell: CellView = {
                let cell = CellView(frame: CGRect.zero, inset: appearance.gridInset)
                let backgroundColor = self.game.colorfulCellsMode ? appearance.randomColor : appearance.defaultCellsColor
                guard let numberColor = self.game.colorfulNumbersMode ? appearance.getAnotherColor(for: backgroundColor) : appearance.defaultNumbersColor else { return CellView() }
                cell.setBackgroundColor(to: backgroundColor, animated: false)
                cell.setNumberColor(to: numberColor, animated: false)
                cell.setCornerRadius(to: appearance.cornerRadius)
                cell.alpha = 0.0
                cell.titleLabel?.font = UIFont.systemFont(ofSize: appearance.numbersFontSize)
                cell.addTarget(self, action: #selector(cellPressed(sender:)), for: .touchDown)
                cell.addTarget(self, action: #selector(cellReleased(sender:)), for: .touchUpInside)
                cell.addTarget(self, action: #selector(cellReleased(sender:)), for: .touchUpOutside)
                return cell
            }()
            cells.append(cell)
            cellsContainerView.addSubview(cell)
        }
    }
    
    func removeCells(count: Int, animated: Bool) {
        assert(count % 5 == 0, "Reason: invalid number of buttons to remove. Provide a multiple of five number.")
        for _ in 0..<count {
            let lastCell = cells.last
            if let lastCell = lastCell {
                if animated {
                    lastCell.hideNumber(animated: false)
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.5,
                        delay: 0.0,
                        options: .curveEaseInOut,
                        animations: {
                            lastCell.alpha = 0.0
                    }) { (position) in
                        if position == .end {
                            lastCell.removeFromSuperview()
                        }
                    }
                } else {
                    lastCell.removeFromSuperview()
                }
            }
            cells.removeLast()
        }
    }
    
    internal func updateCellsCount(animated: Bool, completion: (() -> Void)? = nil) {
        /// Adds/removes cells
        if cells.count < game.maxNumber {
            addCells(count: game.maxNumber - cells.count)
        } else {
            removeCells(count: cells.count - game.maxNumber, animated: animated)
        }
        
        /// Changes cells position
        updateCellFrames(animated: animated) {
            guard let completion = completion else { return }
            completion()
        }
        
        /// Sets cell numbers
        setNumbers(animated: false)
        hideNumbers(animated: false)
        
        /// Changes message view position
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
                self.startGameView.bounds.size = CGSize(width: self.messageViewWidth, height: self.messageViewHeight)
                self.startGameView.center = self.cellsContainerView.center
        })
    }
    
    // MARK: - Numbers
    
    func setNumbers(animated: Bool) {
        for i in cells.indices {
            let number = game.numbers[i]
            let cell = cells[i]
            cell.setNumber(number, animated: animated)
        }
    }
    
    func hideNumbers(animated: Bool) {
        for cell in cells {
            cell.hideNumber(animated: animated)
        }
    }
    
    func swapNumbers(animated: Bool) {
        if cellsNotAnimating.isEmpty { return }
        
        let cell1 = cellsNotAnimating[cellsNotAnimating.count.arc4random]
        guard let index1 = cellsNotAnimating.index(of: cell1) else { return }
        cellsNotAnimating.remove(at: index1)
        
        let cell2 = cellsNotAnimating[cellsNotAnimating.count.arc4random]
        guard let index2 = cellsNotAnimating.index(of: cell2) else { return }
        cellsNotAnimating.remove(at: index2)
        
        let number1 = cell1.tag
        let number2 = cell2.tag
        
        if animated {
            let duration = 1.0
            let delayIn = 0.0
            let delayOut = 0.0
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: duration / 2,
                delay: delayIn,
                options: .curveEaseInOut,
                animations: {
                    cell1.titleLabel?.alpha = 0.0
                    cell2.titleLabel?.alpha = 0.0
            }) { (_) in
                if self.game.inGame {
                    cell1.setTitle(String(number2), for: .normal)
                    cell2.setTitle(String(number1), for: .normal)
                    cell1.tag = number2
                    cell2.tag = number1
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: duration / 2,
                        delay: delayOut,
                        options: .curveEaseInOut,
                        animations: {
                            cell1.titleLabel?.alpha = 1.0
                            cell2.titleLabel?.alpha = 1.0
                    }) { (_) in
                        if self.game.inGame {
                            self.cellsNotAnimating.append(cell1)
                            self.cellsNotAnimating.append(cell2)
                        }
                    }
                }
            }
        }
    }
    
    internal func winkRandomNumber() {
        if cellsNotAnimating.isEmpty { return }
        
        let cell = cellsNotAnimating[cellsNotAnimating.count.arc4random]
        
        if let index = cellsNotAnimating.index(of: cell) {
            cellsNotAnimating.remove(at: index)
        }
        
        cell.winkNumber() {
            self.cellsNotAnimating.append(cell)
        }
    }
    
    // MARK: - Colors
    
    func setCellsColorsToDefault(animated: Bool) {
        cells.forEach({ (cell) in
            cell.setBackgroundColor(to: appearance.defaultCellsColor, animated: animated)
        })
    }
    
    func setNumbersColorsToDefault(animated: Bool) {
        cells.forEach({ (cell) in
            cell.setNumberColor(to: appearance.defaultNumbersColor, animated: animated)
        })
    }
    
    func updateCellsColorsFromModel() {
        for cell in cells {
            let cellBackgroundColor = game.colorfulCellsMode ? appearance.randomColor : appearance.defaultCellsColor
            guard let cellNumberColor: UIColor = {
                if game.colorfulNumbersMode {
                    return appearance.getAnotherColor(for: cellBackgroundColor)
                } else if game.colorfulCellsMode {
                    return .white
                } else {
                    return appearance.defaultNumbersColor
                }
            }() else { return }
            
            cell.setBackgroundColor(to: cellBackgroundColor, animated: true)
            cell.setNumberColor(to: cellNumberColor, animated: true)
        }
    }
    
    internal func prepareForColorfulCellsMode() {
        startGameView.titleLabel.textColor = game.colorfulCellsMode ? .white : appearance.textColor
        startGameView.detailLabel.textColor = game.colorfulCellsMode ? .white : appearance.textColor
        updateCellsColorsFromModel()
    }
    
    // MARK: - Helping Methods
    
    @objc internal func startGame() {
        startGameView.hide()
        
        let needsToShowTip = stopGameEventConunter <= necessaryNumberOfEvents
        tipsLabel?.setText(needsToShowTip ? Strings.SwipeDownTipLabelText : nil, animated: true)
        
        feedbackGenerator.playSelectionHapticFeedback()
        
        self.statusBarIsHidden = true
        
        if resultsIsShowing {
            resultsView.hide()
            resultsIsShowing = false
        }
        
        if game.colorfulCellsMode {
            updateCellsColorsFromModel()
        }
        
        for cell in cells {
            cell.isEnabled = true
            cell.showNumber(animated: true)
        }
        
        game.startGame()
        
        if game.winkNumbersMode {
            winkNumberTimer = Timer.scheduledTimer(
                timeInterval: TimeInterval(3.5 / Double(game.maxNumber)),
                target: self,
                selector: #selector(timerSceduled),
                userInfo: nil,
                repeats: true
            )
        }
        if game.swapNumbersMode {
            swapNumberTimer = Timer.scheduledTimer(
                timeInterval: TimeInterval(5.0 / Double(game.maxNumber)),
                target: self,
                selector: #selector(timerSceduled),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    /// Counts count of stop game events (needed for tips) and makes all needed prerapations for new game
    func stopGame() {
        stopGameEventConunter += 1
        prepareForNewGame()
    }
    
    /// Ends the game without preparations for the new one
    func endGame(levelPassed: Bool) {
        /// Says to the model to finish game
        self.game.finishGame()
        
        /// Stops all cell animations (e.g. wink, swap)
        stopAnimations()
        
        /// Hides cell numbers and diables all cells
        for cell in cells {
            cell.hideNumber(animated: true)
        }
        
        if game.infinityMode {
            self.view.addSubview(resultsView)
            resultsIsShowing = true
            resultsView.show(score: game.infinityModeScore)
            
            /// Plays vibration feedback
            feedbackGenerator.playVibrationFeedback()
        } else if levelPassed {
            if game.level == game.maxLevel {
                let title = "Поздравляю! 🎂"
                let text = "Вы смогли пройти все \(game.maxLevel) уровней! Отличная работа!"
                
                self.view.addSubview(messageView)
                resultsIsShowing = true
                messageView.show(title: title, text: text)
            } else {
                /// Shows results with result time
                guard let time = game.elapsedTime else { return }
                let timeWithFine = time + game.fine
                let difference = game.goal - timeWithFine
                
                self.view.addSubview(resultsView)
                resultsIsShowing = true
                resultsView.show(withTime: timeWithFine, goal: game.goal, difference: difference, fine: game.fine)
            }

            /// Plays 'success' haptic feedback
            feedbackGenerator.playNotificationHapticFeedback(notificationFeedbackType: .success)

            /// Says to the model to open next level
            game.openNextLevel()
            game.changeLevel()
        } else {
            /// Shows results
            self.view.addSubview(resultsView)
            resultsIsShowing = true
            resultsView.show(goal: game.goal, fine: game.fine)
            
            /// Plays vibration feedback
            feedbackGenerator.playVibrationFeedback()
        }
        
        lastPressedCell?.uncompress(hiddenNumber: true)
    }
    
    /// Makes all needed prerapations for new game
    func prepareForNewGame() {
        /// Says to the model to set new game
        self.game.newGame()
        
        /// Stops all cell animations (e.g. wink, swap)
        stopAnimations()
        
        /// Sets all cells as 'without animations'
        cellsNotAnimating = cells
        
        /// Sets numbers according to the model
        setNumbers(animated: false)
        
        /// Hides numbers
        hideNumbers(animated: false)
        
        /// Shows 'how to open settings' tip if user has opened setting less then necessary
        let needsToShowTip = showSettingsEventCounter <= necessaryNumberOfEvents
        tipsLabel?.setText(needsToShowTip ? Strings.SwipeUpTipLabelText : nil, animated: true)
        
        /// Shows message view
        self.view.addSubview(startGameView)
        startGameView.show()
        
        /// Shows status bar
        self.statusBarIsHidden = false
        
        /// Hides Time Label
        self.timeLabel.stopAnimation()
        self.timeLabel.alpha = 0.0
    }
    
    /// Stops all cell animations (e.g. wink, swap)
    func stopAnimations() {
        /// Prevents subsequent animations
        winkNumberTimer.invalidate()
        swapNumberTimer.invalidate()
        
        /// Stops current animations and performs any completion tasks
        for cell in cells {
            cell.winkPhase = nil
            if cell.disappearingWinkAnimator.state == .stopped {
                cell.disappearingWinkAnimator.finishAnimation(at: .end)
            } else {
                cell.disappearingWinkAnimator.stopAnimation(true)
            }
            if cell.appearingWinkAnimator.state == .stopped {
                cell.appearingWinkAnimator.finishAnimation(at: .end)
            } else {
                cell.appearingWinkAnimator.stopAnimation(true)
            }
            if cell.setAnimator.state == .stopped {
                cell.setAnimator.finishAnimation(at: .end)
            } else {
                cell.setAnimator.stopAnimation(true)
            }
            cell.titleLabel?.layer.removeAllAnimations()
        }
    }
    
    /// Performs periodic animations
    @objc func timerSceduled() {
        /// Winks random number in the appropriate mode
        if game.winkNumbersMode {
            winkRandomNumber()
        }
        
        /// Swaps random numbers in the appropriate mode
        if game.swapNumbersMode {
            swapNumbers(animated: true)
        }
    }
    
}
