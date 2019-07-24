//
//  StartView.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/9/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class StartGameView: UIVisualEffectView {
    
    enum Style {
        case light
        case dark
    }
    
    private enum Strings {
        static let startButtonText = NSLocalizedString("Start", comment: "Start gmae button")
        static let goalText = NSLocalizedString("Time: ", comment: "Time given to find all of the numbers")
    }
    
    private var interval: Double
    
    private var blurEffect = UIBlurEffect() {
        didSet {
            effect = blurEffect
        }
    }
    private var vibrancyEffect = UIVibrancyEffect() {
        didSet {
            vibrancyView.effect = vibrancyEffect
        }
    }
    
    private let vibrancyView = UIVisualEffectView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.startButtonText
        label.font = .systemFont(ofSize: 35.0)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    init(interval: Double, style: StartGameView.Style) {
        self.interval = interval
        super.init(effect: nil)
        setupInputComponents()
        setStyle(style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func show() {
        guard isHidden else { return }
        isHidden = false
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: {
                        self.effect = self.blurEffect
                        self.vibrancyView.effect = self.vibrancyEffect
                        self.titleLabel.alpha = 1.0
        })
    }
    
    func hide() {
        guard !isHidden else { return }
        UIView.animate(withDuration: 0.15,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: {
                        self.effect = nil
                        self.titleLabel.alpha = 0.0
        },
                       completion: { (_) in
                        self.isHidden = true
        })
    }
    
    func setStyle(_ style: StartGameView.Style) {
        let blurStyle: UIBlurEffect.Style
        let vibrancyStyle: UIBlurEffect.Style
        
        switch style {
        case .light:
            blurStyle = .light
            vibrancyStyle = .extraLight
        case .dark:
            blurStyle = .dark
            vibrancyStyle = .dark
        }
        
        blurEffect = UIBlurEffect(style: blurStyle)
        vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: vibrancyStyle))
    }
    
    // MARK: - Private Methods
    
    private func setupInputComponents() {
        vibrancyView.contentView.addSubview(titleLabel)
        contentView.addSubview(vibrancyView)
        
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        vibrancyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        vibrancyView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        vibrancyView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
}
