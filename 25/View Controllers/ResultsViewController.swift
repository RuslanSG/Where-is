//
//  ResultsViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 7/23/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {
    
    var numbersFound: Int!
    var gameFinishingReason: GameFinishingReason!
    
    private var blurEffectView = UIVisualEffectView()
    private var vibrancyEffectView = UIVisualEffectView()
    private var numbersCountLabel = UILabel()
    private var numbersFoundLabel = UILabel()
    private var tapAnywhereToHideLabel = UILabel()
    private var titleLabel = UILabel()
    private var labels = [UILabel]()
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numbersCountLabel.text = String(numbersFound)
        configureUI()
        configureGestureRecognizer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        show()
    }
    
    deinit {
        print("deinit \(self)")
    }

    // MARK: - Actions
    
    @objc private func close() {
        hide {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - Private Methods
    
    private func show() {
        var blurEffect: UIBlurEffect
        var vibrancyEffect: UIVibrancyEffect
        
//        if #available(iOS 13.0, *) {
//            blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
//            vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .secondaryLabel)
//        } else {
            blurEffect = UIBlurEffect(style: .light)
            vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .extraLight))
            blurEffectView.contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07)
//        }
        
        let blurAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            self.blurEffectView.effect = blurEffect
            self.vibrancyEffectView.effect = vibrancyEffect
            self.labels.forEach { $0.alpha = 1 }
        }
        blurAnimator.startAnimation()
    }
    
    private func hide(completion: @escaping () -> Void) {
        let blurAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            self.blurEffectView.effect = nil
            self.labels.forEach { $0.alpha = 0 }
        }
        blurAnimator.addCompletion { (_) in
            completion()
        }
        blurAnimator.startAnimation()
    }
    
    // MARK: - Helper Methods
    
    private func configureUI() {
        /// Configure blur effect view
        blurEffectView = UIVisualEffectView(effect: nil)
        
        view.addSubview(blurEffectView)
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        blurEffectView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        blurEffectView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        /// Configure vibrancy effect view
        vibrancyEffectView = UIVisualEffectView(effect: nil)
        
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        
        let margins = view.layoutMarginsGuide
        
        vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyEffectView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        vibrancyEffectView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        vibrancyEffectView.leftAnchor.constraint(equalTo: blurEffectView.leftAnchor).isActive = true
        vibrancyEffectView.rightAnchor.constraint(equalTo: blurEffectView.rightAnchor).isActive = true
        
        /// Configure title lable
        vibrancyEffectView.contentView.addSubview(titleLabel)
        if gameFinishingReason == .timeIsOver {
            titleLabel.text = "Time Is Over!"
        } else if gameFinishingReason == .wrongNumberTapped {
            titleLabel.text = "Wrong Number Tapped!"
        } else {
            titleLabel.text = "Level Passed!"
        }
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 30)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: vibrancyEffectView.contentView.topAnchor, constant: 30).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: vibrancyEffectView.contentView.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: vibrancyEffectView.contentView.rightAnchor).isActive = true
        
        labels.append(titleLabel)
        
        /// Configure numbers count label
        vibrancyEffectView.contentView.addSubview(numbersCountLabel)
        numbersCountLabel.text = String(numbersFound)
        numbersCountLabel.textAlignment = .center
        numbersCountLabel.font = .systemFont(ofSize: 80)
        
        numbersCountLabel.translatesAutoresizingMaskIntoConstraints = false
        numbersCountLabel.centerXAnchor.constraint(equalTo: vibrancyEffectView.contentView.centerXAnchor).isActive = true
        numbersCountLabel.centerYAnchor.constraint(equalTo: vibrancyEffectView.contentView.centerYAnchor).isActive = true
        
        labels.append(numbersCountLabel)
        
        /// Configure "Numbers Found" label
        vibrancyEffectView.contentView.addSubview(numbersFoundLabel)
        numbersFoundLabel.text = "Numbers Found:"
        numbersFoundLabel.textAlignment = .center
        numbersFoundLabel.font = .systemFont(ofSize: 15)
        
        numbersFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        numbersFoundLabel.centerXAnchor.constraint(equalTo: vibrancyEffectView.contentView.centerXAnchor).isActive = true
        numbersFoundLabel.bottomAnchor.constraint(equalTo: numbersCountLabel.topAnchor, constant: -10).isActive = true
        
        labels.append(numbersFoundLabel)
        
        /// Configure "Tap anywhere to hide" label
        vibrancyEffectView.contentView.addSubview(tapAnywhereToHideLabel)
        tapAnywhereToHideLabel.text = "Tap anywhere to hide"
        tapAnywhereToHideLabel.textAlignment = .center
        tapAnywhereToHideLabel.font = .boldSystemFont(ofSize: 15)
        
        tapAnywhereToHideLabel.translatesAutoresizingMaskIntoConstraints = false
        tapAnywhereToHideLabel.centerXAnchor.constraint(equalTo: vibrancyEffectView.contentView.centerXAnchor).isActive = true
        tapAnywhereToHideLabel.bottomAnchor.constraint(equalTo: vibrancyEffectView.contentView.bottomAnchor, constant: -7).isActive = true
        
        labels.append(tapAnywhereToHideLabel)
    }
    
    private func configureGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        vibrancyEffectView.contentView.addGestureRecognizer(tap)
    }

}

extension ResultsViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
            return BlurryPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
