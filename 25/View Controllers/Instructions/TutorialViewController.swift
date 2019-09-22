//
//  TutorialViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 8/25/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol TutorialViewControllerDelegate: class {
    
    func tutorialViewController(_ tutorialViewController: TutorialViewController, doneButtonDidPress doneButton: UIButton)
    func tutorialViewController(_ tutorialViewController: TutorialViewController, closeButtonDidPress closeButton: UIButton)
}

class TutorialViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: TutorialViewControllerDelegate?
    
    var showCloseButtonNeeded = false
    
    // MARK: - Private Properties
    
    @IBOutlet private var cells: [CellView]!
    @IBOutlet private var labels: [UILabel]!
    @IBOutlet private weak var findNumberLabel: UILabel!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    
    // MARK: - Private Properties
    
    private var numberToFind = 1
    private let maxNumberToFind = 10
    private var trainingCompleted = false
    
    private let feedbackGenerator = FeedbackGenerator()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCells()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            labels.forEach { $0.textColor = .label }
            doneButton.tintColor = .systemBlue
        }
        
        if !showCloseButtonNeeded {
            closeButton.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cellPressed(_ sender: CellView) {
        guard let number = Int(sender.titleLabel!.text!) else { return }
        
        if number == maxNumberToFind {
            hideCellNumbers()
            findNumberLabel.text = NSLocalizedString("Awesome!", comment: "Localized kind: awesome label")
            trainingCompleted = true
            showDoneButton()
            feedbackGenerator.playSucceessFeedback()
        } else if number == numberToFind {
            sender.setNumber(number + cells.count, animateIfNeeded: false)
            numberToFind += 1
            findNumberLabel.text = NSLocalizedString("Find", comment: "Localized kind: find %number%") + " " + String(numberToFind)
            feedbackGenerator.playSelectionFeedback()
        }
        sender.compress()
    }
    
    @IBAction func cellReleased(_ sender: CellView) {
        sender.uncompress(showNumber: !trainingCompleted)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        delegate?.tutorialViewController(self, doneButtonDidPress: sender)
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        delegate?.tutorialViewController(self, closeButtonDidPress: sender)
    }
    
    // MARK: - Helper Methods
    
    private func configureCells() {
        for cell in cells {
            cell.setCornerRadius(cellCornerRadius)
            cell.setStyle(.colorful, animated: false)
        }
    }
    
    private func hideCellNumbers() {
        cells.forEach { $0.hideNumber(animated: true) }
    }
    
    private func showDoneButton() {
        doneButton.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.doneButton.alpha = 1
        }
    }

}
