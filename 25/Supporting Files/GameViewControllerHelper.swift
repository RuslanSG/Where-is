//
//  GameViewControllerHelper.swift
//  25
//
//  Created by Ruslan Gritsenko on 8/9/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

extension GameViewController {
    
    internal enum StartGameViewAcpectRatio {
        case threeToOne, threeToTwo, twoToOne
    }
    
    internal enum SettingsButtonAspectRatio {
        case oneToOne, oneToTwo
    }
    
    internal func getRectUnion(of cells: [CellView]) -> CGRect {
        var rect: CGRect = .zero
        
        for cell in cells {
            let cellFrame = self.view.convert(cell.bounds, from: cell)
            if rect == .zero {
                rect = cellFrame
            } else {
                rect = rect.union(cellFrame)
            }
        }
        
        return rect
    }
    
    internal func startGameViewRect(aspectRatio: StartGameViewAcpectRatio) -> CGRect {
        let origin: CGPoint
        let size: CGSize
        
        switch aspectRatio {
        case .threeToOne:
            if orientation == .portrait {
                origin = CGPoint(x: 2,
                                 y: Int(ceilf(Float(cellsGrid.cells.count) / Float(rowSize) / 2)))
            } else {
                origin = CGPoint(x: cellsGrid.cells.count / rowSize / 2,
                                 y: 3)
            }
            size = CGSize(width: 3, height: 1)
        case .threeToTwo:
            if orientation == .portrait {
                origin = CGPoint(x: 2,
                                 y: cellsGrid.cells.count / rowSize / 2)
            } else {
                origin = CGPoint(x: cellsGrid.cells.count / rowSize / 2,
                                 y: 2)
            }
            size = CGSize(width: 3, height: 2)
        case .twoToOne:
            if orientation == .portrait {
                origin = CGPoint(x: 2,
                                 y: Int(ceilf(Float(cellsGrid.cells.count) / Float(rowSize) / 2)))
            } else {
                origin = CGPoint(x: cellsGrid.cells.count / rowSize / 2,
                                 y: 3)
            }
            size = CGSize(width: 2, height: 1)
        }
        
        guard let centralCells = cellsGrid.getCells(origin: origin, size: size) else {
            return .zero
        }
        
        return getRectUnion(of: centralCells).inset(by: UIEdgeInsets(top: globalCellInset,
                                                                     left: globalCellInset,
                                                                     bottom: globalCellInset,
                                                                     right: globalCellInset))
    }
    
    internal func settingsButtonRect(aspectRatio: SettingsButtonAspectRatio) -> CGRect {
        let origin: CGPoint
        let size: CGSize
        
        switch aspectRatio {
        case .oneToOne:
            if orientation == .portrait {
                origin = CGPoint(x: Int(ceilf(Float(rowSize) / 2)),
                                 y: cellsGrid.cells.count / rowSize)
            } else {
                origin = CGPoint(x: Int(ceilf(Float(cellsGrid.cells.count) / Float(rowSize) / 2)),
                                 y: rowSize)
            }
            size = CGSize(width: 1, height: 1)
        case .oneToTwo:
            origin = CGPoint(x: cellsGrid.cells.count / rowSize / 2,
                             y: rowSize)
            size = CGSize(width: 2, height: 1)
        }
        
        guard let targetCells = cellsGrid.getCells(origin: origin, size: size) else { return .zero }
        cellsUnderSettingsButton = targetCells
        
        return getRectUnion(of: targetCells).inset(by: UIEdgeInsets(top: globalCellInset,
                                                                    left: globalCellInset,
                                                                    bottom: globalCellInset,
                                                                    right: globalCellInset))
    }
}
