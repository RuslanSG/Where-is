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
    private var inGame = false
    
    private lazy var cellView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var disappearingWinkAnimator = UIViewPropertyAnimator()
    var appearingWinkAnimator = UIViewPropertyAnimator()
    var setAnimator = UIViewPropertyAnimator()
    
    private let feedbackGenerator = FeedbackGenerator()
    
    enum WinkPhase {
        case disappearing
        case disappeared
        case appearing
    }
    
    var winkPhase: WinkPhase?
    
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
        if let userInfo = notification.userInfo, let inGame = userInfo[Notification.UserInfoKey.InGame] as? Bool {
            self.inGame = inGame
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
        
        /// Plays selection haptic feedback (only on devices with Haptic Feedback)
        if UIDevice.current.hasHapticFeedback {
            feedbackGenerator.playSelectionHapticFeedback()
        }
    }
    
    func uncompress(hapticFeedback: Bool? = nil, hiddenNumber: Bool = false) {
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
                    if self.numberFeedback && !hiddenNumber {
                        self.titleLabel?.alpha = 1.0
                    }
            })
            self.cellFrameX = nil
            self.cellFrameY = nil
            self.cellFrameWidth = nil
            self.cellFrameHeight = nil
        }
        
        /// If user tapped right number it plays selection haptic feedback (only on devices with Haptic Feedback) otherwise it plays error haptic feedback
        if let hapticFeedback = hapticFeedback {
            if hapticFeedback {
                if UIDevice.current.hasHapticFeedback {
                    self.feedbackGenerator.playSelectionHapticFeedback()
                }
            } else {
                self.feedbackGenerator.playNotificationHapticFeedback(notificationFeedbackType: .error)
            }
        }
    }
    
    func setBackgroundColor(to color: UIColor, animated: Bool) {
        let duration: Double = 0.2
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
        self.isEnabled = true

        if animated {
            let duration: Double = 0.2
            let delay: Double = 0.0
            
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
        self.isEnabled = false
        
        if animated {
            let duration = 0.2
            let delay = 0.0
            
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
    
    func winkNumber(completion: (() -> Void)?) {
        if  self.disappearingWinkAnimator.state != .stopped &&
            self.appearingWinkAnimator.state != .stopped &&
            !self.setAnimator.isRunning {
            let duration = 1.0
            let delay = 1.0
            let timing = UICubicTimingParameters(animationCurve: .easeInOut)
            
            /// Disappearing animation
            self.disappearingWinkAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
            
            self.disappearingWinkAnimator.addAnimations {
                self.titleLabel?.alpha = 0.0
            }
            
            self.disappearingWinkAnimator.addCompletion { (_) in
                /// Appearing animation
                self.appearingWinkAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
                
                self.appearingWinkAnimator.addAnimations {
                    self.titleLabel?.alpha = 1.0
                }
                
                self.appearingWinkAnimator.addCompletion { (_) in
                    self.winkPhase = nil
                    guard let completion = completion else { return }
                    completion()
                }
                
                self.winkPhase = .disappeared
                
                self.appearingWinkAnimator.startAnimation(afterDelay: 1.0)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    self.winkPhase = .appearing
                })
            }
            self.disappearingWinkAnimator.startAnimation()
            self.winkPhase = .disappearing
        } else {
            guard let completion = completion else { return }
            completion()
        }
    }
    
    func setNumber(_ number: Int, animated: Bool) {
        if animated {
            let durationIn = 0.1
            let durationOut = 0.4
            let timing = UICubicTimingParameters(animationCurve: .easeOut)
            
            /// Disappearing animation
            self.setAnimator = UIViewPropertyAnimator(duration: durationIn, timingParameters: timing)
            
            self.setAnimator.addAnimations {
                self.titleLabel?.alpha = 0.0
            }
            
            self.setAnimator.addCompletion { (_) in
                self.setTitle(String(number), for: .normal)
                self.tag = number
                
                /// Appearing animation
                self.setAnimator = UIViewPropertyAnimator(duration: durationOut, timingParameters: timing)
                
                self.setAnimator.addAnimations {
                    self.titleLabel?.alpha = 1.0
                }
                
                self.setAnimator.addCompletion({ (_) in
                    if self.appearingWinkAnimator.state == .stopped {
                        self.appearingWinkAnimator.finishAnimation(at: .end)
                    }
                })
                
                switch self.winkPhase {
                case .disappearing?:
                    self.disappearingWinkAnimator.finishAnimation(at: .end)
                case .appearing?:
                    self.setAnimator.startAnimation()
                case nil:
                    self.setAnimator.startAnimation()
                default:
                    break
                }
                
            }
            
            if self.winkPhase == .disappeared {
                self.setTitle(String(number), for: .normal)
                self.tag = number
                return
            } else if self.disappearingWinkAnimator.state == .active, self.disappearingWinkAnimator.isRunning {
                self.disappearingWinkAnimator.stopAnimation(false)
            } else if self.appearingWinkAnimator.state == .active, self.appearingWinkAnimator.isRunning {
                self.appearingWinkAnimator.stopAnimation(false)
            }
            self.setAnimator.startAnimation()
        } else {
            self.setTitle(String(number), for: .normal)
            self.tag = number
        }
    }
    
    func setNumberColor(to color: UIColor, animated: Bool) {
        let duration: Double = 0.2
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
        
        // cellView constraints
        self.cellView.translatesAutoresizingMaskIntoConstraints = false
        let cellViewTopConstraint = cellView.topAnchor.constraint(equalTo: self.topAnchor, constant: inset)
        let cellViewBottomConstraint = cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset)
        let cellViewTrailingConstraint = cellView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset)
        let cellViewLeadingConstraint = cellView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset)
        NSLayoutConstraint.activate([cellViewTopConstraint, cellViewBottomConstraint, cellViewTrailingConstraint, cellViewLeadingConstraint])
    }
    
}
