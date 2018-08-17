//
//  ViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 07.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, SettingsTableViewControllerDelegate {
    
    @IBOutlet weak var label: UILabel!
    
    private var buttonsFieldFrame: CGRect {
        let height = view.bounds.width / CGFloat(Game.shared.colums) * CGFloat(Game.shared.rows)
        let pointY = view.bounds.midY - height / 2
        return CGRect(x: 0.0, y: pointY, width: view.bounds.width, height: height)
    }
    
    private lazy var grid = Grid(layout: .dimensions(rowCount: Game.shared.rows, columnCount: Game.shared.colums), frame: buttonsFieldFrame)
    private var buttons = [UIButton]()
    private let colors = [#colorLiteral(red: 0.03137254902, green: 0.3058823529, blue: 0.4941176471, alpha: 1), #colorLiteral(red: 0.06666666667, green: 0.4823529412, blue: 0.462745098, alpha: 1), #colorLiteral(red: 0.05098039216, green: 0.4392156863, blue: 0.05882352941, alpha: 1)]
        
    override func viewDidLoad() {
        addButtons(count: Game.shared.numbers.count)
        updateViewFromModel()
    }
    
    // MARK: - Actions
    
    @objc private func buttonPressed(sender: UIButton) {
        if Game.shared.nextNumberToTap < Game.shared.numberOfNumbers {
            if sender.tag == Game.shared.nextNumberToTap {
                Game.shared.numberSelected(sender.tag)
                showMessage(on: self.label, text: "Good!")
            } else {
                showMessage(on: self.label, text: "Miss!")
            }
            if Game.shared.shuffleNumbersMode {
                Game.shared.shuffleNumbers()
                updateViewFromModel()
            }
        } else {
            Game.shared.finishGame()
            showMessage(on: label, text: String(format: "%.02f", Game.shared.elapsedTime), disappear: false)
        }
    }
    
    @IBAction func startButtonPressed(sender: UIButton) {
        showNumbers(animated: true)
        Game.shared.startGame()
    }
    
    @IBAction func newGameButtonPressed(sender: UIButton) {
        Game.shared.newGame()
        isNewGame = true
        updateViewFromModel()
        hideNumbers(animated: false)
        label.text = nil
    }
    
    @IBAction func addFiveNumbersButtonPressed(sender: UIButton) {
        if Game.shared.numbers.count < Game.shared.maxNumberOfNumbers {
            Game.shared.rows += 1
            Game.shared.newGame()
            isNewGame = true
            grid = Grid(layout: .dimensions(rowCount: Game.shared.rows, columnCount: Game.shared.colums), frame: buttonsFieldFrame)
            addButtons(count: Game.shared.colums)
            hideNumbers(animated: false)
            updateViewFromModel()
        }
    }
    
    // MARK: - UI Management
    
    private var isNewGame = true
    
    private func updateViewFromModel() {
        for i in buttons.indices {
            let button = buttons[i]

            if let viewFrame = grid[i]?.insetBy(dx: 2.0, dy: 2.0) {
                button.frame = viewFrame
            }
            
            if isNewGame {
                setNumbers()
            } else {
                updateNumbers(animated: Game.shared.shuffleNumbersMode)
            }
        }
        isNewGame = false
    }
    
    // MARK: - SettingsTableViewControllerDelegate
    
    func colorModeStateChanged(to state: Bool) {
        if state == true {
            buttons.forEach({ (button) in
                button.backgroundColor = colors[colors.count.arc4random]
            })
        } else {
            buttons.forEach({ (button) in
                button.backgroundColor = .lightGray
            })
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let svc = nav.topViewController as? SettingsTableViewController {
            svc.delegate = self
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
                button.backgroundColor = .lightGray
                button.layer.cornerRadius = 5
                button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
                button.isEnabled = false
                return button
            }()
            buttons.append(button)
            view.addSubview(button)
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
            button.isEnabled = false
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
    
    private func setNumbers() {
        for i in buttons.indices {
            let number = Game.shared.numbers[i]
            let button = buttons[i]
            button.setTitle(String(number), for: .normal)
            button.tag = number
        }
    }
    
    private func updateNumbers(animated: Bool) {
        for i in buttons.indices {
            let number = Game.shared.numbers[i]
            let button = buttons[i]
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.titleLabel?.alpha = 0.0
                }) { (position) in
                    button.setTitle(String(number), for: .normal)
                    button.tag = number
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.1,
                        delay: 0.0,
                        options: [],
                        animations: {
                            button.titleLabel?.alpha = 1.0
                    })
                }
            } else {
                button.setTitle(String(number), for: .normal)
                button.tag = number
            }
        }
    }
    
}


