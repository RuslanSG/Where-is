//
//  CellView.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/5/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class CellView: UIButton {
    
    // MARK: - Public Properties
    
    enum Style {
        case standart, colorful
    }
    
    enum HighlightReason {
        case goalAchieved, newRecord
    }
    
    var isSetEnabled = true
    var isWinkEnabled = true
    var isSwapEnabled = true
    var number = 0
    
    override var backgroundColor: UIColor? {
        set {
            contentView.backgroundColor = newValue
        }
        get {
            return contentView.backgroundColor
        }
    }
    
    // MARK: - Private Properties
    
    override var description: String {
        return "|\(number)|"
    }
    
    private enum NumberState {
        case visible
        case invisible
        case appearing
        case disappearing
    }
    
    private var winkDisappearingAnimator: UIViewPropertyAnimator?
    private var winkAppearingAnimator: UIViewPropertyAnimator?
    
    private var setAppearingAnimator: UIViewPropertyAnimator?
    private var setDisappearingAnimator: UIViewPropertyAnimator?
    
    private var contentView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private var contentViewInset: CGFloat = 0.0
    private var numberState: NumberState = .visible
    private var numberCurrentAlpha: CGFloat = 1.0
    private var isWinking = false
    private var isSetting = false
    
    // MARK: - Lifecycle
    
    init(frame: CGRect, contentViewInset: CGFloat) {
        self.contentViewInset = contentViewInset
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentViewInset = globalCellInset
        configure()
    }
    
    // MARK: - Public Methods
    
    func setNumber(_ number: Int, animateIfNeeded: Bool) {
        self.number = number
        
        if !animateIfNeeded || (numberState == .invisible && isWinking) {
            setTitle(String(number), for: .normal)
            return
        }
        
        if numberState == .invisible {
            setTitle(String(number), for: .normal)
            isSetEnabled = false
            showNumber(animated: true) {
                self.isSetEnabled = true
            }
            return
        }
        
        let isWinking = self.isWinking
        let numberState = self.numberState
        
        setDisappearingAnimator = UIViewPropertyAnimator(duration: 0.1, curve: .easeInOut) {
            self.titleLabel?.alpha = 0.0
        }
        
        setAppearingAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            self.titleLabel?.alpha = isWinking ? self.numberCurrentAlpha : 1.0
        }
        
        setDisappearingAnimator?.addCompletion { (_) in
            self.setTitle(String(number), for: .normal)
            /// Phase 2 (appearing)
            self.setAppearingAnimator?.startAnimation()
        }
        
        setAppearingAnimator?.addCompletion { (_) in
            /// Phase 3 (visible)
            self.numberState = .visible
            self.isWinkEnabled = true
            self.isSetting = false
            
            if isWinking {
                self.wink(from: numberState, fractionComplete: 1.0)
            }
        }
        
        numberCurrentAlpha = titleLabel!.alpha
        removeWinkAnimations()
        
        /// Phase 1 (disappearing)
        setDisappearingAnimator?.startAnimation()
        
        isSetting = true
        isWinkEnabled = false
    }
    
    func setStyle(_ style: Style, animated: Bool) {
        var colorsForCells: [UIColor] = [.cellDefault, .cellRed]
        
        let newCellColor: UIColor
        let newNumberColor: UIColor
        
        switch style {
        case .standart:
            newCellColor = .cellDefault
            if #available(iOS 13.0, *) {
                newNumberColor = .label
            } else {
                newNumberColor = .black
            }
        case .colorful:
            newCellColor = colorsForCells[Int.random(in: colorsForCells.indices)]
            let index = colorsForCells.firstIndex(of: newCellColor)!
            colorsForCells.remove(at: index)
            newNumberColor = colorsForCells[Int.random(in: colorsForCells.indices)]
        }
        
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.contentView.backgroundColor = newCellColor
                self.setTitleColor(newNumberColor, for: .normal)
            }
        } else {
            backgroundColor = newCellColor
            setTitleColor(newNumberColor, for: .normal)
        }
    }
    
    func setCornerRadius(_ cornerRadius: CGFloat) {
        contentView.layer.cornerRadius = cornerRadius
    }
    
    func showNumber(animated: Bool, completion: (() -> Void)? = nil) {
        isEnabled = true
                if !animated {
            titleLabel?.alpha = 1.0
            numberState = .visible
            return
        }
        
        isWinkEnabled = false
        numberState = .appearing
        
        let show = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            self.titleLabel?.alpha = 1.0
        }
        show.addCompletion { (_) in
            self.isWinkEnabled = true
            self.numberState = .visible
            completion?()
        }
        show.startAnimation()
    }
    
    func hideNumber(animated: Bool) {
        if !animated {
            titleLabel?.alpha = 0.0
            numberState = .invisible
            return
        }
        
        isWinkEnabled = false
        numberState = .disappearing

        let hide = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            self.titleLabel?.alpha = 0.0
        }
        hide.addCompletion { _ in
            self.isWinkEnabled = true
            self.numberState = .invisible
        }
        hide.startAnimation()
    }
    
    func wink() {
        wink(from: .visible)
    }
    
    func removeAllAnimations() {
        removeWinkAnimations()
        removeSetAnimations()
    }
    
    func compress() {
        transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        hideNumber(animated: false)
    }
    
    func uncompress(showNumber: Bool = true) {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
        if showNumber {
            self.showNumber(animated: true)
        }
    }
    
    func highlight(reason: HighlightReason) {
        let oldBackgroundColor = backgroundColor
        
        if reason == .goalAchieved {
            backgroundColor = .systemGreen
        } else {
            backgroundColor = .systemOrange
        }
        
        UIView.animate(withDuration: 1) {
            self.backgroundColor = oldBackgroundColor
        }
    }
    
    // MARK: - Private Methods
    
    private func configure() {
        addSubview(contentView)
        backgroundColor = .clear
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 1
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.5
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: contentViewInset).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -contentViewInset).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -contentViewInset).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: contentViewInset).isActive = true
    }
    
    private func wink(from state: NumberState = .visible, fractionComplete: CGFloat = 1.0) {
        guard isWinkEnabled else { return }
        
        let disappearingDuration = 0.5 * Double(fractionComplete)
        let disappearedDuration = 1.5
        let appearingDuration = 0.5 * Double(fractionComplete)
        
        winkDisappearingAnimator = UIViewPropertyAnimator(duration: disappearingDuration, curve: .easeInOut) {
            self.titleLabel?.alpha = 0
        }
        
        winkDisappearingAnimator?.addCompletion { (_) in
            /// Phase 2 (invisible)
            self.numberState = .invisible
            
            self.winkDisappearingAnimator = nil
            
            guard self.isWinking else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + disappearedDuration, execute: {
                /// Phase 3 (appearing)
                self.winkAppearingAnimator?.startAnimation()
                self.numberState = .appearing
            })
        }
        
        winkAppearingAnimator = UIViewPropertyAnimator(duration: appearingDuration, curve: .easeInOut) {
            self.titleLabel?.alpha = 1
        }
        
        winkAppearingAnimator?.addCompletion { (_) in
            /// Final (visible)
            self.numberState = .visible
            self.isWinking = false
            self.winkAppearingAnimator = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.isWinkEnabled = true
            })
        }
        
        if state == .invisible || state == .appearing {
            winkAppearingAnimator?.startAnimation()
            numberState = .appearing
        } else {
            winkDisappearingAnimator?.startAnimation()
            numberState = .disappearing
        }
        
        isWinking = true
        isWinkEnabled = false
    }
    
    private func removeWinkAnimations() {
        isWinking = false
        isWinkEnabled = true
        
        winkAppearingAnimator?.stopAnimation(true)
        winkDisappearingAnimator?.stopAnimation(true)
        
        winkAppearingAnimator = nil
        winkDisappearingAnimator = nil
    }
    
    private func removeSetAnimations() {
        isSetting = false
        isWinkEnabled = true
        
        setAppearingAnimator?.stopAnimation(true)
        setDisappearingAnimator?.stopAnimation(true)
        
        setAppearingAnimator = nil
        setDisappearingAnimator = nil
    }
}
