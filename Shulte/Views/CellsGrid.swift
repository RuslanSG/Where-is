//
//  CellsGrid.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/2/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol CellsGridDelegate: AnyObject {
    
    func cellsCountDidChange(cells: [CellView])
}

class CellsGrid: UIStackView {
    
    // MARK: - Public Properties
    
    weak var delegate: CellsGridDelegate?
    
    var topConstraint: NSLayoutConstraint?
    var leftConstraint: NSLayoutConstraint?
    
    private(set) var cells: [CellView] = []
    private(set) var gridOrientation: Orientation = .portrait
    
    // MARK: - Private Properties
    
    private var currentRow: UIStackView?
    private var lastRowIndex: Int!
    private let rowSize: Int
    private let rowHeight: CGFloat
    
    // MARK: - Initialization
    
    init(rowSize: Int, rowHeight: CGFloat) {
        self.rowHeight = rowHeight
        self.rowSize = rowSize
        super.init(frame: .zero)
        self.axis = .vertical
        self.distribution = .fillEqually
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func addRows(count: Int, animated: Bool) {
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
            
            if animated {
                UIView.animate(withDuration: 0.3,
                               animations: {
                                lastRow?.removeFromSuperview()
                                self.layoutIfNeeded()
                })
            } else {
                lastRow?.removeFromSuperview()
                layoutIfNeeded()
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
                
        if orientation == .portrait {
            axis = .vertical
            topConstraint?.isActive = true
            leftConstraint?.isActive = false
        } else if orientation == .landscape {
            axis = .horizontal
            topConstraint?.isActive = false
            leftConstraint?.isActive = true
        }
    }
    
    func getCell(at point: CGPoint) -> CellView? {
        let index: Int
        
        if orientation == .portrait {
            index = Int(point.y - 1) * rowSize + Int(point.x - 1)
        } else {
            index = Int(point.x - 1) * rowSize + Int(point.y - 1)
        }
        
        guard index <= cells.count - 1 && index >= 0 else {
            return nil
        }
        
        return cells[index]
    }
    
    func getCells(origin: CGPoint, size: CGSize) -> [CellView]? {
        let xAxisIsValid: Bool
        let yAxisIsValid: Bool
        
        if orientation == .portrait {
            xAxisIsValid = origin.x + size.width - 1 <= CGFloat(rowSize)
            yAxisIsValid = origin.y + size.height - 1 <= CGFloat(cells.count / rowSize)
        } else {
            xAxisIsValid = origin.x + size.width - 1 <= CGFloat(cells.count / rowSize)
            yAxisIsValid = origin.y + size.height - 1 <= CGFloat(rowSize)
        }
        
        guard xAxisIsValid && yAxisIsValid else {
            return nil
        }
        
        var cells = [CellView]()
        
        for i in 0..<Int(size.height) {
            let y = origin.y + CGFloat(i)
            for j in 0..<Int(size.width) {
                let x = origin.x + CGFloat(j)
                cells.append(getCell(at: CGPoint(x: x, y: y))!)
            }
        }
        
        return cells
    }
    
    // MARK: - Private Methods
    
    private func addCells(count: Int, animated: Bool) {
        assert(count.isMultiple(of: rowSize), "Reason: invalid number of views. Provide a multiple of row size (\(rowSize)) number.")
        for _ in 0..<count {
            let cell = CellView(frame: .zero, contentViewInset: cellInset)
            cell.setCornerRadius(cellCornerRadius)
            if #available(iOS 13, *) {
                if let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withDesign(.rounded) {
                    cell.titleLabel?.font = UIFont(descriptor: descriptor, size: cellNumbersFontSize)
                }
            } else {
                cell.titleLabel?.font = .systemFont(ofSize: cellNumbersFontSize)
            }
            
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
            let widthConstraint = cell.widthAnchor.constraint(equalToConstant: rowHeight)
            let heightConstraint = cell.heightAnchor.constraint(equalToConstant: rowHeight)
            widthConstraint.priority = UILayoutPriority(rawValue: 999)
            heightConstraint.priority = UILayoutPriority(rawValue: 999)
            widthConstraint.isActive = true
            heightConstraint.isActive = true

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

extension CellsGrid {
    
    override var description: String {
        var result = ""
        for i in 1...cells.count {
            if i % rowSize == 0 {
                result += "\(cells[i - 1])\n"
            } else {
                result += "\(cells[i - 1])\t"
            }
        }
        return result
    }
}
