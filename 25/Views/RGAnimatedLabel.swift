//
//  RGAnimatedLabel.swift
//  25
//
//  Created by Ruslan Gritsenko on 1/4/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class RGAnimatedLabel: UILabel {

    var isAnimaing = false
    
    private var animator = UIViewPropertyAnimator()
    
    // MARK: - Actions
    
    func setText(_ text: String?, animated: Bool) {
        if animated {
            let durationIn = 0.2
            let durationOut = 0.2
            let delayIn = 0.0
            let delayOut = 0.0
            
            self.isAnimaing = true
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: durationIn,
                delay: delayIn,
                options: .curveEaseIn,
                animations: {
                    self.alpha = 0.0
            }) { (_) in
                self.text = text
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: durationOut,
                    delay: delayOut,
                    options: .curveEaseOut,
                    animations: {
                        self.alpha = 1.0
                }) { (_) in
                    self.isAnimaing = false
                }
            }
        } else {
            self.text = text
        }
    }
    
    func showAndHideText(_ text: String, duration: Double) {
        let delay = duration
        
        self.text = text
        self.isAnimaing = true
        
        let durationIn = 0.1
        let durationOut = 0.4
        let timing = UICubicTimingParameters(animationCurve: .easeOut)
        
        /// Disappearing animation
        self.animator = UIViewPropertyAnimator(duration: durationIn, timingParameters: timing)
        
        self.animator.addAnimations {
            self.alpha = 1.0
        }
        
        self.animator.addCompletion { (_) in
            self.animator = UIViewPropertyAnimator(duration: durationOut, timingParameters: timing)
            
            self.animator.addAnimations {
                self.alpha = 0.0
            }
            
            self.animator.addCompletion { (_) in
                self.text = nil
                self.isAnimaing = false
            }
            
            self.animator.startAnimation(afterDelay: delay)
        }
        self.animator.startAnimation()
    }
    
    func stopAnimation() {
        self.animator.stopAnimation(true)
        self.isAnimaing = false
    }

}
