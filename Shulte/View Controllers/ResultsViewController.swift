//
//  ResultsViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 7/23/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {
        
    internal var blurEffectView = UIVisualEffectView()
    internal var vibrancyEffectView = UIVisualEffectView()
    internal var tapAnywhereToHideLabel = UILabel()
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        show(animated: true)
    }
    
    deinit {
        print("deinit \(self)")
    }

    // MARK: - Actions
    
    @objc private func close() {
        hide { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - Public Methods
    
    func show(animated: Bool) {
        var blurEffect: UIBlurEffect
        var vibrancyEffect: UIVibrancyEffect
        
        if #available(iOS 13.0, *) {
            blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .quaternaryLabel)
        } else {
            blurEffect = UIBlurEffect(style: .light)
            vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .extraLight))
        }
        
        blurEffectView.effect = blurEffect
        if UIDevice.current.systemVersion.prefix(2) == "12" {
            blurEffectView.contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07)
        }
        vibrancyEffectView.effect = vibrancyEffect
        view.subviews.forEach { $0.alpha = 1 }
    }
    
    func hide(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.subviews.forEach { $0.alpha = 0 }
        }, completion: completion)
    }
    
    // MARK: - Helper Methods
    
    internal func configure() {
        // Configure blur effect view
        blurEffectView = UIVisualEffectView(effect: nil)
        
        view.addSubview(blurEffectView)
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        blurEffectView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        blurEffectView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        // Configure vibrancy effect view
        vibrancyEffectView = UIVisualEffectView(effect: nil)
        
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        
        let margins = view.layoutMarginsGuide
        
        vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyEffectView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        vibrancyEffectView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        vibrancyEffectView.leftAnchor.constraint(equalTo: blurEffectView.leftAnchor).isActive = true
        vibrancyEffectView.rightAnchor.constraint(equalTo: blurEffectView.rightAnchor).isActive = true
        
        // Configure "Tap anywhere to hide" label
        vibrancyEffectView.contentView.addSubview(tapAnywhereToHideLabel)
        tapAnywhereToHideLabel.text = NSLocalizedString("Tap anywhere to hide", comment: "Localized kind: hint label")
        tapAnywhereToHideLabel.textAlignment = .center
        tapAnywhereToHideLabel.font = .boldSystemFont(ofSize: 15)
        
        tapAnywhereToHideLabel.translatesAutoresizingMaskIntoConstraints = false
        tapAnywhereToHideLabel.centerXAnchor.constraint(equalTo: vibrancyEffectView.contentView.centerXAnchor).isActive = true
        tapAnywhereToHideLabel.bottomAnchor.constraint(equalTo: vibrancyEffectView.contentView.bottomAnchor, constant: -7).isActive = true
        tapAnywhereToHideLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
                
        // Configure gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        vibrancyEffectView.contentView.addGestureRecognizer(tap)
    }

}

extension ResultsViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
            return BlurryPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
