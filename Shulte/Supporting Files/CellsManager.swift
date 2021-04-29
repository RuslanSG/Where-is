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
    
    func setStyle(to style: CellView.Style, animated: Bool) {
        cells.forEach { $0.setStyle(style, animated: animated) }
    }
    
    func setNumbers(_ numbers: [Int], animated: Bool) {
        assert(cells.count == numbers.count, "Cells count (\(cells.count)) must be equal to numbers count (\(numbers.count)) provided.")
        for i in cells.indices {
            cells[i].setNumber(numbers[i], animated: animated)
        }
    }
    
    func updateNumbers(with numbers: [Int], animated: Bool) {
        guard !cells.isEmpty, !numbers.isEmpty else { return }
        for i in cells.indices {
            let cell = cells[i]
            let number = numbers[i]
            cell.setNumber(number, animated: animated)
        }
    }
    
    func showNumbers(animated: Bool) {
        cells.forEach { $0.showNumber(animated: animated) }
    }
    
    func hideNumbers() {
        cells.forEach { $0.hideNumber() }
    }
    
    func updateCellsStyle(to style: CellView.Style, animated: Bool) {
        cells.forEach { $0.setStyle(style, animated: animated) }
    }
    
    func startWinking() {
        cells.forEach { $0.startWinking() }
    }
    
    func stopWinking() {
        cells.forEach { $0.stopWinking() }
    }
    
    func enableCells() {
        cells.forEach { $0.isUserInteractionEnabled = true }
    }
    
    func disableCells() {
        cells.forEach { $0.isUserInteractionEnabled = false }
    }
    
    func cell(with number: Int) -> CellView? {
        cells.first { $0.titleLabel?.text == String(number) }
    }
    
    // MARK: - Action Methods
    
    @objc private func cellPressed(_ cell: CellView) {
        cell.compress()
        delegate?.cellPressed(cell)
    }
    
    @objc private func cellReleased(_ cell: CellView) {
        let hideNumberNeeded = game.currentLevel.shuffleMode || !game.isRunning
        cell.uncompress(showNumber: !hideNumberNeeded)
        delegate?.cellReleased(cell)
    }
    
    // MARK: - Private Methods
    
    internal func setTarget(to cells: [CellView]) {
        cells.forEach { (cell) in
            cell.addTarget(self, action: #selector(cellPressed(_:)), for: .touchDown)
            cell.addTarget(self, action: #selector(cellReleased(_:)), for: .touchUpInside)
            cell.addTarget(self, action: #selector(cellReleased(_:)), for: .touchUpOutside)
        }
    }
}

extension CellsManager: CellsGridDelegate {
    
    internal func cellsCountDidChange(cells: [CellView]) {
        self.cells = cells
        setTarget(to: cells)
    }
}
