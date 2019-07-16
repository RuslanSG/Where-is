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
        static let startButtonText = NSLocalizedString("Start", comment: "Start gmae button")
        static let goalText = NSLocalizedString("Time: ", comment: "Time given to find all of the numbers")
    }
    
    enum Style {
        case lightWithBlackText
        case lightWithWhiteText
        case darkWithWhiteText
    }
    
    private var goal: Double
    private var animator = UIViewPropertyAnimator()
    private var blur: UIBlurEffect! {
        didSet {
            effect = blur
        }
    }
    
    var heightConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.startButtonText
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.goalText + String(format: "%.2f", goal)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 0
        return stackView
    }()
    
    init(goal: Double, style: StartGameView.Style) {
        self.goal = goal
        super.init(effect: nil)
        setupInputComponents()
        setStyle(style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func show() {
        if !isHidden { return }
        isHidden = false
        let duration = 0.5
        animator.stopAnimation(true)
        animator = UIViewPropertyAnimator(
            duration: duration,
            curve: .easeOut,
            animations: {
                self.effect = self.blur
                self.titleLabel.alpha = 1.0
                self.detailLabel.alpha = 1.0
        })
        animator.startAnimation()
    }
    
    func hide() {
        if isHidden { return }
        let duration = 0.15
        animator.stopAnimation(true)
        animator = UIViewPropertyAnimator(
            duration: duration,
            curve: .easeOut,
            animations: {
                self.effect = nil
                self.titleLabel.alpha = 0.0
                self.detailLabel.alpha = 0.0
        })
        animator.addCompletion { (_) in
            self.isHidden = true
        }
        animator.startAnimation()
    }
    
    func setStyle(_ style: StartGameView.Style) {
        let blurStyle: UIBlurEffect.Style
        let textColor: UIColor
        
        switch style {
        case .lightWithBlackText:
            blurStyle = .light
            textColor = .black
        case .lightWithWhiteText:
            blurStyle = .light
            textColor = .white
        case .darkWithWhiteText:
            blurStyle = .dark
            textColor = .white
        }
        
        self.blur = UIBlurEffect(style: blurStyle)
        titleLabel.textColor = textColor
        detailLabel.textColor = textColor
    }
    
    // MARK: - Private Methods
    
    private func setupInputComponents() {
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
    }
    
}
