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
    
    public func show() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.4,
            delay: 0.0,
            options: [],
            animations: {
                self.effect = self.blur
                self.label.alpha = 1.0
        })
    }
    
    @objc public func hide() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.15,
            delay: 0.0,
            options: [],
            animations: {
                self.effect = nil
                self.label.alpha = 0.0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Helping Methods
    
    private func setupInputComponents() {
        label.text = "Старт"
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.alpha = 0.0
        
        contentView.addSubview(label)
        contentView.addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: label)
        contentView.addConstraintsWithFormat(format: "V:|[v0]|", views: label)
    }
    
}
