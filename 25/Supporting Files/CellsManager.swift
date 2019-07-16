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
    private var timer: Timer?
    
    init(with cells: [CellView]) {
        self.cells = cells
        setTarget(to: cells)
    }
    
    // MARK: - Public Methods
    
    func setStyle(to style: CellView.Style, animated: Bool) {
        cells.forEach { $0.setStyle(style, animated: animated) }
    }
    
    func setNumbers(_ numbers: [Int], animated: Bool) {
        assert(cells.count == numbers.count, "Cells count must be equal to numbers count provided")
        for i in cells.indices {
            cells[i].setNumber(numbers[i], animated: animated)
        }
    }
    
    func updateNumbers(with numbers: [Int], animated: Bool) {
        if cells.isEmpty, numbers.isEmpty { return }
        for i in cells.indices {
            let cell = cells[i]
            let number = numbers[i]
            cell.setNumber(number, animated: animated)
        }
    }
    
    func updateCellsStyle(to style: CellView.Style, animated: Bool) {
        cells.forEach { (cell) in
            cell.setStyle(style, animated: animated)
        }
    }
    
    func startWinking() {
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(winkRandomNumber),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func startSwapping() {
        timer = Timer.scheduledTimer(timeInterval: 0.2,
                                     target: self,
                                     selector: #selector(swapRandomNumbers),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func stopWinking() {
        stopTimer()
    }
    
    func stopSwapping() {
        stopTimer()
    }
    
    // MARK: - Action Methods
    
    @objc private func cellPressed(_ cell: CellView) {
        delegate?.cellPressed(cell)
    }
    
    @objc private func cellReleased(_ cell: CellView) {
        delegate?.cellReleased(cell)
    }
    
    @objc private func winkRandomNumber() {
//        if !game.isRunning { return }
        #warning("Fix this")
        let cellsNotAnimating = cells.filter { !$0.isAnimating }
        let cellToWink = cellsNotAnimating.randomElement()
        cellToWink?.wink()
    }
    
    @objc private func swapRandomNumbers() {
//        if !game.isRunning { return }
        #warning("Fix this")
        var cellsNotAnimating = cells.filter { !$0.isAnimating }
        if cellsNotAnimating.count < 2 { return }
        
        let cell1 = cellsNotAnimating.randomElement()!
        guard let index1 = cellsNotAnimating.firstIndex(of: cell1) else { return }
        cellsNotAnimating.remove(at: index1)
        
        let cell2 = cellsNotAnimating.randomElement()!
        
        let number1 = cell1.tag
        let number2 = cell2.tag
        
        cell1.setNumber(number2, animated: true, speed: .slow)
        cell2.setNumber(number1, animated: true, speed: .slow)
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
    
}

extension CellsManager: CellsGridDelegate {
    
    internal func cellsCountDidChange(cells: [CellView]) {
        self.cells = cells
        setTarget(to: cells)
    }
}
