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
    
    var buttonsContainerViewFrame: CGRect {
        #warning("Refactor this")
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let staturBarHeight = UIApplication.shared.statusBarFrame.height
        
        let minY = staturBarHeight + appearance.gridInset
        let maxY = screenHeight - appearance.gridInset
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
    
    func updateCellFrames() {
        for i in cells.indices {
            let cell = cells[i]
            if let cellFrame = grid[i] {
                cell.frame = cellFrame
            }
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
                cell.titleLabel?.font = UIFont.systemFont(ofSize: appearance.numbersFontSize)
                cell.addTarget(self, action: #selector(cellPressed(sender:)), for: .touchDown)
                cell.addTarget(self, action: #selector(cellReleased(sender:)), for: .touchUpInside)
                cell.addTarget(self, action: #selector(cellReleased(sender:)), for: .touchUpOutside)
                return cell
            }()
            cells.append(cell)
            cellsContainerView.addSubview(cell)
        }
        updateCellFrames()
    }
    
    func removeCells(count: Int) {
        assert(count % 5 == 0, "Reason: invalid number of buttons to remove. Provide a multiple of five number.")
        for _ in 0..<count {
            let lastCell = cells.last
            if let lastCell = lastCell {
                lastCell.removeFromSuperview()
            }
            cells.removeLast()
        }
    }
    
    // MARK: - Numbers
    
    func setNumbers(animated: Bool, hidden: Bool = false) {
        for i in cells.indices {
            let number = game.numbers[i]
            let cell = cells[i]
            let cellIsNotAnimating = cellsNotAnimating.contains(cell)
            cell.setNumber(
                number,
                hidden: hidden,
                animated: animated ? cellIsNotAnimating : false
            )
        }
    }
    
    func swapNumbers(animated: Bool) {
        if cellsNotAnimating.isEmpty { return }
        
        print(cellsNotAnimating.count)
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
    
    // MARK: - Messages
    
    internal func showSwipeTips() {
        self.view.addSubview(swipeUpMessageView)
        self.view.addSubview(swipeDownMessageView)
        
        self.swipeUpMessageView.translatesAutoresizingMaskIntoConstraints = false
        self.swipeDownMessageView.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = self.view.layoutMarginsGuide
        
        // Swipe Up Tip View
        self.swipeUpMessageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.swipeUpMessageView.widthAnchor.constraint(lessThanOrEqualToConstant: 350).isActive = true
        self.swipeUpMessageView.topAnchor.constraint(
            greaterThanOrEqualTo: margins.topAnchor,
            constant: 35.0
        ).isActive = true
        self.swipeUpMessageView.trailingAnchor.constraint(
            greaterThanOrEqualTo: margins.trailingAnchor,
            constant: 10.0
        ).isActive = true
        self.swipeUpMessageView.leadingAnchor.constraint(
            greaterThanOrEqualTo: margins.leadingAnchor,
            constant: 10.0
        ).isActive = true
        self.swipeUpMessageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        // Swipe Down Tip View
        self.swipeDownMessageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.swipeDownMessageView.widthAnchor.constraint(lessThanOrEqualToConstant: 350).isActive = true
        self.swipeDownMessageView.bottomAnchor.constraint(
            greaterThanOrEqualTo: margins.bottomAnchor,
            constant: -35.0
        ).isActive = true
        self.swipeDownMessageView.trailingAnchor.constraint(
            greaterThanOrEqualTo: margins.trailingAnchor,
            constant: 10.0
        ).isActive = true
        self.swipeDownMessageView.leadingAnchor.constraint(
            greaterThanOrEqualTo: margins.leadingAnchor,
            constant: 10.0
        ).isActive = true
        self.swipeDownMessageView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        
        self.swipeUpMessageView.show()
        self.swipeDownMessageView.show()
    }
    
    internal func hideSwipeTips() {
        self.swipeUpMessageView.hide()
        self.swipeDownMessageView.hide()
    }
    
    // MARK: - Helping Methods
    
    @objc internal func startGame() {
        messageView.hide()
        if appearingCounter <= requiredNumberOfShowingSwipeTips {
            self.hideSwipeTips()
            appearingCounter += 1
        }
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
    
    func prepareForNewGame() {
        winkNumberTimer.invalidate()
        swapNumberTimer.invalidate()
        
        cells.forEach { $0.titleLabel?.layer.removeAllAnimations() }
        
        game.newGame()
        setNumbers(animated: false, hidden: true)
        
        for cell in cells {
            cell.hideNumber(animated: true)
            cell.isEnabled = false
        }
        
        if appearingCounter <= requiredNumberOfShowingSwipeTips {
            self.showSwipeTips()
        }
        
        self.view.addSubview(messageView)
        messageView.show()

        self.view.bringSubviewToFront(resultsView)
        
        self.statusBarIsHidden = false
    }
    
    @objc func timerSceduled() {
        if game.winkNumbersMode {
            winkRandomNumber()
        }
        if game.swapNumbersMode {
            swapNumbers(animated: true)
        }
    }
    
}
