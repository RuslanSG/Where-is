//
//  LevelFailedViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/16/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import UIKit

class GameFinishedViewController: ResultsViewController {
    
    // MARK: - Public Properties
    
    var session: GameSession!
    
    // MARK: - Private Properties
    
    private var titleLabel = UILabel()
    private var titleImageView = UIImageView()
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
        if session.goalAchieved {
            if !session.level.isPassed {
                titleLabel.text = "LEVEL PASSED".uppercased()
            } else {
                titleLabel.text = "GAME OVER".uppercased()
            }
        } else {
            titleLabel.text = "GAME OVER".uppercased()
        }
        
        titleLabel.font = .systemFont(ofSize: 35, weight: .black)
        titleLabel.numberOfLines = 2
        titleLabel.alpha = 0.7
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.widthAnchor.constraint(equalToConstant: titleLabel.intrinsicContentSize.width).isActive = true
        
        let checkmarkImage = UIImage(named: "checkmark")?.withRenderingMode(.alwaysTemplate)
        let crossImage = UIImage(named: "cross")?.withRenderingMode(.alwaysTemplate)
        
        if session.goalAchieved {
            titleImageView.image = checkmarkImage
            titleImageView.tintColor = .systemGreen
        } else {
            titleImageView.image = crossImage
            titleImageView.tintColor = .systemRed
        }
        
        titleImageView.alpha = 0.7
        
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        titleImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        titleImageView.widthAnchor.constraint(equalTo: titleImageView.heightAnchor).isActive = true
                
        let titleLabelStackView = UIStackView(arrangedSubviews: [titleImageView, titleLabel])
        titleLabelStackView.axis = .horizontal
        titleLabelStackView.spacing = 16
                
        switch session.finishingReason {
        case .levelPassed:
            detailsLabel.text = "Goal Achieved"
        case .timeIsOver:
            detailsLabel.text = "Time Is Over"
        case .wrongNumberTapped:
             detailsLabel.text = "Wrong Number Tapped"
        default: break
        }
        
        if session.finishingReason != .levelPassed {
            detailsLabel.text! += session.goalAchieved ? "\n(Goal Achieved)" : "\n(Goal Not Achieved)"
        }
        
        detailsLabel.font = .systemFont(ofSize: 23, weight: .bold)
        detailsLabel.textAlignment = .center
        detailsLabel.numberOfLines = 0
        detailsLabel.alpha = titleLabel.alpha
        
        titleStackView = UIStackView(arrangedSubviews: [titleLabelStackView, detailsLabel])
        titleStackView.alignment = .center
        titleStackView.axis = .vertical
        titleStackView.spacing = 20
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.isUserInteractionEnabled = false
        
        view.addSubview(titleStackView)
        
        // Configure game session info
        let topSeparator = configureSeparator(height: 2)
        let bottomSeparator = configureSeparator(height: 2)
        
        let timeTakenStackView = configureRowStackView(title: "Time Taken",
                                                       value: session.timeTaken ?? -1.0)
            
        let numbersFoundStackView = configureRowStackView(title: "Numbers Found",
                                                          value: Double(session.numbersFound))
        
        let goalStackView = configureRowStackView(title: "Goal",
                                                  value: Double(session.level.goal))
        
        let recordStackView = configureRowStackView(title: "Record",
                                                    value: Double(session.level.record))
        
        let messageLabel = UILabel()
        if let nextLevelSerial = session.nextLevel?.serial, session.goalAchieved, !session.level.isPassed {
            messageLabel.text = "Level \(nextLevelSerial) is available!"
        } else {
            messageLabel.text = ""
        }
        messageLabel.font = .systemFont(ofSize: 17, weight: .medium)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.alpha = titleLabel.alpha
        
        gameSessionInfoStackView = UIStackView(arrangedSubviews: [topSeparator,
                                                                  numbersFoundStackView,
                                                                  goalStackView,
                                                                  recordStackView,
                                                                  timeTakenStackView,
                                                                  bottomSeparator,
                                                                  messageLabel])
        gameSessionInfoStackView.axis = .vertical
        gameSessionInfoStackView.spacing = 10
        gameSessionInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        gameSessionInfoStackView.isUserInteractionEnabled = false
        
        view.addSubview(gameSessionInfoStackView)
        
        configureConstraints()
    }
    
    // MARK: - Private Methods
    
    private func configureConstraints() {
        let margins = view.layoutMarginsGuide
        
        sharedConstraints.append(contentsOf: [
            titleStackView.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 16),
            gameSessionInfoStackView.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -16),
            gameSessionInfoStackView.centerYAnchor.constraint(equalTo: margins.centerYAnchor)
        ])
        
        regularConstraints.append(contentsOf: [
            titleStackView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 40),
            titleStackView.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -16),
            gameSessionInfoStackView.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 16),
        ])
        
        compactConstraints.append(contentsOf: [
            titleStackView.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            titleStackView.rightAnchor.constraint(equalTo: margins.centerXAnchor, constant: -16),
            gameSessionInfoStackView.leftAnchor.constraint(equalTo: margins.centerXAnchor, constant: 8),
        ])
        
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
