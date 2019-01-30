//
//  MessageView.swift
//  25
//
//  Created by Ruslan Gritsenko on 1/26/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

import UIKit

protocol MessageViewDelegate {
    func messageViewWillHide()
}

class MessageView: UIVisualEffectView {
    
    private enum Strings {
        static let Done = NSLocalizedString("Готово", comment: "Кнопка, которая закрывает меню")
        static let GoToInfinity = NSLocalizedString("Перейти к ∞", comment: "Кнопка, которая переводит в уровень 'бесконечность'")
        static let LeaveFeedbackButtonText = NSLocalizedString("Оставить отзыв", comment: "Это кнопка 'Оставить отзыв', которая переводит пользователя на страницу приложения в App Store")
    }
    
    var delegate: ResultsViewDelegate?

    var blur = UIBlurEffect()
    
    // MARK: - Subviews
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 35.0)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17.0)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    
    lazy var labels = [titleLabel, textLabel]
    
    var leaveFeedbackButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.LeaveFeedbackButtonText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 0.4
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(leaveFeedbackButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    var actionButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.Done, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        button.addTarget(self, action: #selector(hide), for: .touchUpInside)
        button.addTarget(self, action: #selector(actionButtonPressed(_:)), for: .touchDown)
        return button
    }()
    
    // MARK: - Actions
    
    private func show() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.3,
            delay: 0.0,
            options: [],
            animations: {
                self.effect = self.blur
        }) { (_) in
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.3,
                delay: 0.0,
                options: [],
                animations: {
                    self.contentView.subviews.forEach { $0.alpha = 1.0 }
            })
        }
    }
    
    public func show(title: String, text: String) {
        self.titleLabel.text = title
        self.textLabel.text = text
        self.actionButton.setTitle(Strings.GoToInfinity, for: .normal)

        self.show()
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
    
    @objc private func leaveFeedbackButtonPressed(_ sender: UIButton) {
        
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
        let topGap: CGFloat = 15.0
        let sideGap: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 20.0 : 80.0
        let bottomGap: CGFloat = UIDevice.current.hasLiquidRetina ? 50.0 : 30.0
        
        let titleLabelHeight: CGFloat = 100.0
//        let leaveFeedbackButtonHeight: CGFloat = 15.0
//        let leaveFeedbackButtonWidth: CGFloat = 150.0
        let actionButtonHeight: CGFloat = 50.0
        let textLabelHeight: CGFloat = self.bounds.size.height - titleLabelHeight - actionButtonHeight - topGap - bottomGap - sideGap * 2
        
        /// Adding subviews
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(textLabel)
        //self.contentView.addSubview(leaveFeedbackButton)
        self.contentView.addSubview(actionButton)
        
        /// titleLabel constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: topGap).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -sideGap).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: sideGap).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: titleLabelHeight).isActive = true
        
        /// textLabel constraints
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -sideGap).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: sideGap).isActive = true
        textLabel.heightAnchor.constraint(lessThanOrEqualToConstant: textLabelHeight).isActive = true
        
//        /// leaveFeedbackButton constraints
//        leaveFeedbackButton.translatesAutoresizingMaskIntoConstraints = false
//        leaveFeedbackButton.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
//        leaveFeedbackButton.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -10.0).isActive = true
//        leaveFeedbackButton.heightAnchor.constraint(equalToConstant: leaveFeedbackButtonHeight).isActive = true
//        leaveFeedbackButton.widthAnchor.constraint(equalToConstant: leaveFeedbackButtonWidth).isActive = true
        
        /// actionButton constraints
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -bottomGap).isActive = true
        actionButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -sideGap).isActive = true
        actionButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: sideGap).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: actionButtonHeight).isActive = true
        
        self.contentView.subviews.forEach { $0.alpha = 0.0 }
    }
    
}
