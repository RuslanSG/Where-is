//
//  CellsGrid.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/2/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol CellsGridDelegate: class {
    
    func cellsCountDidChange(cells: [CellView])
}

class CellsGrid: UIStackView {
    
    weak var delegate: CellsGridDelegate?
    
    var cells: [CellView] = [] {
        didSet {
            delegate?.cellsCountDidChange(cells: cells)
        }
    }
    
    let rowSize: Int
    let rowHeight: CGFloat
    
    var heightConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?
    
    private var currentRow: UIStackView?
    private var lastRowIndex: Int!
    
    init(rowSize: Int, rowHeight: CGFloat) {
        self.rowSize = rowSize
        self.rowHeight = rowHeight
        super.init(frame: .zero)
        self.axis = .vertical
        self.distribution = .fillEqually
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func addRows(count: Int, animated: Bool) {
        assert(count.isMultiple(of: 5), "Reason: invalid number of views. Provide a multiple of five number.")
        addCells(count: count * rowSize, animated: animated)
        lastRowIndex = arrangedSubviews.count - 1
    }
    
    func removeRows(count: Int, animated: Bool) {
        if cells.isEmpty { return }
        for _ in 0..<count {
            if lastRowIndex >= arrangedSubviews.count { return }
            let lastRow = arrangedSubviews[lastRowIndex] as? UIStackView
            lastRow?.arrangedSubviews.forEach {
                let cellView = $0 as! CellView
                if let index = self.cells.firstIndex(of: cellView) {
                    self.cells.remove(at: index)
                }
            }
            lastRowIndex -= count
            if !animated {
                lastRow?.removeFromSuperview()
                return
            }
            UIView.animate(withDuration: 0.3,
                           animations: {
                            lastRow?.alpha = 0.0
            }) { (_) in
                lastRow?.removeFromSuperview()
                UIView.animate(withDuration: 0.3, animations: {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    func switchAxis(to axis: NSLayoutConstraint.Axis) {
        for row in arrangedSubviews where row is UIStackView {
            let stackView = row as! UIStackView
            if axis == .vertical {
                stackView.axis = .horizontal
            } else {
                stackView.axis = .vertical
            }
        }
        
        self.axis = axis
    }
    
    // MARK: - Private Methods
    
    private func addCells(count: Int, animated: Bool) {
        for _ in 0..<count {
            let cell = CellView(inset: 2.0)
            cell.setCornerRadius(cornerRadius: 7.0)
            cell.titleLabel?.font = .systemFont(ofSize: 35.0)
            
            let firstCellInRow = cells.count % rowSize == 0
            if currentRow == nil || firstCellInRow {
                currentRow = preapreRow()
                addArrangedSubview(self.currentRow!)
                if animated {
                    UIView.animate(withDuration: 0.3,
                                   delay: 0,
                                   options: .curveEaseOut,
                                   animations: {
                                    self.setNeedsLayout()
                                    self.layoutIfNeeded()
                    })
                }
            }
            
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.heightAnchor.constraint(equalToConstant: rowHeight).isActive = true
            cell.widthAnchor.constraint(equalToConstant: rowHeight).isActive = true
            
            cells.append(cell)
            currentRow!.addArrangedSubview(cell)
            
            if animated {
                cell.alpha = 0.0
                UIView.animate(withDuration: 0.3,
                               delay: 0.3,
                               options: .curveEaseOut,
                               animations: {
                                cell.alpha = 1.0
                })
            } else {
                cell.alpha = 1.0
            }
        }
    }
    
    private func preapreRow() -> UIStackView {
        let row = UIStackView(arrangedSubviews: [])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = self.axis == .vertical ? .horizontal : .vertical
        row.distribution = .fillEqually
        return row
    }
    
}
