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
    private var blur: UIBlurEffect! {
        didSet {
            self.effect = blur
        }
    }
    
    private var appearanceInfo = Appearance()
    
    init(appearanceInfo: Appearance) {
        super.init(effect: nil)
        
        self.blur = UIBlurEffect(style: appearanceInfo.darkMode ? .dark : .light)
        self.appearanceInfo = appearanceInfo
        
        setupInputComponents()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(darkModeStateChanged(notification:)),
            name: Notification.Name(NotificationName.darkModeStateDidChange.rawValue),
            object: nil
        )
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
    
    // MARK: - Notifications
    
    @objc private func darkModeStateChanged(notification: Notification) {
        setupColors()
    }
    
    // MARK: - Helping Methods
    
    private func setupInputComponents() {
        self.isUserInteractionEnabled = false
        
        contentView.addSubview(label)
        contentView.addConstraintsWithFormat(format: "H:|[v0]|", views: label)
        contentView.addConstraintsWithFormat(format: "V:|[v0]|", views: label)
        
        label.text = "Start"
        label.textColor = appearanceInfo.textColor
        label.font = UIFont.systemFont(ofSize: appearanceInfo.numbersFontSize)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.isOpaque = false
        label.isUserInteractionEnabled = true
        label.alpha = 0.0
    }
    
    private func setupColors() {
        if appearanceInfo.darkMode {
            blur = UIBlurEffect(style: .dark)
            label.textColor = appearanceInfo.textColor
        } else {
            blur = UIBlurEffect(style: .light)
            label.textColor = appearanceInfo.textColor
        }
    }
}
