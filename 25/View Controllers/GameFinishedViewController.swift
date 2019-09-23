//
//  LevelFailedViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/16/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class GameFinishedViewController: ResultsViewController {
    
    // MARK: - Public Properties
    
    var session: GameSession!
    
    // MARK: - Private Properties
    
    private var titleLabel = UILabel()
    private var titleStackView = UIStackView()
    private var gameSessionInfoStackView = UIStackView()
    private var detailsLabel = UILabel()
    private var messageLabel = UILabel()
    
    private var compactConstraints = [NSLayoutConstraint]()
    private var regularConstraints = [NSLayoutConstraint]()
    private var sharedConstraints = [NSLayoutConstraint]()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        if session.levelPassed, session.level.serial == 2 {
            SKStoreReviewController.requestReview()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if !sharedConstraints[0].isActive {
            NSLayoutConstraint.activate(sharedConstraints)
        }
        
        if traitCollection.verticalSizeClass == .compact  {
            if regularConstraints.count > 0 && regularConstraints[0].isActive {
                NSLayoutConstraint.deactivate(regularConstraints)
            }
            NSLayoutConstraint.activate(compactConstraints)
        } else {
            if compactConstraints.count > 0 && compactConstraints[0].isActive {
                NSLayoutConstraint.deactivate(compactConstraints)
            }
            NSLayoutConstraint.activate(regularConstraints)
        }
    }

    // MARK: - Private Methods
    
    override func configure() {
        super.configure()
        
        // Configure title
        if session.levelPassed {
            titleLabel.text = NSLocalizedString("LEVEL PASSED", comment: "Localized kind: title label").uppercased()
        } else {
            titleLabel.text = NSLocalizedString("GAME OVER", comment: "Localized kind: title label").uppercased()
        }
        
        titleLabel.font = .systemFont(ofSize: 35, weight: .black)
        titleLabel.numberOfLines = 2
        titleLabel.alpha = 0.7
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
                
        switch session.finishingReason {
        case .timeIsOver:
            detailsLabel.text = NSLocalizedString("Time Is Over", comment: "Localized kind: game finishing reason label")
        case .wrongNumberTapped:
             detailsLabel.text = NSLocalizedString("Wrong Number Tapped", comment: "Localized kind: game finishing reason label")
        default: break
        }
        
        detailsLabel.font = .systemFont(ofSize: 23, weight: .bold)
        detailsLabel.textAlignment = .center
        detailsLabel.numberOfLines = 0
        detailsLabel.alpha = titleLabel.alpha
        
        titleStackView = UIStackView(arrangedSubviews: [titleLabel, detailsLabel])
        titleStackView.alignment = .fill
        titleStackView.axis = .vertical
        titleStackView.spacing = 20
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.isUserInteractionEnabled = false
        
        view.addSubview(titleStackView)
        
        // Configure game session info
        
        let goalAchievedLabel = UILabel()
        goalAchievedLabel.font = .systemFont(ofSize: 20, weight: .bold)
        goalAchievedLabel.alpha = titleLabel.alpha
        
        if session.goalAchieved {
            goalAchievedLabel.text = NSLocalizedString("Goal Achieved", comment: "Localized kind: info label")
        } else {
            goalAchievedLabel.text = NSLocalizedString("Goal Not Achieved", comment: "Localized kind: info label")
        }

        let goalAchievedImageView = UIImageView()
        
        let checkmarkImage = UIImage(named: "checkmark")?.withRenderingMode(.alwaysTemplate)
        let crossImage = UIImage(named: "cross")?.withRenderingMode(.alwaysTemplate)
        
        if session.goalAchieved {
            goalAchievedImageView.image = checkmarkImage
            goalAchievedImageView.tintColor = .systemGreen
        } else {
            goalAchievedImageView.image = crossImage
            goalAchievedImageView.tintColor = .systemRed
        }
        
        goalAchievedImageView.alpha = 0.7
        goalAchievedImageView.contentMode = .scaleAspectFit
        goalAchievedImageView.translatesAutoresizingMaskIntoConstraints = false
        goalAchievedImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        goalAchievedImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
                
        let goalAchievedStackView = UIStackView(arrangedSubviews: [goalAchievedImageView, goalAchievedLabel])
        goalAchievedStackView.axis = .horizontal
        goalAchievedStackView.spacing = 8
        
        let separator1 = configureSeparator(height: 2)
        let separator2 = configureSeparator(height: 2)
        
        let timeTakenStackView = configureRowStackView(title: NSLocalizedString("Time Taken", comment: "Localized kind: game session info label"),
                                                       value: session.timeTaken ?? -1.0)
            
        let numbersFoundStackView = configureRowStackView(title: NSLocalizedString("Numbers Found", comment: "Localized kind: game session info label"),
                                                          value: Double(session.numbersFound))
        
        let goalStackView = configureRowStackView(title: NSLocalizedString("Goal", comment: "Localized kind: game session info label"),
                                                  value: Double(session.level.goal))
        
        let recordStackView = configureRowStackView(title: NSLocalizedString("Record", comment: "Localized kind: game session info label"),
                                                    value: Double(session.level.record))
        
        if session.hasNewRecord {
            let recordTextLabel = recordStackView.arrangedSubviews[0] as! UILabel
            recordTextLabel.text! += " NEW"
            let stringToAttribute = "NEW"
            let attributedTextRange = (recordTextLabel.text! as NSString).range(of: stringToAttribute)
            let attributedString = NSMutableAttributedString(string: recordTextLabel.text!)
            attributedString.addAttribute(.foregroundColor,
                                          value: UIColor.systemOrange,
                                          range: attributedTextRange)
            attributedString.addAttribute(.font,
                                          value: UIFont.systemFont(ofSize: recordTextLabel.font.pointSize,
                                                                   weight: .black),
                                          range: attributedTextRange)
            recordTextLabel.attributedText = attributedString
        }
        
        let messageLabel = UILabel()
        if let nextLevelSerial = session.nextLevel?.serial, session.levelPassed {
            messageLabel.text = String(format: NSLocalizedString("Level %d is available!" , comment: "Localized kind: game session info label"), nextLevelSerial)
        } else {
            messageLabel.text = ""
        }
        messageLabel.font = .systemFont(ofSize: 17, weight: .medium)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.alpha = titleLabel.alpha
        
        gameSessionInfoStackView = UIStackView(arrangedSubviews: [goalAchievedStackView,
                                                                  separator1,
                                                                  numbersFoundStackView,
                                                                  goalStackView,
                                                                  recordStackView,
                                                                  timeTakenStackView,
                                                                  separator2,
                                                                  messageLabel])
        gameSessionInfoStackView.axis = .vertical
        gameSessionInfoStackView.spacing = 10
        gameSessionInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        gameSessionInfoStackView.isUserInteractionEnabled = false
        
        view.addSubview(gameSessionInfoStackView)
        
        configureConstraints()
    }
        
    private func configureConstraints() {
        let margins = view.layoutMarginsGuide
        
        let gameSessionInfoStackViewRightConstraint = gameSessionInfoStackView.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -16)
        gameSessionInfoStackViewRightConstraint.priority = UILayoutPriority(999)
        
        let gameSessionInfoStackViewLeftConstraint = gameSessionInfoStackView.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -16)
        gameSessionInfoStackViewLeftConstraint.priority = UILayoutPriority(999)
        
        sharedConstraints.append(contentsOf: [
            titleStackView.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 16),
            gameSessionInfoStackViewRightConstraint,
            gameSessionInfoStackView.centerYAnchor.constraint(equalTo: margins.centerYAnchor)
        ])
        
        regularConstraints.append(contentsOf: [
            titleStackView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 40),
            titleStackView.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -16),
            gameSessionInfoStackViewLeftConstraint,
            gameSessionInfoStackView.centerXAnchor.constraint(equalTo: margins.centerXAnchor)
        ])
        
        compactConstraints.append(contentsOf: [
            titleStackView.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            titleStackView.rightAnchor.constraint(equalTo: margins.centerXAnchor, constant: -16),
            gameSessionInfoStackView.leftAnchor.constraint(equalTo: margins.centerXAnchor, constant: 8)
        ])
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            gameSessionInfoStackView.widthAnchor.constraint(equalToConstant: 400).isActive = true
        }
    }
    
    private func configureSeparator(height: CGFloat) -> UIView {
        let separator = UIView()
        if #available(iOS 13.0, *) {
            separator.backgroundColor = .label
        } else {
            separator.backgroundColor = .black
        }
        separator.alpha = 0.5
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: height).isActive = true
        separator.layer.cornerRadius = height / 2
        
        return separator
    }
    
    private func configureRowStackView(title: String, value: Double) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        titleLabel.alpha = 0.7
        
        let stringValue: String
        
        let valueIsInteger = floor(value) == value
        if valueIsInteger {
            stringValue = String(Int(value))
        } else {
            stringValue = String(format: "%.2f", value)
        }
        
        let valueLabel = UILabel()
        
        valueLabel.text = stringValue
        valueLabel.font = .systemFont(ofSize: titleLabel.font.pointSize, weight: .heavy)
        valueLabel.textAlignment = .right
        
        let rowStackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        rowStackView.axis = .horizontal
        rowStackView.spacing = 5
        
        return rowStackView
    }
    
    
}
