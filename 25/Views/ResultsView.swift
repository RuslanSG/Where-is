//
//  ResultsView.swift
//  25
//
//  Created by Ruslan Gritsenko on 02.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class ResultsView: UIVisualEffectView {
    
    var blur = UIBlurEffect()
    
    private let phrases = ["Уровень пройден!"]

    // MARK: - Subviews
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: label.font.fontName, size: 45)
        label.adjustsFontSizeToFitWidth = true
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
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
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
            self.titleLabel.text = self.phrases[self.phrases.count.arc4random]
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
        
    init(frame: CGRect) {
        super.init(effect: nil)
        
        self.frame = frame
        setupInputComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helping Methods
    
    private func setupInputComponents() {
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(actionButton)
        
        self.contentView.addConstraintsWithFormat(format: "H:|-30-[v0]-30-|", views: titleLabel)
        self.contentView.addConstraintsWithFormat(format: "V:|-100-[v0(50)]", views: titleLabel)
        
        let currentDeviceIsIPhoneX = UIDevice.current.platform == .iPhoneX || UIDevice.current.platform == .iPhoneXR || UIDevice.current.platform == .iPhoneXS || UIDevice.current.platform == .iPhoneXSMax
        self.contentView.addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: actionButton)
        self.contentView.addConstraintsWithFormat(format: currentDeviceIsIPhoneX ? "V:[v0(50)]-76-|" : "V:[v0(50)]-42-|", views: actionButton)
    }
    
}
