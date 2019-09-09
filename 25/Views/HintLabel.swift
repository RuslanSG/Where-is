//
//  TipLabel.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/4/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import UIKit

final class HintLabel: UILabel {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    // MARK: - Private Methods
    
    private func configure() {
        let labelTextColor: UIColor
        
//        if #available (iOS 13.0, *) {
//            labelTextColor = .label
//        } else {
            labelTextColor = .black
//        }
        
        textColor = labelTextColor
        adjustsFontSizeToFitWidth = true
        textAlignment = .center
        alpha = 0
        isHidden = true
    }
}
