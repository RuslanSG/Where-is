//
//  CellView.swift
//  25
//
//  Created by Ruslan Gritsenko on 19.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class CellView: UIButton {
    public var number: Int!
    
    private var appearance = Appearance()
    private var game = Game()
    
    private var buttonFrameX: CGFloat?
    private var buttonFrameY: CGFloat?
    private var buttonFrameHeight: CGFloat?
    private var buttonFrameWidth: CGFloat?

    private lazy var cellView: UIView = {
        let view = UIView()
        view.backgroundColor = game.colorfulCellsMode ? appearance.randomColor : appearance.defaultCellsColor
        view.layer.cornerRadius = appearance.cornerRadius
        view.isUserInteractionEnabled = false
        return view
    }()
    
    // MARK: - Initialization
    
    public init(frame: CGRect, appearance: Appearance, game: Game) {
        super.init(frame: frame)
        
        self.appearance = appearance
        self.game = game
        
        setupInputComponents()
        setupColors()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(darkModeStateChanged(notification:)),
            name: Notification.Name(StringKeys.NotificationName.darkModeStateDidChange.rawValue),
            object: nil
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Cell
    
    public func compress() {
        buttonFrameX = self.frame.minX
        buttonFrameY = self.frame.minY
        buttonFrameWidth = self.frame.width
        buttonFrameHeight = self.frame.height
        
        let newButtonFrameX = self.frame.minX + self.frame.width * CGFloat(1 - appearance.cellCompressionRatio) / 2
        let newButtonFrameY = self.frame.minY + self.frame.height * CGFloat(1 - appearance.cellCompressionRatio) / 2
        let newButtonFrameWidth = self.frame.width * CGFloat(appearance.cellCompressionRatio)
        let newButtonFrameHeight = self.frame.height * CGFloat(appearance.cellCompressionRatio)
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.05,
            delay: 0.0,
            options: [],
            animations: {
                self.frame = CGRect(
                    x: newButtonFrameX,
                    y: newButtonFrameY,
                    width: newButtonFrameWidth,
                    height: newButtonFrameHeight
                )
                if !self.game.winkNumbersMode {
                    self.titleLabel?.alpha = 0.2
                }
        })
    }
    
    public func uncompress() {
        if let buttonFrameX = self.buttonFrameX,
            let buttonFrameY = self.buttonFrameY,
            let buttonFrameWidth = self.buttonFrameWidth,
            let buttonFrameHeight = self.buttonFrameHeight {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.4,
                delay: 0.0,
                options: .curveEaseOut,
                animations: {
                    self.frame = CGRect(
                        x: buttonFrameX,
                        y: buttonFrameY,
                        width: buttonFrameWidth,
                        height: buttonFrameHeight
                    )
                    if self.game.inGame, !self.game.shuffleNumbersMode, !self.game.winkNumbersMode {
                        self.titleLabel?.alpha = 1.0
                    }
            })
            self.buttonFrameX = nil
            self.buttonFrameY = nil
            self.buttonFrameWidth = nil
            self.buttonFrameHeight = nil
        }
    }
    
    public func updateBackgroundColor(animated: Bool, to color: UIColor? = nil) {
        let colorChanger = {
            if let color = color {
                self.cellView.backgroundColor = color
            } else {
                self.cellView.backgroundColor = self.game.colorfulCellsMode ? self.appearance.randomColor :
                                                                              self.appearance.defaultCellsColor
            }
        }
        
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.1,
                delay: 0.0,
                options: [],
                animations: {
                    colorChanger()
            })
        } else {
            colorChanger()
        }
    }
    
    // MARK: - Number
    
    public func showNumber(animated: Bool) {
        self.isEnabled = true
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.2,
                delay: 0.0,
                options: [],
                animations: {
                    self.titleLabel?.alpha = 1.0
            })
        } else {
            self.titleLabel?.alpha = 1.0
        }
    }
    
    public func hideNumber(animated: Bool) {
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.2,
                delay: 0.0,
                options: [],
                animations: {
                    self.titleLabel?.alpha = 0.0
            })
        } else {
            self.titleLabel?.alpha = 0.0
        }
    }
    
    public func winkNumber(duration: Double, delay: Double) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: duration / 2,
            delay: 0.0,
            options: [],
            animations: {
                self.titleLabel?.alpha = 0.0
        }) { (_) in
            if self.game.inGame {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: duration / 2,
                    delay: delay,
                    options: [],
                    animations: {
                        self.titleLabel?.alpha = 1.0
                })
            }
        }
    }
    
    public func updateNumber(to number: Int, animated: Bool) {
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.1,
                delay: 0.0,
                options: [],
                animations: {
                    self.titleLabel?.alpha = 0.0
            }) { (position) in
                self.setTitle(String(number), for: .normal)
                self.tag = number
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: [],
                    animations: {
                        self.titleLabel?.alpha = 1.0
                })
            }
        } else {
            self.setTitle(String(number), for: .normal)
            self.tag = number
        }
    }
    
    public func updateNumberColor(animated: Bool) {
        let colorChanger = {
            var newColor = UIColor()
            if self.game.colorfulNumbersMode, self.game.colorfulCellsMode {
                if  let color = self.cellView.backgroundColor,
                    let anotherColor = self.appearance.getAnotherColor(for: color) {
                    newColor = anotherColor
                }
            } else if self.game.colorfulCellsMode {
                newColor = .white
            } else {
                newColor = self.appearance.textColor
            }
            self.setTitleColor(newColor, for: .normal)
        }
        
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.1,
                delay: 0.0,
                options: [],
                animations: {
                    colorChanger()
            })
        } else {
            colorChanger()
        }
    }
    
    // MARK: - Notifications
    
    @objc private func darkModeStateChanged(notification: Notification) {
        updateColors()
    }

    // MARK: - Helping Methods
    
    private func setupInputComponents() {
        self.addSubview(cellView)
        
        self.backgroundColor = .clear
        self.titleLabel?.font = UIFont.systemFont(ofSize: appearance.numbersFontSize)
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.alpha = 0.0
        
        let inset = appearance.gridInset
        
        self.addConstraintsWithFormat(
            format: "H:|-\(inset)-[v0]-\(inset)-|",
            views: cellView
        )
        self.addConstraintsWithFormat(
            format: "V:|-\(inset)-[v0]-\(inset)-|",
            views: cellView
        )
    }
    
    private func setupColors() {
        guard let currentColor = self.backgroundColor else { return }
        
        let cellColor = game.colorfulCellsMode ? appearance.randomColor : appearance.defaultCellsColor
        let numberColor = game.colorfulNumbersMode ? appearance.getAnotherColor(for: currentColor) : appearance.textColor
        
        self.setTitleColor(numberColor, for: .normal)
        self.cellView.backgroundColor = cellColor
    }
    
    private func updateColors() {
        if game.colorfulCellsMode {
            guard let currentColor = cellView.backgroundColor else { return }
            cellView.backgroundColor = appearance.switchColorForAnotherScheme(currentColor)
        } else {
            updateBackgroundColor(animated: true)
        }
        updateNumberColor(animated: true)
    }
    
}
