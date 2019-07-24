//
//  ResultsViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 7/23/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var vibrancyEffectView: UIVisualEffectView!
    @IBOutlet weak var numbersCountLabel: UILabel!
    @IBOutlet var labels: [UILabel]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showUIElements()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    // MARK: - Actions
    
    @IBAction func close() {
        hideUIElements {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - Private Methods
    
    private func showUIElements() {
        visualEffectView.effect = nil
        vibrancyEffectView.effect = nil
        labels.forEach { $0.alpha = 0 }
        
        
        let blur: UIBlurEffect
        let vibrancy: UIVibrancyEffect?
        
//        if #available(iOS 13.0, *) {
//            blur = UIBlurEffect(style: .systemThickMaterial)
//            vibrancy = UIVibrancyEffect(blurEffect: blur, style: .label)
//        } else {
//            blur = UIBlurEffect(style: .light)
//            vibrancy = nil
//        }
        
        blur = UIBlurEffect(style: .light)
        vibrancy = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .extraLight))
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: {
                        self.visualEffectView.effect = blur
                        self.vibrancyEffectView.effect = vibrancy
                        self.labels.forEach { $0.alpha = 1 }
        })
    }
    
    private func hideUIElements(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: {
                        self.visualEffectView.effect = nil
                        self.labels.forEach { $0.alpha = 0 }
        },
                       completion: { (_) in
                        completion()
        })
    }

}

extension ResultsViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
            return BlurryPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
