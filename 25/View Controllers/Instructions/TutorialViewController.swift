//
//  TutorialViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 8/25/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol TutorialViewControllerDelegate: class {
    
    func doneButtonPressed(_ viewController: TutorialViewController)
}

class TutorialViewController: UIViewController {
    
    @IBOutlet var cells: [CellView]!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var findNumberLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    weak var delegate: TutorialViewControllerDelegate?
    
    private var numberToFind = 1
    private let maxNumberToFind = 10
    
    private var trainingCompleted = false
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCells()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            labels.forEach { $0.textColor = .label }
            doneButton.tintColor = .systemBlue
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cellPressed(_ sender: CellView) {
        guard let number = Int(sender.titleLabel!.text!) else { return }
        
        if number == maxNumberToFind {
            hideCellNumbers()
            findNumberLabel.text = "Awesome!"
            trainingCompleted = true
            showDoneButton()
        } else if number == numberToFind {
            sender.setNumber(number + cells.count, animateIfNeeded: false)
            numberToFind += 1
            findNumberLabel.text = "Find \(numberToFind)"
        }
        sender.compress()
    }
    
    @IBAction func cellReleased(_ sender: CellView) {
        sender.uncompress(showNumber: !trainingCompleted)
    }
    
    @IBAction func doneButtonPressed(_ sender: CellView) {
        delegate?.doneButtonPressed(self)
    }
    
    // MARK: - Helper Methods
    
    private func configureCells() {
        for cell in cells {
            cell.setCornerRadius(globalCornerRadius)
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
