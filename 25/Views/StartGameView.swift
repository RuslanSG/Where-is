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
    
    var interval = 0.0
    
    private var vibrancyEffectView = UIVisualEffectView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.startButtonText
        label.font = .systemFont(ofSize: 35.0)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    init() {
        super.init(effect: nil)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func show() {
        guard isHidden else { return }
        isHidden = false
        isUserInteractionEnabled = true
        
        let effects = getEffects()
        
        let blurAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            self.effect = effects.blur
            self.vibrancyEffectView.effect = effects.vibrancy
            self.titleLabel.alpha = 1
        }
        
        blurAnimator.startAnimation()
    }
    
    func hide() {
        guard !isHidden else { return }
        isUserInteractionEnabled = false
        
        let blurAnimator = UIViewPropertyAnimator(duration: 0.1, curve: .easeOut) {
            self.effect = nil
            self.titleLabel.alpha = 0
        }
        blurAnimator.addCompletion { (_) in
            self.isHidden = true
        }
        blurAnimator.startAnimation()
    }
    
    // MARK: - Private Methods
    
    private func configureUI() {
        let effects = getEffects()
        
        effect = effects.blur
        vibrancyEffectView.effect = effects.vibrancy
        
        contentView.addSubview(vibrancyEffectView)
        vibrancyEffectView.contentView.addSubview(titleLabel)
        
        vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyEffectView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        vibrancyEffectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        vibrancyEffectView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        vibrancyEffectView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    private func getEffects() -> (blur: UIBlurEffect, vibrancy: UIVibrancyEffect) {
        var blurEffect: UIBlurEffect
        var vibrancyEffect: UIVibrancyEffect
        
        if #available(iOS 13.0, *) {
            blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .secondaryLabel)
        } else {
            blurEffect = UIBlurEffect(style: .light)
            vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        }
        
        return (blur: blurEffect, vibrancy: vibrancyEffect)
    }
    
}
