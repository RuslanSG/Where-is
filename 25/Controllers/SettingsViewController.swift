//
//  SettingsViewController.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/20/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: class {
    
    func levelDidChange(to level: Level)
}

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet var levelButtons: [UIButton]!
    
    var game: Game!
    weak var delegate: SettingsViewControllerDelegate?
    
    private let levelButtonSideSize: CGFloat = 50.0
    private let infinityLevelButtonHeightCoeff: CGFloat = 1.7
    /// higher coeff = lower height revatavely to the regular level button
    
    private var lastPressedLevelButton: UIButton?
    
    private let levelButtonsGridParameters: (rows: Int, colums: Int) = {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return (rows: 7, colums: 5)
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            return (rows: 4, colums: 10)
        }
        return (rows: 0, colums: 0)
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        highlightLevelButton(for: game.level)
    }
    
    deinit {
        print("deinit: \(self)")
    }

    // MARK: - Actions
    
    @IBAction func levelButtonPressed(_ sender: UIButton) {
        game.setLevel(to: sender.tag)
        delegate?.levelDidChange(to: game.level)
        lastPressedLevelButton?.layer.borderWidth = 0.0
        sender.layer.borderWidth = 3.0
        sender.layer.borderColor = UIColor.red.cgColor
        lastPressedLevelButton = sender
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func contactButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func rateButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Hepler Methods
    
    private func highlightLevelButton(for level: Level) {
        let index = levelButtons.firstIndex { $0.tag == level.index }
        guard let i = index else { return }
        let levelButton = levelButtons[i]
        levelButton.layer.borderWidth = 3.0
        levelButton.layer.borderColor = UIColor.red.cgColor
        lastPressedLevelButton = levelButton
    }
    
    
    
//    private func setupLevelButtonsStackView(count: Int) {
//        let verticalStackView = UIStackView()
//        verticalStackView.axis = .vertical
//        verticalStackView.distribution = .equalSpacing
//        verticalStackView.alignment = .fill
//
//        for i in 0..<levelButtonsGridParameters.rows - 1 { /// minus Infinity Level button
//            let horizontalStackView = UIStackView()
//            horizontalStackView.axis = .horizontal
//            horizontalStackView.distribution = .equalSpacing
//            horizontalStackView.alignment = .fill
//
//            for j in 1...levelButtonsGridParameters.colums {
//                let level = j + i * levelButtonsGridParameters.colums
//                //                horizontalStackView.addArrangedSubview(setupLevelButton(for: level))
//            }
//            verticalStackView.addArrangedSubview(horizontalStackView)
//        }
//
//        /// Adding Infinity Level button
//        //        verticalStackView.addArrangedSubview(setupLevelButton(for: 0))
//
//        self.firstCell.contentView.addSubview(verticalStackView)
//
//        /// verticalStackView constraints
//        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
//        verticalStackView.topAnchor.constraint(equalTo: self.firstCell.contentView.topAnchor, constant: 10.0).isActive = true
//        verticalStackView.bottomAnchor.constraint(equalTo: self.firstCell.contentView.bottomAnchor, constant: -10.0).isActive = true
//        verticalStackView.leftAnchor.constraint(equalTo: self.firstCell.contentView.leftAnchor, constant: 16.0).isActive = true
//        verticalStackView.rightAnchor.constraint(equalTo: self.firstCell.contentView.rightAnchor, constant: -16.0).isActive = true
//
//        //        updateLevelButtons()
//    }
    
//    private func setupLevelButton(for level: Int) -> UIButton {
//        let fontSize: CGFloat = 25.0
//        let cornerRadius: CGFloat = 8.0
//        let title = level == 0 ? "∞" : String(level)
//        let side = level == 0 ? levelButtonSideSize / self.infinityLevelButtonHeightCoeff : levelButtonSideSize
//
//        let levelButton = UIButton()
//        levelButton.setTitle(title, for: .normal)
//        levelButton.setTitleColor(.white, for: .normal)
//        levelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
//        levelButton.tag = level
//        levelButton.layer.cornerRadius = cornerRadius
//        levelButton.translatesAutoresizingMaskIntoConstraints = false
//        levelButton.heightAnchor.constraint(equalToConstant: side).isActive = true
//        levelButton.widthAnchor.constraint(equalToConstant: side).isActive = true
//        levelButton.addTarget(self, action: #selector(levelButtonPressed(_:)), for: .touchUpInside)
//
//        self.levelButtons.append(levelButton)
//
//        return levelButton
//    }
//
//    private func updateLevelButtons() {
//
//    }
//
//    private func selectLevelButton(_ button: UIButton) {
//
//    }
    
    
}

// MARK: - Table View Delegate

extension SettingsViewController {
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        
//        return 44.0
//    }
    
}

// MARK: - Strings

extension SettingsViewController {
    
    
    
}
