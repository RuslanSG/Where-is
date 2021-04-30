//
//  CellView.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/5/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

public class CellView: UIButton {
    
    // MARK: - Public Properties
    
    enum Style {
        case standart, colorful
    }
    
    enum HighlightReason {
        case goalAchieved, newRecord, notFound
    }
    
    var number = 0 {
        didSet {
            setTitle(String(number), for: .normal)
        }
    }
    
    override public var backgroundColor: UIColor? {
        set {
            contentView.backgroundColor = newValue
        }
        get {
            return contentView.backgroundColor
        }
    }
    
    override public var description: String {
        return "|\(number)|"
    }

    
    // MARK: - Private Properties
        
    private var contentView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private var contentViewInset: CGFloat = 0.0
    private var numberCurrentAlpha: CGFloat = 1.0
    
    private var winkAnimator: UIViewPropertyAnimator?
    private var isWinking = false
    
    // MARK: - Lifecycle
    
    init(frame: CGRect, contentViewInset: CGFloat) {
        self.contentViewInset = contentViewInset
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentViewInset = cellInset
        configure()
    }
    
    // MARK: - Public Methods
    
    func setNumber(_ number: Int, animated: Bool) {
        if animated {
            let duration = 0.33
            
            if let animator = winkAnimator {
                animator.pauseAnimation()
                let fractionComplete = animator.fractionComplete
                
                animator.stopAnimation(false)
                let currentAlpha = titleLabel!.alpha
                
                titleLabel?.alpha = 0
                self.number = number
                
                UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut], animations: {
                    self.titleLabel?.alpha = currentAlpha
                }) { (_) in
                    animator.finishAnimation(at: .current)
                    self.wink(fractionComplete: fractionComplete)
                }
            } else {
                titleLabel?.alpha = 0
                self.number = number
                
                UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut], animations: {
                    self.titleLabel?.alpha = 1
                })
            }
            return
        }
        self.number = number
        accessibilityIdentifier = "\(number)_button"
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
    
    func showNumber(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        if animated {
            UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseOut, animations: {
                self.titleLabel?.alpha = 1
            }, completion: completion)
        } else {
            titleLabel?.alpha = 1
        }
    }
    
    func hideNumber() {
        titleLabel?.alpha = 0
    }
    
    func startWinking(fractionComplete: CGFloat = 0) {
        isWinking = true
        wink(fractionComplete: fractionComplete)
    }
        
    func stopWinking() {
        defer { winkAnimator = nil }
        isWinking = false
        guard winkAnimator?.state != .stopped else {
            winkAnimator?.finishAnimation(at: .end)
            return
        }
        winkAnimator?.stopAnimation(true)
    }
    
    func compress() {
        transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        hideNumber()
    }
    
    func uncompress(showNumber: Bool = true) {
        UIView.animate(withDuration: 0.33) {
            self.transform = CGAffineTransform.identity
        }
        if showNumber {
            self.showNumber(animated: true)
        }
    }
    
    func highlight(reason: HighlightReason, duration: Double = 0) {
        let oldBackgroundColor = backgroundColor
        let oldTextColor = titleLabel?.textColor
        
        let backwardsAnimation = {
            UIView.animate(
                withDuration: 1,
                delay: duration,
                animations: {
                    self.backgroundColor = oldBackgroundColor
                },
                completion: { _ in
                    self.setTitleColor(oldTextColor, for: .normal)
                }
            )
        }
        
        switch reason {
        case .goalAchieved:
            backgroundColor = .systemGreen
            backwardsAnimation()
        case .newRecord:
            backgroundColor = .systemOrange
            backwardsAnimation()
        case .notFound:
            stopWinking()
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.setTitleColor(.white, for: .normal)
                    self.backgroundColor = .systemBlue
                    self.showNumber(animated: false)
                },
                completion: { _ in
                    backwardsAnimation()
                }
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func configure() {
        addSubview(contentView)
        backgroundColor = .clear
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 1
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.2
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: contentViewInset).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -contentViewInset).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -contentViewInset).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: contentViewInset).isActive = true
    }
    
    private func wink(fractionComplete: CGFloat = 0) {
        guard isWinking else { return }
        let delay = Double.random(in: 0...4)
        winkAnimator = AnimationFactory.startWinking(
            view: titleLabel!,
            delay: delay,
            fractionComplete: fractionComplete
        ) { position in
            guard position == .end else { return }
            self.wink()
        }
    }
}
