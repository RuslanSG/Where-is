//
//  ResultsView.swift
//  25
//
//  Created by Ruslan Gritsenko on 02.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class ResultsView: UIVisualEffectView {

    var userInterfaceColor: UIColor!
    var cornerRadius: CGFloat!
    var fontsColor: UIColor! {
        didSet {
            titleLabel.textColor = fontsColor
            timeLabel.textColor = fontsColor
        }
    }
    
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
        button.backgroundColor = userInterfaceColor
        button.layer.cornerRadius = cornerRadius
        button.setTitle("New Game", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.addTarget(self, action: #selector(hide), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Actions
    
    @objc private func hide() {
        titleLabel.text = nil
        timeLabel.text = nil
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.15,
            delay: 0.0,
            options: [],
            animations: {
                self.alpha = 0.0
        })
    }
    
    // MARK: - Initialization
    
    public init(frame: CGRect, effect: UIVisualEffect?, userInterfaceColor: UIColor, cornerRadius: CGFloat, fontsColor: UIColor) {
        super.init(effect: effect)
        self.frame = frame
        self.userInterfaceColor = userInterfaceColor
        self.cornerRadius = cornerRadius
        self.fontsColor = fontsColor
        setupInputComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helping Methods
    
    func setupInputComponents() {
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(actionButton)
        
        self.contentView.addConstraintsWithFormat(format: "H:|-30-[v0]-30-|", views: titleLabel)
        self.contentView.addConstraintsWithFormat(format: "V:|-100-[v0(35)]", views: titleLabel)
        
        let currentDeviceIsIPhoneX = UIScreen.main.nativeBounds.height == 2436
        self.contentView.addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: actionButton)
        self.contentView.addConstraintsWithFormat(format: currentDeviceIsIPhoneX ? "V:[v0(50)]-76-|" : "V:[v0(50)]-42-|", views: actionButton)
    }
    
}
