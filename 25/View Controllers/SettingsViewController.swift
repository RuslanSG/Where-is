//
//  SettingsViewController.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/20/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

typealias LevelButton = UIButton

class SettingsViewController: UITableViewController {
    
    // MARK: - Public Properties
        
    var game: Game!
    
    // MARK: - Private Properties
    
    @IBOutlet private weak var doneButton: UIBarButtonItem!
    
    private var levelButtons = [LevelButton]()
    private var selectedLevelButton: LevelButton?
    
    private var levelButtonsStackView = UIStackView()
    
    private var levelButtonsGridParameters: (rows: Int, colums: Int) {
        if orientation == .portrait {
            return (rows: 2, colums: 5)
        } else {
            return (rows: 1, colums: 10)
        }
    }
    
    private let levelButtonSide: CGFloat = 44.0
    private let levelButtonTopConstraintConstant: CGFloat = 8.0
    private let levelButtonBottomConstraintConstant: CGFloat = 8.0
    
    private var firstTime = true
    
    // MARK: - Lifecycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstTime {
            configureLevelButtonsStackView()
            selectLevelButton(levelButtons[game.currentLevel.index], animated: false)
            firstTime = false
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateLevelButtonsStackViewConfiguration()
    }
    
    deinit {
        print("deinit: \(self)")
    }

    // MARK: - Actions
    
    @objc private func levelButtonPressed(_ sender: LevelButton) {
        game.setCurrentLevel(index: sender.tag)
        
        if sender !== selectedLevelButton {
            if let selectedLevelButton = selectedLevelButton {
                deselectLevelButton(selectedLevelButton, animated: true)
            }
            selectLevelButton(sender, animated: true)
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Hepler Methods
    
    private func configureLevelButtonsStackView() {
        configureLevelButtons(for: game)
        
        let verticalStackView = levelButtonsStackView
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .equalSpacing
        verticalStackView.alignment = .fill

        for i in 0..<levelButtonsGridParameters.rows {
            let horizontalStackView = UIStackView()
            horizontalStackView.axis = .horizontal
            horizontalStackView.distribution = .equalSpacing
            horizontalStackView.alignment = .fill

            for j in 0..<levelButtonsGridParameters.colums {
                let index = j + i * levelButtonsGridParameters.colums
                horizontalStackView.addArrangedSubview(levelButtons[index])
            }
            verticalStackView.addArrangedSubview(horizontalStackView)
        }
        
        let firstCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))!
        firstCell.contentView.addSubview(verticalStackView)

        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.topAnchor.constraint(equalTo: firstCell.contentView.topAnchor, constant: levelButtonTopConstraintConstant).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: firstCell.contentView.bottomAnchor, constant: -levelButtonBottomConstraintConstant).isActive = true
        verticalStackView.leftAnchor.constraint(equalTo: firstCell.contentView.leftAnchor, constant: 16.0).isActive = true
        verticalStackView.rightAnchor.constraint(equalTo: firstCell.contentView.rightAnchor, constant: -16.0).isActive = true
    }
    
    private func updateLevelButtonsStackViewConfiguration() {
        for rowStackView in levelButtonsStackView.arrangedSubviews as! [UIStackView] {
            rowStackView.removeFromSuperview()
        }
    
        for i in 0..<levelButtonsGridParameters.rows {
            let horizontalStackView = UIStackView()
            horizontalStackView.axis = .horizontal
            horizontalStackView.distribution = .equalSpacing
            horizontalStackView.alignment = .fill

            for j in 0..<levelButtonsGridParameters.colums {
                let index = j + i * levelButtonsGridParameters.colums
                horizontalStackView.addArrangedSubview(levelButtons[index])
            }
            
            levelButtonsStackView.addArrangedSubview(horizontalStackView)
        }
    }
    
    private func configureLevelButton(for level: Level) -> LevelButton {
        let fontSize: CGFloat = 25.0
        let cornerRadius: CGFloat = 10.0
        let title = String(level.serial)
        let side: CGFloat = 44.0

        let levelButton = LevelButton()
        
        if #available(iOS 13.0, *) {
            levelButton.setTitleColor(level.isAvailable ? view.tintColor : .systemGray3, for: .normal)
            levelButton.layer.borderColor = level.isAvailable ? view.tintColor.cgColor : UIColor.systemGray3.cgColor
        } else {
            levelButton.setTitleColor(level.isAvailable ? view.tintColor : .gray, for: .normal)
            levelButton.layer.borderColor = level.isAvailable ? view.tintColor.cgColor : UIColor.gray.cgColor
        }
        
        levelButton.setTitle(title, for: .normal)
        
        levelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        levelButton.layer.borderWidth = 2
        levelButton.tag = level.index
        levelButton.layer.cornerRadius = cornerRadius
        levelButton.isEnabled = level.isAvailable
        
        levelButton.addTarget(self, action: #selector(levelButtonPressed(_:)), for: .touchUpInside)
        
        levelButton.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = levelButton.heightAnchor.constraint(equalToConstant: side)
        let widthConstraint = levelButton.widthAnchor.constraint(equalToConstant: side)
        heightConstraint.priority = UILayoutPriority(rawValue: 999)
        widthConstraint.priority = UILayoutPriority(rawValue: 999)
        heightConstraint.isActive = true
        widthConstraint.isActive = true

        return levelButton
    }
    
    private func configureLevelButtons(for game: Game) {
        for level in game.levels {
            levelButtons.append(configureLevelButton(for: level))
        }
    }
    
    private func selectLevelButton(_ levelButton: LevelButton, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                levelButton.setTitleColor(.white, for: .normal)
                levelButton.backgroundColor = self.view.tintColor
            }
        } else {
            levelButton.setTitleColor(.white, for: .normal)
            levelButton.backgroundColor = view.tintColor
        }
        levelButton.isSelected = true
        selectedLevelButton = levelButton
    }
    
    private func deselectLevelButton(_ levelButton: LevelButton, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                levelButton.setTitleColor(self.view.tintColor, for: .normal)
                levelButton.backgroundColor = .clear
            }
        } else {
            levelButton.setTitleColor(view.tintColor, for: .normal)
            levelButton.backgroundColor = .clear
        }
        levelButton.isSelected = false
        selectedLevelButton = nil
    }
    
}

extension SettingsViewController {
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0, indexPath.section == 0 {
            if orientation == .portrait {
                return levelButtonTopConstraintConstant + levelButtonSide + 8.0 + levelButtonSide + levelButtonBottomConstraintConstant
            } else {
                return levelButtonTopConstraintConstant + levelButtonSide + levelButtonBottomConstraintConstant
            }
            
        }
        return 44.0
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1, indexPath.row == 0 {
            guard let instructionsViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: InstructionsViewController.self)) as? InstructionsViewController else { return }
            instructionsViewController.needsToShowWelcome = false
            present(instructionsViewController, animated: true)
        }
    }
    
}


