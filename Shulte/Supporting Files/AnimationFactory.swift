//
//  AnimationFactory.swift
//  25
//
//  Created by Ruslan Gritsenko on 28.01.2020.
//  Copyright © 2020 Ruslan Gritsenko. All rights reserved.
//

import UIKit

struct AnimationFactory {
    
    @discardableResult
    static func startWinking(view: UIView, delay: TimeInterval, fractionComplete: CGFloat = 0, completion: ((UIViewAnimatingPosition) -> Void)? = nil) -> UIViewPropertyAnimator {
        
        let animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 5, delay: delay, options: [], animations: {
            UIView.animateKeyframes(withDuration: 1, delay: 0, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
                    view.alpha = 0
                }
                UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                    view.alpha = 1
                }
            }, completion: nil)
        }, completion: completion)
        
        if fractionComplete != 0 {
            animator.fractionComplete = fractionComplete
        }
        
        return animator
    }
}
