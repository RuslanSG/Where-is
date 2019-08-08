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
    
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var vibrancyEffectView: UIVisualEffectView!
    @IBOutlet private weak var numbersCountLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private var labels: [UILabel]!
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numbersCountLabel.text = String(numbersFound)
        if gameFinishingReason == .timeIsOver {
            titleLabel.text = "Time Is Over!"
        } else {
            titleLabel.text = "Wrong Number Tapped!"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        show()
    }
    
    deinit {
        print("deinit \(self)")
    }

    // MARK: - Actions
    
    @IBAction func close() {
        hide {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - Private Methods
    
    private func show() {
        visualEffectView.effect = nil
        vibrancyEffectView.effect = nil
        labels.forEach { $0.alpha = 0 }
        
        var blurEffect: UIBlurEffect
        var vibrancyEffect: UIVibrancyEffect
        
        if #available(iOS 13.0, *) {
            blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .secondaryLabel)
        } else {
            blurEffect = UIBlurEffect(style: .light)
            vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .extraLight))
            visualEffectView.contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07)
        }
        
        let blurAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            self.visualEffectView.effect = blurEffect
            self.vibrancyEffectView.effect = vibrancyEffect
            self.labels.forEach { $0.alpha = 1 }
        }
        blurAnimator.startAnimation()
    }
    
    private func hide(completion: @escaping () -> Void) {
        let blurAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            self.visualEffectView.effect = nil
            self.labels.forEach { $0.alpha = 0 }
        }
        blurAnimator.addCompletion { (_) in
            completion()
        }
        blurAnimator.startAnimation()
    }

}

extension ResultsViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
            return BlurryPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
