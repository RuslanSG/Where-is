//
//  CellView.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/5/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class CellView: UIButton {
    
    enum Style {
        case defaultWithWhiteNumber
        case defaultWithBlackNumber
        case colorfulWithWhiteNumber
        case colorfulWithColorfulNumber
    }
    
    enum AnimationSpeed {
        case slow
        case fast
    }
    
    var isAnimating = false
    var winkEnabled = true
    var number = 0
    
    override var backgroundColor: UIColor? {
        set {
            childView.backgroundColor = newValue
        }
        get {
            return childView.backgroundColor
        }
    }
    
    
    override var description: String {
        return "|\(number)|"
    }
    
    private enum NumberState {
        case visible
        case invisible
        case appearing
        case disappearing
    }
    
    private var disappearingAnimator: UIViewPropertyAnimator?
    private var appearingAnimator: UIViewPropertyAnimator?
    private var settingAnimator: UIViewPropertyAnimator?
    
    private var childView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private var inset: CGFloat
    private var numberState: NumberState = .visible
    
    // MARK: - Initialization
    
    init(inset: CGFloat) {
        self.inset = inset
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func setNumber(_ number: Int, animated: Bool, speed: CellView.AnimationSpeed = .fast) {
        self.number = number
        
        if !animated && !isAnimating {
            setTitle(String(number), for: .normal)
            return
        }
        
        let duranion1: Double
        let duration2: Double
        
        switch speed {
        case .slow:
            duranion1 = 0.3
            duration2 = 0.6
        case .fast:
            duranion1 = 0.1
            duration2 = 0.3
        }
        
        let easeIn = UICubicTimingParameters(animationCurve: .easeIn)
        let easeOut = UICubicTimingParameters(animationCurve: .easeOut)
        
        let animator1 = UIViewPropertyAnimator(duration: duranion1, timingParameters: easeIn)
        let animator2 = UIViewPropertyAnimator(duration: duration2, timingParameters: easeOut)
        
        animator1.addAnimations {
            self.titleLabel?.alpha = 0.0
        }
        
        animator1.addCompletion { (_) in
            /// Phase 2 (invisible)
            self.setTitle(String(number), for: .normal)
            if self.numberState != .invisible && self.isAnimating {
                self.settingAnimator = animator2
                self.settingAnimator?.startAnimation()
            } else {
                self.isAnimating = false
                self.winkEnabled = true
            }
        }
        
        animator2.addAnimations {
            /// Phase 3 (appearing)
            self.titleLabel?.alpha = 1.0
        }
        
        animator2.addCompletion { (_) in
            /// Phase 4 (visible)
            self.numberState = .visible
            self.isAnimating = false
            self.winkEnabled = true
            self.settingAnimator = nil
        }
        
        switch numberState {
        case .disappearing:
            disappearingAnimator?.stopAnimation(false)
            disappearingAnimator?.finishAnimation(at: .current)
        case .invisible:
            setTitle(String(number), for: .normal)
        case .appearing:
            appearingAnimator?.stopAnimation(false)
            if appearingAnimator?.state == .stopped {
                appearingAnimator?.finishAnimation(at: .current)
            }
        default:
            break
        }
        
        settingAnimator = animator1
        
        /// Phase 1 (disappearing)
        settingAnimator?.startAnimation()
        isAnimating = true
        winkEnabled = false
    }
    
    func setStyle(_ style: CellView.Style, animated: Bool) {
        var cellColors: [UIColor] = [.cellPurple, .cellRed, .cellYellow]
        
        let newCellColor: UIColor
        let newNumberColor: UIColor
        
        switch style {
        case .defaultWithWhiteNumber:
            newCellColor = .cellGrey
            newNumberColor = .white
        case .defaultWithBlackNumber:
            newCellColor = .cellGrey
            newNumberColor = .black
        case .colorfulWithWhiteNumber:
            newCellColor = cellColors[Int.random(in: cellColors.indices)]
            newNumberColor = .white
        case .colorfulWithColorfulNumber:
            newCellColor = cellColors[Int.random(in: cellColors.indices)]
            let index = cellColors.firstIndex(of: newCellColor)!
            cellColors.remove(at: index)
            newNumberColor = cellColors[Int.random(in: cellColors.indices)]
        }
        
        if !animated {
            self.backgroundColor = newCellColor
            self.setTitleColor(newNumberColor, for: .normal)
            return
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2,
                                                       delay: 0,
                                                       options: .curveEaseOut,
                                                       animations: {
                                                        self.childView.backgroundColor = newCellColor
                                                        self.setTitleColor(newNumberColor, for: .normal)
        })
    }
    
    func setCornerRadius(cornerRadius: CGFloat) {
        childView.layer.cornerRadius = cornerRadius
    }
    
    func showNumber(animated: Bool) {
        isEnabled = true
        
        if !animated {
            titleLabel?.alpha = 1.0
            numberState = .visible
            return
        }
        
        isAnimating = true
        winkEnabled = false
        numberState = .appearing
        
        let duration: Double = 0.2
        let delay: Double = 0.0
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: duration,
            delay: delay,
            options: .curveEaseIn,
            animations: {
                self.titleLabel?.alpha = 1.0
        }, completion: { (_) in
            self.isAnimating = false
            self.winkEnabled = true
            self.numberState = .visible
        })
    }
    
    func hideNumber(animated: Bool) {
        if !animated {
            titleLabel?.alpha = 0.0
            numberState = .invisible
            return
        }
        
        isAnimating = true
        winkEnabled = false
        numberState = .disappearing
        
        let duration = 0.2
        let delay = 0.0
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: duration,
            delay: delay,
            options: .curveEaseIn,
            animations: {
                self.titleLabel?.alpha = 0.0
        }, completion: { _ in
            self.isAnimating = false
            self.winkEnabled = true
            self.numberState = .invisible
        })
    }
    
    func wink() {
        let disappearingDuration = 0.5
        let disappearedDuration = 1.5
        let appearingDuration = 0.5
        let winkEnablingDelay = 1.0
        
        let easeIn = UICubicTimingParameters(animationCurve: .easeIn)
        let easeOut = UICubicTimingParameters(animationCurve: .easeOut)
        
        disappearingAnimator = UIViewPropertyAnimator(duration: disappearingDuration, timingParameters: easeIn)
        
        disappearingAnimator?.addAnimations {
            self.titleLabel?.alpha = 0.0
        }
        
        disappearingAnimator?.addCompletion { (_) in
            /// Phase 2 (invisible)
            self.numberState = .invisible
            guard self.isAnimating else { return }
            
            /// Phase 3 (appearing)
            self.appearingAnimator?.startAnimation(afterDelay: disappearedDuration)
            self.isAnimating = true
            self.winkEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + disappearedDuration, execute: {
                self.numberState = .appearing
            })
        }
        
        appearingAnimator = UIViewPropertyAnimator(duration: appearingDuration, timingParameters: easeOut)
        
        appearingAnimator?.addAnimations {
            self.titleLabel?.alpha = 1.0
        }
        
        appearingAnimator?.addCompletion { (_) in
            /// Final (visible)
            self.numberState = .visible
            self.isAnimating = false
            DispatchQueue.main.asyncAfter(deadline: .now() + winkEnablingDelay, execute: {
                self.winkEnabled = true
            })
        }
        
        guard !isAnimating, winkEnabled else { return }
        
        /// Phase 1 (disappearing)
        disappearingAnimator?.startAnimation()
        isAnimating = true
        winkEnabled = false
        numberState = .disappearing
    }
    
    func stopAnimations() {
        isAnimating = false
        winkEnabled = true
        
        appearingAnimator?.stopAnimation(true)
        disappearingAnimator?.stopAnimation(true)
        settingAnimator?.stopAnimation(true)
        
        appearingAnimator = nil
        disappearingAnimator = nil
        settingAnimator = nil
    }
    
    func compress() {
        UIView.animate(withDuration: 0.05) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        hideNumber(animated: false)
    }
    
    func uncompress(hideNumber: Bool = false) {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
        if !hideNumber {
            showNumber(animated: true)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        addSubview(childView)
        backgroundColor = .clear
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 1
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.5
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        childView.topAnchor.constraint(equalTo: self.topAnchor, constant: inset).isActive = true
        childView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset).isActive = true
        childView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset).isActive = true
        childView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset).isActive = true
    }
    
    
}
