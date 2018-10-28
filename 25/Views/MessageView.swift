//
//  MessageView.swift
//  25
//
//  Created by Ruslan Gritsenko on 05.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class MessageView: UIVisualEffectView {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.alpha = 0.0
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.alpha = 0.0
        return label
    }()
    
    var blur = UIBlurEffect()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 0
        return stackView
    }()
    
    init() {
        super.init(effect: nil)

        setupInputComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    private var animator = UIViewPropertyAnimator()
    
    func show() {
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
    
    @objc public func hide() {
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
            self.removeFromSuperview()
        }
        animator.startAnimation()
    }
    
    // MARK: - Helping Methods
    
    private func setupInputComponents() {
        contentView.addSubview(stackView)
        
        /// Stack view constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let stackViewHorizontalConstraint = stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let stackViewVerticalConstraint = stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        NSLayoutConstraint.activate([stackViewHorizontalConstraint, stackViewVerticalConstraint])
    }
    
}
