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
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let staturBarHeight = UIApplication.shared.statusBarFrame.height
        
        let bottomGap = screenHeight - stopButton.frame.maxY
        
        let minY = staturBarHeight + appearance.gridInset
        let maxY = screenHeight - stopButton.frame.height - bottomGap - appearance.gridInset
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
            let width = cell.bounds.width * 3 - appearance.gridInset * 2
            return width
        }
        return 0.0
    }
    
    internal var messageViewHeight: CGFloat {
        if let cellHeight = buttonHeight {
            let height = cells.count % 10 == 0 ? cellHeight * 2 - appearance.gridInset * 2 :
                                                 cellHeight - appearance.gridInset * 2
            return height
        }
        return 0.0
    }
    
    // MARK: - Cells
    
    func updateButtonsFrames() {
        for i in cells.indices {
            let button = cells[i]
            if let buttonFrame = grid[i] {
                button.frame = buttonFrame
            }
        }
    }
    
    func addCells(count: Int) {
        assert(count % 5 == 0, "Reason: invalid number of buttons to add. Provide a multiple of five number.")
        for _ in 0..<count {
            let cell: Cell = {
                let cell = Cell(frame: CGRect(x: 0, y: 0, width: 0, height: 0), appearance: appearance)
                cell.addTarget(self, action: #selector(cellPressed(sender:)), for: .touchDown)
                cell.addTarget(self, action: #selector(cellReleased(sender:)), for: .touchUpInside)
                cell.addTarget(self, action: #selector(cellReleased(sender:)), for: .touchUpOutside)
                return cell
            }()
            cells.append(cell)
            buttonsContainerView.addSubview(cell)
        }
    }
    
    func removeButtons(count: Int) {
        assert(count % 5 == 0, "Reason: invalid number of buttons to remove. Provide a multiple of five number.")
        for _ in 0..<count {
            let lastButton = cells.last
            if let lastButton = lastButton {
                lastButton.removeFromSuperview()
            }
            cells.removeLast()
        }
    }
    
    // MARK: - Numbers
    
    func setNumbers() {
        for i in cells.indices {
            let number = game.numbers[i]
            let cell = cells[i]
            cell.setTitle(String(number), for: .normal)
            cell.tag = number
        }
    }
    
    func updateNumbers(animated: Bool) {
        for i in cells.indices {
            let number = game.numbers[i]
            let cell = cells[i]
            cell.updateNumber(to: number, animated: cellsNotAnimating.contains(cell))
        }
    }
    
    func swapNumbers(animated: Bool) {
        let cell1 = cellsNotAnimating[cellsNotAnimating.count.arc4random]
        guard let index1 = cellsNotAnimating.index(of: cell1) else { return }
        cellsNotAnimating.remove(at: index1)
        
        let cell2 = cellsNotAnimating[cellsNotAnimating.count.arc4random]
        guard let index2 = cellsNotAnimating.index(of: cell2) else { return }
        cellsNotAnimating.remove(at: index2)
        
        let number1 = cell1.tag
        let number2 = cell2.tag
        
        let duration = 1.0
        
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: duration / 2,
                delay: 0.0,
                options: [],
                animations: {
                    cell1.titleLabel?.alpha = 0.0
                    cell2.titleLabel?.alpha = 0.0
            }) { (position) in
                if self.game.inGame {
                    cell1.setTitle(String(number2), for: .normal)
                    cell2.setTitle(String(number1), for: .normal)
                    cell1.tag = number2
                    cell2.tag = number1
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: duration / 2,
                        delay: 0.0,
                        options: [],
                        animations: {
                            cell1.titleLabel?.alpha = 1.0
                            cell2.titleLabel?.alpha = 1.0
                    })
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.cellsNotAnimating.append(cell1)
                self.cellsNotAnimating.append(cell2)
            }
        }
    }
    
    internal func winkNumber(at cell: Cell) {
        let duration = 1.0
        let delay = 1.0
        
        cell.winkNumber(duration: duration, delay: delay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + delay) {
            self.cellsNotAnimating.append(cell)
        }
        
    }
    
    // MARK: - Colors
    
    func removeCellColors(animated: Bool) {
        cells.forEach({ (cell) in
            cell.updateBackgroundColor(animated: animated, to: appearance.defaultCellsColor)
        })
    }
    
    func removeNumberColors(animated: Bool) {
        cells.forEach({ (cell) in
            cell.updateNumberColor(animated: false)
        })
    }
    
    func winkCellColor(at cell: Cell) {
        guard let currentColor = cell.backgroundColor else { return }
        if let color = appearance.getAnotherColor(for: currentColor) {
            cell.updateBackgroundColor(animated: true, to: color)
        }
    }
    
    // MARK: - Helping Methods
    
    internal func startGame() {
        if resultsIsShowing {
            resultsView.hide()
            resultsIsShowing = false
        }
        
        for cell in cells {
            cell.updateBackgroundColor(animated: false)
            cell.updateNumberColor(animated: false)
            cell.showNumber(animated: true)
        }
        
        stopButton.isEnabled = true
        
        game.startGame()
        
        feedbackGenerator.impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactFeedbackGenerator?.prepare()
        
        if game.winkNumbersMode {
            timer1 = Timer.scheduledTimer(
                timeInterval: TimeInterval(3.5 / Double(game.maxNumber)),
                target: self,
                selector: #selector(timerSceduled),
                userInfo: nil,
                repeats: true
            )
        }
        if game.swapNumbersMode {
            timer2 = Timer.scheduledTimer(
                timeInterval: TimeInterval(5.0 / Double(game.maxNumber)),
                target: self,
                selector: #selector(timerSceduled),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    func prepareForNewGame() {
        game.newGame()
        setNumbers()
        stopButton.isEnabled = false
        if game.winkNumbersMode || game.winkColorsMode || game.swapNumbersMode {
            timer1.invalidate()
            timer2.invalidate()
            cells.forEach { $0.titleLabel?.layer.removeAllAnimations() }
        }
        cells.forEach { $0.hideNumber(animated: false) }
        self.view.addSubview(messageView)
        self.view.bringSubviewToFront(resultsView)
        messageView.show()
    }
    
    @objc func timerSceduled() {
        if game.winkNumbersMode {
            wink(.number)
        }
        if game.winkColorsMode {
            wink(.color)
        }
        if game.swapNumbersMode {
            swapNumbers(animated: true)
        }
    }
    
    enum CellPart {
        case number
        case color
    }
    
    func wink(_ cellPart: CellPart) {
        if cellPart == .number {
            print(cellsNotAnimating.count)
            let cell = cellsNotAnimating[cellsNotAnimating.count.arc4random]
            if let index = cellsNotAnimating.index(of: cell) {
                cellsNotAnimating.remove(at: index)
            }
            winkNumber(at: cell)
        }
        if cellPart == .color {
            let cell = cells[cells.count.arc4random]
            winkCellColor(at: cell)
        }
    }
    
}
