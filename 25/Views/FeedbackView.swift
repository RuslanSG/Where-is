//
//  FeedbackView.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/27/18.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class FeedbackView: UIView {

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.alpha = 0.25
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    public func playErrorFeedback() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.1,
            delay: 0.0,
            options: [],
            animations: {
                self.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.1490196078, blue: 0.1215686275, alpha: 1)
        }) { (position) in
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.1,
                delay: 0.0,
                options: [],
                animations: {
                    self.backgroundColor = .clear
            })
        }
    }

}
