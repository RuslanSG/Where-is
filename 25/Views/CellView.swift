//
//  CellView.swift
//  25
//
//  Created by Ruslan Gritsenko on 19.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class CellView: UIButton {
    
    private enum ViewConstants {
        static let CompressionRatio: CGFloat = 0.90
    }
    
    var number = "?"
    var inset: CGFloat = 0.0
    
    private var cellFrameX: CGFloat?
    private var cellFrameY: CGFloat?
    private var cellFrameHeight: CGFloat?
    private var cellFrameWidth: CGFloat?
    
    private var numberFeedback = true
    private var showNumber = true

    private lazy var cellView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, inset: CGFloat) {
        super.init(frame: frame)
        
        self.inset = inset
        
        setupInputComponents()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(inGameStateDidChange(notification:)),
            name: Notification.Name.InGameStateDidChange,
            object: nil
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notifications
    
    @objc private func inGameStateDidChange(notification: Notification) {
        if let userInfo = notification.userInfo, let showNumber = userInfo[Notification.UserInfoKey.InGame] as? Bool {
            self.showNumber = showNumber
        }
    }
    
}

extension CellView {
    
    // MARK: - Cell
    
    func compress(numberFeedback: Bool) {
        self.numberFeedback = numberFeedback
        
        cellFrameX = self.frame.minX
        cellFrameY = self.frame.minY
        cellFrameWidth = self.frame.width
        cellFrameHeight = self.frame.height
        
        let compressionRatio = ViewConstants.CompressionRatio
        
        let newCellFrameX = self.frame.minX + self.frame.width * CGFloat(1 - compressionRatio) / 2
        let newCellFrameY = self.frame.minY + self.frame.height * CGFloat(1 - compressionRatio) / 2
        let newCellFrameWidth = self.frame.width * CGFloat(compressionRatio)
        let newCellFrameHeight = self.frame.height * CGFloat(compressionRatio)
        
        let duration: Double = 0.05
        let delay: Double = 0.0
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: duration,
            delay: delay,
            options: [],
            animations: {
                self.frame = CGRect(
                    x: newCellFrameX,
                    y: newCellFrameY,
                    width: newCellFrameWidth,
                    height: newCellFrameHeight
                )
                if self.numberFeedback {
                    self.titleLabel?.alpha = 0.2
                }
        })
    }
    
    func uncompress() {
        let duration: Double = 0.4
        let delay: Double = 0.0
        
        if  let cellFrameX = self.cellFrameX,
            let cellFrameY = self.cellFrameY,
            let cellFrameWidth = self.cellFrameWidth,
            let cellFrameHeight = self.cellFrameHeight {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: duration,
                delay: delay,
                options: .curveEaseOut,
                animations: {
                    self.frame = CGRect(
                        x: cellFrameX,
                        y: cellFrameY,
                        width: cellFrameWidth,
                        height: cellFrameHeight
                    )
                    if self.numberFeedback {
                        self.titleLabel?.alpha = 1.0
                    }
            })
            self.cellFrameX = nil
            self.cellFrameY = nil
            self.cellFrameWidth = nil
            self.cellFrameHeight = nil
        }
    }
    
    func setBackgroundColor(to color: UIColor, animated: Bool) {
        let duration: Double = 0.1
        let delay: Double = 0.0
        
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: duration,
                delay: delay,
                options: [],
                animations: {
                    self.cellView.backgroundColor = color
            })
        } else {
            self.cellView.backgroundColor = color
        }
    }
    
    func setCornerRadius(to cornerRadius: CGFloat) {
        self.cellView.layer.cornerRadius = cornerRadius
    }
    
    // MARK: - Number
    
    func showNumber(animated: Bool) {
        self.isUserInteractionEnabled = true
        
        let duration: Double = 0.2
        let delay: Double = 0.0
        
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: duration,
                delay: delay,
                options: .curveEaseIn,
                animations: {
                    self.titleLabel?.alpha = 1.0
            })
        } else {
            self.titleLabel?.alpha = 1.0
        }
    }
    
    func hideNumber(animated: Bool) {
        let duration: Double = 0.2
        let delay: Double = 0.0
        
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: duration,
                delay: delay,
                options: .curveEaseIn,
                animations: {
                    self.titleLabel?.alpha = 0.0
            })
        } else {
            self.titleLabel?.alpha = 0.0
        }
    }
    
    func winkNumber(duration: Double, delay: Double) {
        let durationIn: Double = duration / 2
        let durationOut: Double = duration / 2
        let delayIn: Double = 0.0
        let delayOut: Double = delay
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: durationIn,
            delay: delayIn,
            options: .curveEaseIn,
            animations: {
                self.titleLabel?.alpha = 0.0
        }) { (_) in
            if self.showNumber {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: durationOut,
                    delay: delayOut,
                    options: .curveEaseOut,
                    animations: {
                        self.titleLabel?.alpha = 1.0
                })
            }
        }
    }
    
    func setNumber(_ number: Int, animated: Bool) {
        let durationIn: Double = 0.1
        let durationOut: Double = 0.35
        let delayIn: Double = 0.0
        let delayOut: Double = 0.0
        
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: durationIn,
                delay: delayIn,
                options: .curveEaseIn,
                animations: {
                    self.titleLabel?.alpha = 0.0
            }) { (position) in
                self.setTitle(String(number), for: .normal)
                self.tag = number
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: durationOut,
                    delay: delayOut,
                    options: .curveEaseOut,
                    animations: {
                        self.titleLabel?.alpha = 1.0
                })
            }
        } else {
            self.setTitle(String(number), for: .normal)
            self.tag = number
        }
    }
    
    func setNumberColor(to color: UIColor, animated: Bool) {
        let duration: Double = 0.1
        let delay: Double = 0.0
        
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: duration,
                delay: delay,
                options: .curveEaseInOut,
                animations: {
                    self.setTitleColor(color, for: .normal)
            })
        } else {
            self.setTitleColor(color, for: .normal)
        }
    }
}

extension CellView {
    // MARK: - Helping Methods
    
    private func setupInputComponents() {
        self.addSubview(cellView)
        
        self.backgroundColor = .clear
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.alpha = 0.0
        
        self.cellView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraintsWithFormat(
            format: "H:|-\(inset)-[v0]-\(inset)-|",
            views: cellView
        )
        self.addConstraintsWithFormat(
            format: "V:|-\(inset)-[v0]-\(inset)-|",
            views: cellView
        )
    }
    
}
