//
//  ResultsView.swift
//  25
//
//  Created by Ruslan Gritsenko on 02.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class ResultsView: UIVisualEffectView {

    private var appearance = Appearance()
    private var blur = UIBlurEffect()

    // MARK: - Subviews
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: label.font.fontName, size: 45)
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 250.0, height: 100.0))
        label.center = self.center
        label.textAlignment = .center
        label.font = UIFont(name: label.font.fontName, size: 90)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("New Game", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.addTarget(self, action: #selector(hide), for: .touchUpInside)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchDown)
        return button
    }()
    
    // MARK: - Actions
    
    public func show(withTime time: Double) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.3,
            delay: 0.0,
            options: [],
            animations: {
                self.effect = self.blur
        }) { (_) in
            self.titleLabel.text = time < 60.0 ? "Excellent!" : "Almost there!"
            self.timeLabel.text = String(format: "%.02f", time)
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.3,
                delay: 0.0,
                options: [],
                animations: {
                    self.contentView.subviews.forEach { $0.alpha = 1.0 }
            })
        }
    }
    
    @objc public func hide() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.3,
            delay: 0.0,
            options: [],
            animations: {
                self.effect = nil
                self.contentView.subviews.forEach { $0.alpha = 0.0 }
        }) { (_) in
            self.actionButton.alpha = 0.0
            self.removeFromSuperview()
        }
    }
    
    @objc private func actionButtonPressed() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.03,
            delay: 0.0,
            options: [],
            animations: {
                self.actionButton.alpha = 0.2
        })
        
    }
    
    // MARK: - Initialization
        
    public init(frame: CGRect, appearance: Appearance) {
        super.init(effect: nil)
        
        self.frame = frame
        self.appearance = appearance
        setupInputComponents()
        setupColors()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(darkModeStateChanged(notification:)),
            name: Notification.Name(StringKeys.NotificationName.darkModeStateDidChange.rawValue),
            object: nil
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - DarkModeStateChangedNotification
    
    @objc private func darkModeStateChanged(notification: Notification) {
        setupColors()
    }
    
    // MARK: - Helping Methods
    
    private func setupInputComponents() {
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(actionButton)
        
        self.contentView.addConstraintsWithFormat(format: "H:|-30-[v0]-30-|", views: titleLabel)
        self.contentView.addConstraintsWithFormat(format: "V:|-100-[v0(35)]", views: titleLabel)
        
        let currentDeviceIsIPhoneX = UIScreen.main.nativeBounds.height == 2436
        self.contentView.addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: actionButton)
        self.contentView.addConstraintsWithFormat(format: currentDeviceIsIPhoneX ? "V:[v0(50)]-76-|" : "V:[v0(50)]-42-|", views: actionButton)
    }
    
    private func setupColors() {
        if appearance.darkMode {
            blur = UIBlurEffect(style: .dark)
            titleLabel.textColor = .white
            timeLabel.textColor = .white
        } else {
            blur = UIBlurEffect(style: .light)
            titleLabel.textColor = .black
            timeLabel.textColor = .black
        }
    }
    
}
