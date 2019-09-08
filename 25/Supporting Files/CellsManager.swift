//
//  CellsManager.swift
//  25
//
//  Created by Ruslan Gritsenko on 7/16/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation

protocol CellsManagerDelegate: class {
    
    func cellPressed(_ cell: CellView)
    func cellReleased(_ cell: CellView)
}

final class CellsManager {
    
    weak var delegate: CellsManagerDelegate?
    
    private var cells: [CellView]
    private var game: Game
    private var timer: Timer?
    private var isWinking = false
    private var isSwapping = false
    
    init(with cells: [CellView], game: Game) {
        self.cells = cells
        self.game = game
        setTarget(to: cells)
    }
    
    // MARK: - Public Methods
    
    func setStyle(to style: CellView.Style, palette: CellView.Palette, animated: Bool) {
        cells.forEach { $0.setStyle(style, palette: palette, animated: animated) }
    }
    
    func setNumbers(_ numbers: [Int], animated: Bool) {
        assert(cells.count == numbers.count, "Cells count (\(cells.count)) must be equal to numbers count (\(numbers.count)) provided.")
        for i in cells.indices {
            cells[i].setNumber(numbers[i], animateIfNeeded: animated)
        }
    }
    
    func updateNumbers(with numbers: [Int], animated: Bool) {
        guard !cells.isEmpty, !numbers.isEmpty else { return }
        for i in cells.indices {
            let cell = cells[i]
            let number = numbers[i]
            cell.setNumber(number, animateIfNeeded: animated)
        }
    }
    
    func showNumbers(animated: Bool) {
        for cell in cells {
            cell.showNumber(animated: animated)
        }
    }
    
    func hideNumbers(animated: Bool) {
        for cell in cells {
            cell.hideNumber(animated: animated)
        }
    }
    
    func updateCellsStyle(to style: CellView.Style, animated: Bool) {
        cells.forEach { (cell) in
            cell.setStyle(style, palette: .hot, animated: animated)
        }
    }
    
    func startWinking() {
        guard !isWinking else { return }
        isWinking = true
        let winkingSpeed = 3.0 // less = faster
        let interval = winkingSpeed / Double(cells.count)
        timer = Timer.scheduledTimer(timeInterval: interval,
                                     target: self,
                                     selector: #selector(winkRandomNumber),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func startSwapping() {
        guard !isSwapping else { return }
        isSwapping = true
        let swappingSpeed = 8.0 // less = faster
        let interval = swappingSpeed / Double(cells.count)
        timer = Timer.scheduledTimer(timeInterval: interval,
                                     target: self,
                                     selector: #selector(swapRandomNumbers),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func stopWinking() {
        isWinking = false
        stopAnimations()
    }
    
    func stopSwapping() {
        isSwapping = false 
        stopAnimations()
    }
    
    func enableCells() {
        cells.forEach { $0.isUserInteractionEnabled = true }
    }
    
    func disableCells() {
        cells.forEach { $0.isUserInteractionEnabled = false }
    }
    
    // MARK: - Action Methods
    
    @objc private func cellPressed(_ cell: CellView) {
        guard cell.isSetEnabled else { return }
        cell.compress()
        delegate?.cellPressed(cell)
    }
    
    @objc private func cellReleased(_ cell: CellView) {
        guard cell.isSetEnabled else { return }
        let hideNumberNeeded = game.currentLevel.shuffleMode || !game.isRunning
        cell.uncompress(showNumber: !hideNumberNeeded)
        delegate?.cellReleased(cell)
    }
    
    @objc private func winkRandomNumber() {
        guard game.isRunning else { return }
        let cellsToWink = cells.filter { $0.isWinkEnabled }
        let cellToWink = cellsToWink.randomElement()
        cellToWink?.wink()
    }
    
    @objc private func swapRandomNumbers() {
//        guard game.isRunning else { return }
//        var cellsNotAnimating = cells.filter { !$0.swapEnabled }
//        if cellsNotAnimating.count < 2 { return }
//
//        let cell1 = cellsNotAnimating.randomElement()!
//        guard let index1 = cellsNotAnimating.firstIndex(of: cell1) else { return }
//        cellsNotAnimating.remove(at: index1)
//
//        let cell2 = cellsNotAnimating.randomElement()!
//
//        let number1 = cell1.number
//        let number2 = cell2.number
//
//        cell1.setNumber(number2, animateIfNeeded: true, animationSpeed: .slow)
//        cell2.setNumber(number1, animateIfNeeded: true, animationSpeed: .slow)
    }
    
    // MARK: - Private Methods
    
    internal func setTarget(to cells: [CellView]) {
        cells.forEach { (cell) in
            cell.addTarget(self, action: #selector(cellPressed(_:)), for: .touchDown)
            cell.addTarget(self, action: #selector(cellReleased(_:)), for: .touchUpInside)
            cell.addTarget(self, action: #selector(cellReleased(_:)), for: .touchUpOutside)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func stopAnimations() {
        stopTimer()
        cells.forEach { $0.removeAllAnimations() }
    }
}

extension CellsManager: CellsGridDelegate {
    
    internal func cellsCountDidChange(cells: [CellView]) {
        self.cells = cells
        setTarget(to: cells)
    }
}
