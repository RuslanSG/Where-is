//
//  TutorialViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/27/18.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var cellsContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detaillabel: UILabel!
    
    private var cells = [CellView]()
    private let feedbackGenerator = FeedbackGenerator()
    private lazy var feedbackView = FeedbackView(frame: self.view.frame)
    private lazy var appearance = Appearance()
    
    private var nextCellToTap: CellView?
    private var lastTappedCell: CellView?
    
    public var game: Game!
    private var firstTimeAppeared = true
    
    private var grid: Grid {
        return Grid(
            layout: .dimensions(
                rowCount: game.rows,
                columnCount: game.colums
            ),
            frame: cellsContainerView.bounds
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parent = self.parent as? UIPageViewController, let root = parent.parent as? RootViewController {
            self.game = root.game
        }
        
        self.view.addSubview(feedbackView)
        self.view.sendSubviewToBack(feedbackView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstTimeAppeared {
            addCells(count: 25)
            setNumbers()
            game.startGame()
            nextCellToTap = getNextCellToTap()
            highlightRightCell()
            firstTimeAppeared = false
        }
    }
    
    // MARK: - Actions
    
    @objc func cellPressed(sender: CellView) {
        sender.compress(numberFeedback: !self.game.winkNumbersMode)
        let selectedNumberIsRight = game.selectedNumberIsRight(sender.tag)
        if selectedNumberIsRight && sender.tag == game.maxNumber {
            // User tapped the last number
            lastCellTapped(sender)
            return
        }
        game.numberSelected(sender.tag)
        if selectedNumberIsRight {
            // User tapped the right number
            lastTappedCell = sender
            nextCellToTap = getNextCellToTap()
            highlightRightCell()
            feedbackGenerator.playImpactHapticFeedback(needsToPrepare: true, style: .medium)
        } else {
            // User tapped the wrong number
            feedbackView.feedbackSelection(isRight: false)
            feedbackGenerator.playNotificationHapticFeedback(notificationFeedbackType: .error)
        }
    }
    
    @objc func cellReleased(sender: CellView) {
        sender.uncompress()
    }
    
    // MARK: - Helping Methods
    
    private func addCells(count: Int) {
        assert(count % 5 == 0, "Reason: invalid number of buttons to add. Provide a multiple of five number.")
        for i in 0..<count {
            if let cellFrame = grid[i] {
                let cell: CellView = {
                    let cell = CellView(frame: cellFrame)
                    cell.addTarget(self, action: #selector(cellPressed(sender:)), for: .touchDown)
                    cell.addTarget(self, action: #selector(cellReleased(sender:)), for: .touchUpInside)
                    cell.addTarget(self, action: #selector(cellReleased(sender:)), for: .touchUpOutside)
                    return cell
                }()
                cell.showNumber(animated: false)
                cell.alpha = 0.0
                cells.append(cell)
                cellsContainerView.addSubview(cell)
            } else {
                print("Error: unable to get cell's frame")
            }
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 1.0,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                self.cells.forEach { $0.alpha = 1.0 }
        })
    }
    
    private func setNumbers() {
        for i in cells.indices {
            let number = game.numbers[i]
            let cell = cells[i]
            cell.setTitle(String(number), for: .normal)
            cell.tag = number
        }
    }
    
    private func highlightRightCell() {
        for cell in cells {
            if cell == lastTappedCell {
                cell.setBackgroundColor(to: appearance.defaultCellsColor, animated: true)
            } else if let cellToHighlight = self.nextCellToTap, cell == nextCellToTap {
                cellToHighlight.setBackgroundColor(to: appearance.highlightedCellColor, animated: true)
            }
        }
    }
    
    private func getNextCellToTap() -> CellView? {
        for cell in cells {
            if cell.tag == game.nextNumberToTap {
                return cell
            }
        }
        return nil
    }
    
    private func lastCellTapped(_ cell: CellView) {
        game.finishGame()
        feedbackGenerator.playNotificationHapticFeedback(notificationFeedbackType: .success)
        cells.forEach {
            $0.hideNumber(animated: true)
            $0.isUserInteractionEnabled = false
        }
        nextCellToTap?.setBackgroundColor(to: appearance.defaultCellsColor, animated: true)
        titleLabel.changeTextWithAnimation(to: "Отлично!")
        detaillabel.changeTextWithAnimation(to: "Все очень просто! Этот принцип будет сохраняться во всех Ваших последующих играх.")
        cell.uncompress()
    }
}
