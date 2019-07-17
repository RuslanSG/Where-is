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
    
    var cells: [CellView] = []
    
    let rowsCount: Int
    
    var heightConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?
    
    var orientation: Orientation = .portrait
    
    private var currentRow: UIStackView?
    private var lastRowIndex: Int!
    
    private var rowHeight: CGFloat {
        return (UIScreen.main.bounds.width - 2.0) / CGFloat(rowsCount)
        #warning("Replace cell inset (2.0)")
    }
    
    init(rowSize: Int) {
        self.rowsCount = rowSize
        super.init(frame: .zero)
        self.axis = .vertical
        self.distribution = .fillEqually
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func addRows(count: Int, animated: Bool) {
        addCells(count: count * rowsCount, animated: animated)
        lastRowIndex = arrangedSubviews.count - 1
        
        if orientation == .portrait {
            heightConstraint?.constant += rowHeight
        } else {
            widthConstraint?.constant += rowHeight
        }
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

            if orientation == .portrait {
                heightConstraint?.constant -= rowHeight
            } else {
                widthConstraint?.constant -= rowHeight
            }
            
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
        delegate?.cellsCountDidChange(cells: cells)
    }
    
    func setOrientation(to orientation: Orientation) {
        for row in arrangedSubviews where row is UIStackView {
            let stackView = row as! UIStackView
            if orientation == .portrait {
                stackView.axis = .horizontal
            } else {
                stackView.axis = .vertical
            }
        }
        
        self.axis = orientation == .portrait ? .vertical : .horizontal
        
        guard let heightConstraintConstant = heightConstraint?.constant else { return }
        guard let widthConstraintConstant = widthConstraint?.constant else { return }
                
        heightConstraint?.constant = widthConstraintConstant
        widthConstraint?.constant = heightConstraintConstant
    }
    
    // MARK: - Private Methods
    
    private func addCells(count: Int, animated: Bool) {
        assert(count.isMultiple(of: rowsCount), "Reason: invalid number of views. Provide a multiple of row size (\(rowsCount)) number.")
        for _ in 0..<count {
            let cell = CellView(inset: 2.0)
            cell.setCornerRadius(cornerRadius: 7.0)
            cell.titleLabel?.font = .systemFont(ofSize: 35.0)
            
            let firstCellInRow = cells.count % rowsCount == 0
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
        delegate?.cellsCountDidChange(cells: cells)
    }
    
    private func preapreRow() -> UIStackView {
        let row = UIStackView(arrangedSubviews: [])
        row.axis = self.axis == .vertical ? .horizontal : .vertical
        row.distribution = .fillEqually
        return row
    }
    
}
