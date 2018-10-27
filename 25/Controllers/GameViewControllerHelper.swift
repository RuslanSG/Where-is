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
    
    func updateCellFrames(animated: Bool) {
        updateCellContainerViewFrame(animated: animated)
        for i in cells.indices {
            let cell = cells[i]
            if let cellFrame = grid[i] {
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
    
    func updateCellContainerViewFrame(animated: Bool) {
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.2,
                delay: 0.0,
                options: .curveEaseInOut,
                animations: {
                    self.cellsContainerView.frame = self.cellsContainerViewFrame
            })
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
    
    internal func updateCellsCount(animated: Bool) {
        // Adding/removing cells
        if cells.count < game.maxNumber {
            addCells(count: game.maxNumber - cells.count)
        } else {
            removeCells(count: cells.count - game.maxNumber, animated: animated)
        }
        
        // Change cells position
        updateCellFrames(animated: animated)
        
        // Set cell numbers
        setNumbers(animated: false, hidden: true)
        
        // Change message view position
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
                self.messageView.bounds.size = CGSize(width: self.messageViewWidth, height: self.messageViewHeight)
                self.messageView.center = self.cellsContainerView.center
        })
    }
    
    // MARK: - Numbers
    
    func setNumbers(animated: Bool, hidden: Bool = false) {
        for i in cells.indices {
            let number = game.numbers[i]
            let cell = cells[i]
            cell.setNumber(
                number,
                alpha: cell.titleLabel?.alpha ?? 1.0,
                hidden: hidden,
                animated: true
            )
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
        
        let duration = 1.0
        let delayIn = 0.0
        let delayOut = 0.0
        
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: duration / 2,
                delay: delayIn,
                options: [],
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
                        options: [],
                        animations: {
                            cell1.titleLabel?.alpha = 1.0
                            cell2.titleLabel?.alpha = 1.0
                    }) { (_) in
                        self.cellsNotAnimating.append(cell1)
                        self.cellsNotAnimating.append(cell2)
                    }
                } else {
                    self.cellsNotAnimating.append(cell1)
                    self.cellsNotAnimating.append(cell2)
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
        
        cell.winkNumber {
            self.cellsNotAnimating.append(cell)
            print(self.cellsNotAnimating.count)
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
        messageView.label.textColor = game.colorfulCellsMode ? .white : appearance.textColor
        updateCellsColorsFromModel()
    }
    
    // MARK: - Helping Methods
    
    @objc internal func startGame() {
        messageView.hide()
        
        let needsToShowTip = stopGameEventConunter <= requiredNumberOfEvents
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
    
    func stopGame() {
        stopGameEventConunter += 1
        if game.winkNumbersMode { cellsNotAnimating = cells }
        prepareForNewGame()
    }
    
    func prepareForNewGame() {
        stopAnimations()
        game.newGame()
        setNumbers(animated: false, hidden: true)
        cellsNotAnimating = cells
        
        for cell in cells {
            cell.hideNumber(animated: true)
            cell.isEnabled = false
        }
        
        let needsToShowTip = showSettingsEventCounter <= requiredNumberOfEvents
        tipsLabel?.setText(needsToShowTip ? Strings.SwipeUpTipLabelText : nil, animated: true)
        
        self.view.addSubview(messageView)
        messageView.show()

        self.view.bringSubviewToFront(resultsView)
        
        self.statusBarIsHidden = false
    }
    
    func stopAnimations() {
        winkNumberTimer.invalidate()
        swapNumberTimer.invalidate()
        for cell in cells {
            if cell.animator.state != .stopped {
                cell.animator.stopAnimation(true)
            } else {
                cell.animator.finishAnimation(at: .end)
            }
            cell.titleLabel?.layer.removeAllAnimations()
        }
        print("Cells not animating: \(cellsNotAnimating.count)")
    }
    
    @objc func timerSceduled() {
        // Winking random number if Wink Numbers Mode is on
        if game.winkNumbersMode {
            winkRandomNumber()
        }
        
        // Swaping random numbers if Swap Numbers Mode is on
        if game.swapNumbersMode {
            swapNumbers(animated: true)
        }
    }
    
}
