//
//  ViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 07.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var basicView: UIView!
    
    private var rowCount = 5 {
        didSet {
            grid = Grid(layout: .dimensions(rowCount: rowCount, columnCount: columnCount), frame: basicView.bounds)
        }
    }
    private let columnCount = 5
    
    private lazy var game = Game(rows: rowCount, colums: columnCount)
    private lazy var grid = Grid(layout: .dimensions(rowCount: rowCount, columnCount: columnCount), frame: basicView.bounds)
    private var buttons = [UIButton]()
    
    override func viewDidLoad() {
        updateViewFromModel()
    }
    
    // MARK: - Actions
    
    @objc private func buttonPressed(sender: UIButton) {
        if game.nextNumberToTap < game.numberOfNumbers {
            if sender.tag == game.nextNumberToTap {
                game.numberSelected()
                showMessage(on: self.label, text: "Good!")
            } else {
                showMessage(on: self.label, text: "Miss!")
            }
        } else {
            game.finishGame()
            showMessage(on: label, text: String(format: "%.02f", game.elapsedTime), disappear: false)
        }
    }
    
    @IBAction func startButtonPressed(sender: UIButton) {
        showNumbers(animated: true)
        game.startGame()
    }
    
    @IBAction func newGameButtonPressed(sender: UIButton) {
        game.newGame()
        hideNumbers(animated: false)
        updateViewFromModel()
    }
    
    @IBAction func addFiveNumbersButtonPressed(sender: UIButton) {
        let height = self.view.bounds.width / CGFloat(columnCount) * CGFloat(rowCount + 1)
        let pointY = self.view.bounds.midY - height / 2
        basicView.frame = CGRect(x: 0.0, y: pointY, width: self.view.bounds.width, height: height)
        rowCount += 1
        game = Game(rows: rowCount, colums: columnCount)
        addButtons(count: columnCount)
        updateViewFromModel()
    }
    
    // MARK: - UI Management
    
    private func updateViewFromModel() {
        if game.numberOfNumbers != basicView.subviews.count {
            addButtons(count: game.numberOfNumbers - basicView.subviews.count)
        }
        
        grid.cellCount = game.numberOfNumbers
        for i in buttons.indices {
            if let viewFrame = grid[i]?.insetBy(dx: 2.0, dy: 2.0) {
                let number = game.numbers[i]
                let button = buttons[i]
                button.frame = viewFrame
                button.setTitle(String(number), for: .normal)
                button.tag = number
            }
            
        }
    }
    
    // MARK: - Helping Methods
    
    private func showMessage(on label: UILabel, text: String, disappear: Bool = true) {
        label.text = text
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: 0.0,
            options: [],
            animations: {
                label.alpha = 1.0
        }) { (position) in
            if disappear {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.2,
                    delay: 0.5,
                    options: [],
                    animations: {
                        label.alpha = 0.0
                })
            }
        }
    }
    
    private func addButtons(count: Int) {
        for _ in 0..<count {
            let button: UIButton = {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                button.titleLabel?.font = UIFont.systemFont(ofSize: 35)
                button.titleLabel?.alpha = 0.0
                button.backgroundColor = .red
                button.layer.cornerRadius = 5
                button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
                button.isEnabled = false
                return button
            }()
            buttons.append(button)
            basicView.addSubview(button)
        }
    }
    
    private func showNumbers(animated: Bool) {
        buttons.forEach({ (button) in
            button.isEnabled = true
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.2,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.titleLabel?.alpha = 1.0
                })
            } else {
                button.titleLabel?.alpha = 1.0
            }
        })
    }
    
    private func hideNumbers(animated: Bool) {
        buttons.forEach({ (button) in
            button.isEnabled = true
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.2,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.titleLabel?.alpha = 0.0
                })
            } else {
                button.titleLabel?.alpha = 0.0
            }
        })
    }
    
}


