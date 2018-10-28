//
//  MessageView.swift
//  25
//
//  Created by Ruslan Gritsenko on 05.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class MessageView: UIVisualEffectView {

    let label = UILabel()
    var blur = UIBlurEffect()
    
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
                self.label.alpha = 1.0
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
                self.label.alpha = 0.0
        })
        animator.addCompletion { (_) in
            self.removeFromSuperview()
        }
        animator.startAnimation()
    }
    
    // MARK: - Helping Methods
    
    private func setupInputComponents() {
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.alpha = 0.0
        
        contentView.addSubview(label)
        contentView.addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: label)
        contentView.addConstraintsWithFormat(format: "V:|[v0]|", views: label)
    }
    
}
