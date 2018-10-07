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
    
    private var game = Game()
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
    
    // MARK - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInputComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Setuping
    
    private func setupInputComponents() {
        self.view.addSubview(feedbackView)
        self.view.sendSubviewToBack(feedbackView)
        
        if firstTimeAppeared {
            addCells(count: 25)
            updateCellFrames()
            setNumbers()
            game.startGame()
            nextCellToTap = getNextCellToTap()
            highlightRightCell()
            firstTimeAppeared = false
        }
    }
    
    // MARK: - Actions
    
    @objc func cellPressed(sender: CellView) {
        let selectedNumberIsRight = game.selectedNumberIsRight(sender.tag)
        if selectedNumberIsRight && sender.tag == game.maxNumber {
            // User tapped the last number
            sender.compress(numberFeedback: false)
            lastCellTapped(sender)
            return
        }
        sender.compress(numberFeedback: true)
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
        for _ in 0..<count {
            let cell: CellView = {
                let cell = CellView(frame: CGRect.zero, inset: appearance.gridInset)
                let backgroundColor = appearance.defaultCellsColor
                let numberColor = appearance.defaultNumbersColor
                cell.setBackgroundColor(to: backgroundColor, animated: false)
                cell.setNumberColor(to: numberColor, animated: false)
                cell.setCornerRadius(to: appearance.cornerRadius)
                cell.titleLabel?.font = UIFont.systemFont(ofSize: appearance.numbersFontSize)
                cell.addTarget(self, action: #selector(cellPressed(sender:)), for: .touchDown)
                cell.addTarget(self, action: #selector(cellReleased(sender:)), for: .touchUpInside)
                cell.addTarget(self, action: #selector(cellReleased(sender:)), for: .touchUpOutside)
                return cell
            }()
            cell.showNumber(animated: false)
            cell.alpha = 0.0
            cells.append(cell)
            cellsContainerView.addSubview(cell)
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 1.0,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                self.cells.forEach { $0.alpha = 1.0 }
        })
    }
    
    private func updateCellFrames() {
        for i in cells.indices {
            let cell = cells[i]
            if let cellFrame = grid[i] {
                cell.frame = cellFrame
            }
        }
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
