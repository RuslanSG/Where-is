//
//  ResultsView.swift
//  25
//
//  Created by Ruslan Gritsenko on 02.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol ResultsViewDelegate {
    func resultsViewWillHide()
}

class ResultsView: UIVisualEffectView {
    
    var delegate: ResultsViewDelegate?
    
    var blur = UIBlurEffect()
    
    // MARK: - Subviews
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 45.0)
        label.adjustsFontSizeToFitWidth = true
        label.alpha = 0.0
        return label
    }()
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 90.0)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.alpha = 0.0
        return label
    }()
    
    private var detailTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 25.0)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.alpha = 0.0
        label.textColor = .green
        return label
    }()
    
    lazy var labels = [titleLabel, timeLabel]
    
    var actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        button.addTarget(self, action: #selector(hide), for: .touchUpInside)
        button.addTarget(self, action: #selector(actionButtonPressed(_:)), for: .touchDown)
        return button
    }()
    
    // MARK: - Actions
    
    public func show(withTime time: Double, goal: Double, difference: Double) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.3,
            delay: 0.0,
            options: [],
            animations: {
                self.effect = self.blur
        }) { (_) in
            let goalAchieved = time < goal
            self.titleLabel.text = goalAchieved ? "Цель \(goal) сек достигнута!" : "Цель \(goal) сек не достигнута"
            self.timeLabel.text = goalAchieved ? String(format: "%.02f", time) : "😢"
            self.detailTimeLabel.text = "-" + String(format: "%.02f", difference)
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.3,
                delay: 0.0,
                options: [],
                animations: {
                    self.contentView.subviews.forEach { $0.alpha = 1.0 }
            })
        }
    }
    
    @objc public func hide() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.3,
            delay: 0.0,
            options: [],
            animations: {
                self.effect = nil
                self.contentView.subviews.forEach { $0.alpha = 0.0 }
        }) { (position) in
            if position == .end {
                self.delegate?.resultsViewWillHide()
                self.removeFromSuperview()
            }
        }
    }
    
    @objc private func actionButtonPressed(_ sender: UIButton) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.03,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
                self.actionButton.alpha = 0.2
        })
    }
    
    // MARK: - Initialization
        
    init(frame: CGRect) {
        super.init(effect: nil)
        
        self.frame = frame
        setupInputComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helping Methods
    
    private func setupInputComponents() {
        
        let currentDeviceIsIPhoneX = UIDevice.current.platform == .iPhoneX ||
            UIDevice.current.platform == .iPhoneXR ||
            UIDevice.current.platform == .iPhoneXS ||
            UIDevice.current.platform == .iPhoneXSMax
        
        let topGap: CGFloat = 100.0
        let bottomGap: CGFloat = currentDeviceIsIPhoneX ? 76.0 : 42.0
        let sideGap: CGFloat = 10.0
        let actionButtonHeight: CGFloat = 50.0
        let timeLabelHeight: CGFloat = 100.0
        let detailTimeLabelHeight: CGFloat = 50.0
        
        // Adding subviews
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(detailTimeLabel)
        self.contentView.addSubview(actionButton)
        
        // titleLabel constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let titleLabelHorizontalConstraint = titleLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        let titleLabelTopConstraint = titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: topGap)
        let titleLabelTrailingConstraint = titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -sideGap)
        let titleLabelLeadingConstraint = titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: sideGap)
        NSLayoutConstraint.activate([titleLabelHorizontalConstraint, titleLabelTopConstraint, titleLabelTrailingConstraint, titleLabelLeadingConstraint])
        
        // timeLabel constraints
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        let timeLabelHorizontalConstraint = timeLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        let timeLabelVerticalConstraint = timeLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        let timeLabelTrailingConstraint = timeLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -sideGap)
        let timeLabelLeadingConstraint = timeLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: sideGap)
        let timeLabelHeightConstraint = timeLabel.heightAnchor.constraint(equalToConstant: timeLabelHeight)
        NSLayoutConstraint.activate([timeLabelHorizontalConstraint, timeLabelVerticalConstraint, timeLabelHeightConstraint, timeLabelTrailingConstraint, timeLabelLeadingConstraint])
        
        // detailTimeLabel constraints
        detailTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        let detailTimeLabelTopConstraint = detailTimeLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor)
        let detailTimeLabelTrailingConstraint = detailTimeLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -sideGap)
        let detailTimeLabelLeadingConstraint = detailTimeLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: sideGap)
        let detailTimeLabelHeightConstraint = detailTimeLabel.heightAnchor.constraint(equalToConstant: detailTimeLabelHeight)
        NSLayoutConstraint.activate([detailTimeLabelTopConstraint, detailTimeLabelTrailingConstraint, detailTimeLabelLeadingConstraint, detailTimeLabelHeightConstraint])

        // actionButton constraints
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        let actionButtonHorizontalConstraint = actionButton.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        let actionButtonBottomConstraint = actionButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -bottomGap)
        let actionButtonTrailingConstraint = actionButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -sideGap)
        let actionButtonLeadingConstraint = actionButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: sideGap)
        let actionButtonHeightConstraint = actionButton.heightAnchor.constraint(equalToConstant: actionButtonHeight)
        NSLayoutConstraint.activate([actionButtonHorizontalConstraint, actionButtonBottomConstraint, actionButtonTrailingConstraint, actionButtonLeadingConstraint, actionButtonHeightConstraint])
    }
    
}
