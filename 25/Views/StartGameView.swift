//
//  StartView.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/9/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class StartGameView: UIVisualEffectView {
    
    private enum Strings {
        static let titleText = NSLocalizedString("Start", comment: "Start gmae button")
        static let detailsText = NSLocalizedString("Time: ", comment: "Time given to find all of the numbers")
    }
    
    // MARK: - Public Properties
    
    var level: Level! {
        didSet {
            updateDetails()
        }
    }
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: cellNumbersFontSize * 0.85, weight: .heavy)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    var detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: cellNumbersFontSize * 0.4, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.alpha = 0.7
        return label
    }()
    
    // MARK: - Private Properties
    
    private let titleLabelDefaultAlpha: CGFloat = 1.0
    private let detailsLabelDefaultAlpha: CGFloat = 0.7
        
    // MARK: - Initialization
    
    init(level: Level) {
        self.level = level
        super.init(effect: nil)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func show() {
        guard isHidden else { return }
        isHidden = false
        isUserInteractionEnabled = true
                
        let blurAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            if #available(iOS 13.0, *) {
                self.effect = UIBlurEffect(style: .systemUltraThinMaterial)
            } else {
                self.effect = UIBlurEffect(style: .light)
            }
            self.titleLabel.alpha = self.titleLabelDefaultAlpha
            self.detailsLabel.alpha = self.detailsLabelDefaultAlpha
        }
        blurAnimator.startAnimation()
    }
    
    func hide() {
        guard !isHidden else { return }
        isUserInteractionEnabled = false
        
        let blurAnimator = UIViewPropertyAnimator(duration: 0.1, curve: .easeOut) {
            self.effect = nil
            self.titleLabel.alpha = 0
            self.detailsLabel.alpha = 0
        }
        blurAnimator.addCompletion { (_) in
            self.isHidden = true
        }
        blurAnimator.startAnimation()
    }
    
    // MARK: - Private Methods
    
    private func configure() {
        if #available(iOS 13.0, *) {
            effect = UIBlurEffect(style: .systemUltraThinMaterial)
        } else {
            effect = UIBlurEffect(style: .light)
        }
    
        titleLabel.text = "START"
        
        updateDetails()
                
        let stackView = UIStackView(arrangedSubviews: [titleLabel, detailsLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .fill
        stackView.alignment = .center
        
        contentView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func updateDetails() {
        if level.isPassed {
            detailsLabel.text = "Record: \(level.record)"
        } else {
            detailsLabel.text = "Find \(level.goal) Numbers"
        }
    }
}
