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
    
    private var game = Game(numberOfNumbers: 5*5)
    private lazy var grid = Grid(layout: .aspectRatio(1/1), frame: basicView.bounds)
    private var buttons = [UIButton]()
    
    override func viewDidLoad() {
        updateViewFromModel()
    }
    
    // MARK: - Actions
    
    @objc private func buttonPressed(sender: UIButton) {
        if game.nextNumberToTap < game.numberOfNumbers {
            if sender.tag == game.nextNumberToTap {
                print(sender.tag)
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
        buttons.forEach({ (button) in
            button.isEnabled = true
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.2,
                delay: 0.0,
                options: [],
                animations: {
                    button.titleLabel?.alpha = 1.0
                }
            )
        })
        game.startGame()
    }
    
    @IBAction func newGameButtonPressed(sender: UIButton) {
        game.newGame()
        hideNumbers()
        updateViewFromModel()
    }
    
    @IBAction func addFiveNumbersButtonPressed(sender: UIButton) {
//        game = Game(numberOfNumbers: 6*5)
    }
    
    // UI Management
    
    private func updateViewFromModel() {
        if game.numberOfNumbers != basicView.subviews.count {
            addButtons(count: game.numberOfNumbers - basicView.subviews.count)
        }
        
        for i in buttons.indices {
            let button = buttons[i]
            let number = game.numbers[i]
            button.titleLabel?.text = String(number)
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
        grid.cellCount += count
        for i in 0..<count {
            if let viewFrame = grid[i]?.insetBy(dx: 2.0, dy: 2.0) {
                let number = game.numbers[i]
                let button: UIButton = {
                    let button = UIButton(frame: viewFrame)
                    button.setTitle(String(number), for: .normal)
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 35)
                    button.titleLabel?.alpha = 0.0
                    button.backgroundColor = .red
                    button.tag = number
                    button.layer.cornerRadius = 5
                    button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
                    button.isEnabled = false
                    return button
                }()
                buttons.append(button)
                basicView.addSubview(button)
            }
        }
    }
    
    private func hideNumbers() {
        buttons.forEach({ (button) in
            button.titleLabel?.alpha = 0.0
        })
    }
    
}


