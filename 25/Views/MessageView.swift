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
    
    private var darkMode: Bool! {
        didSet {
            setupColors()
        }
    }
    
    init(style: UIBlurEffect.Style) {
        super.init(effect: nil)
        
        self.blur = UIBlurEffect(style: style)
                
        contentView.addSubview(label)
        contentView.addConstraintsWithFormat(format: "H:|[v0]|", views: label)
        contentView.addConstraintsWithFormat(format: "V:|[v0]|", views: label)
        
        label.text = "Start"
        label.font = UIFont.systemFont(ofSize: 30.0)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.isOpaque = false
        label.isUserInteractionEnabled = true
        label.alpha = 0.0
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(darkModeStateChanged(notification:)),
            name: Notification.Name(DarkModeStateDidChangeNotification),
            object: nil
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    public func show() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.15,
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
    
    // MARK: - DarkModeStateChangedNotification
    
    @objc private func darkModeStateChanged(notification: Notification) {
        let darkModeNewState = notification.userInfo?[DarkModeStateUserInfoKey] as? Bool
        if darkMode != darkModeNewState {
            darkMode = darkModeNewState
        }
    }
    
    // MARK: - Helping Methods
    
    private func setupColors() {
        if darkMode {
            blur = UIBlurEffect(style: .dark)
            label.textColor = .white
        } else {
            blur = UIBlurEffect(style: .light)
            label.textColor = .black
        }
    }
}
