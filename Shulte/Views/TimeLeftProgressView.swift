//
//  TimeLeftView.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/5/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import UIKit

final class TimeLeftProgressView: UIView {
    
    // MARK: - Public Properties
    
    var trackColor: UIColor? {
        get {
            return backgroundColor
        }
        set {
            backgroundColor = newValue
        }
    }
    
    var progressColor: UIColor? {
        get {
            return progressView.backgroundColor
        }
        set {
            progressView.backgroundColor = newValue
        }
    }
    
    // MARK: - Private Properties
    
    private var progressView = UIView()
        
    private var topConstratintStandartConstant: CGFloat?
    private var heightConstratintStandartConstant: CGFloat?
        
    private var progressViewWidthConstraint: NSLayoutConstraint?
    
    private var firstTime = true
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    
    func show(animated: Bool) {
        guard isHidden else { return }
        
        if animated {
            let show = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
                self.alpha = 1
            }
            
            isHidden = false
            alpha = 0
            
            show.startAnimation()
        } else {
            alpha = 1
            isHidden = false
        }
    }
    
    func hide(animated: Bool) {
        guard !isHidden else { return }
                
        if animated {
            let hide = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
                self.alpha = 0
            }
            hide.addCompletion { (_) in
                self.isHidden = true
            }
            hide.startAnimation()
        } else {
            isHidden = true
        }
    }
    
    func startAnimation(duration: Double) {
        #if FASTLANE
        progressViewWidthConstraint?.constant = -bounds.size.width * 0.75
        #else
        progressViewWidthConstraint?.constant = -bounds.size.width
        #endif
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        self.layoutIfNeeded()
        })
    }
    
    func reset() {
        progressView.layer.removeAllAnimations()
        progressViewWidthConstraint?.constant = 0
        layoutIfNeeded()
    }
    
    func setCornerRadius(_ cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        progressView.layer.cornerRadius = cornerRadius
    }
    
    // MARK: - Private Methods
    
    private func configure() {
        addSubview(progressView)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        progressView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        progressViewWidthConstraint = progressView.widthAnchor.constraint(equalTo: widthAnchor)
        progressViewWidthConstraint?.isActive = true
                
        alpha = 0
        isHidden = true
        
        trackColor = .cellDefault
        progressColor = tintColor
    }
    
}
