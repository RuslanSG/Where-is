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
    
    private enum Strings {
        static let Done = NSLocalizedString("Готово", comment: "Кнопка, которая закрывает меню")
        static let GoalAcieved = NSLocalizedString("Цель в %.1f сек достигнута!", comment: "")
        static let GoalNotAcieved = NSLocalizedString("Цель в %.1f сек не достигнута", comment: "")
        static let OnceAgain = NSLocalizedString("Еще раз", comment: "Еще попытка")
        static let GameOver = NSLocalizedString("Игра окончена! Найдено цифр:", comment: "")
        static let Record = NSLocalizedString("Рекорд:", comment: "Рекодный счет в игре")
        static let Fine = NSLocalizedString("Штраф: +", comment: "Штраф за неправильно нажатые цифры")
    }
    
    var delegate: ResultsViewDelegate?
    
    var blur = UIBlurEffect()
    
    private let sadEmojies = ["😢", "😭", "😤", "😠", "😡", "🤬", "🤯", "🥵", "😱", "😨", "😰", "😥", "😓", "😐", "😶", "😧", "🤮", "💩", "😒", "😞", "😔"]
    
    // MARK: - Subviews
    
    let levelLabel: UILabel = {
        let label = UILabel()
        let cornerRadius: CGFloat = 10.0
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 40.0)
        label.textAlignment = .center
        label.layer.cornerRadius = cornerRadius
        label.clipsToBounds = true
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 35.0, weight: UIFont.Weight.light) //boldSystemFont(ofSize: 35.0)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 90.0)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private var detailTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 25.0)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .green
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 2.0
        label.layer.shadowOpacity = 0.2
        label.layer.shadowOffset = CGSize(width: 0.8, height: 0.8)
        label.layer.masksToBounds = false
        return label
    }()
    
    private var fineTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 25.0)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .red
        return label
    }()
    
    lazy var labels = [titleLabel, timeLabel]
    
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
    
    func show(withTime time: Double, level: Int, goal: Double, difference: Double, fine: Double) {
        self.levelLabel.text = level == 0 ? "∞" : String(level)
        self.titleLabel.text = String(format: Strings.GoalAcieved, goal)
        self.timeLabel.text = String(format: "%.2f", time)
        self.detailTimeLabel.text = "-" + String(format: "%.2f", abs(difference))
        fineTimeLabel.textColor = .red
        self.fineTimeLabel.attributedText = fine > 0.0 ? attributedTextForFineLabel(fine: fine) : NSAttributedString()
        self.actionButton.setTitle(Strings.Done, for: .normal)
        
        self.show()
    }
    
    func show(level: Int, goal: Double, fine: Double) {
        self.levelLabel.text = level == 0 ? "∞" : String(level)
        self.titleLabel.text = String(format: Strings.GoalNotAcieved, goal)
        let randomSadEmojie = self.sadEmojies[self.sadEmojies.count.arc4random]
        self.timeLabel.text = randomSadEmojie
        self.detailTimeLabel.text = ""
        fineTimeLabel.textColor = .red
        self.fineTimeLabel.attributedText = fine > 0.0 ? attributedTextForFineLabel(fine: fine) : NSAttributedString()
        self.actionButton.setTitle(Strings.OnceAgain, for: .normal)
        
        self.show()
    }
    
    public func show(level: Int, score: Int, record: Int) {
        self.levelLabel.text = level == 0 ? "∞" : String(level)
        self.titleLabel.text = Strings.GameOver
        self.timeLabel.text = String(score)
        self.detailTimeLabel.text = ""
        fineTimeLabel.textColor = titleLabel.textColor
        self.fineTimeLabel.text = Strings.Record + " " + String(record)
        self.actionButton.setTitle(Strings.Done, for: .normal)
        
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
        let topGap: CGFloat = 45.0
        let sideGap: CGFloat = 20.0
        let bottomGap: CGFloat = UIDevice.current.hasLiquidRetina ? 40.0 : 20.0
        
        let levelLabelHeight: CGFloat = 70.0
        let titleLabelHeight: CGFloat = 70.0
        let titleLabelWidth: CGFloat = 200.0
        let timeLabelHeight: CGFloat = 100.0
        let detailTimeLabelHeight: CGFloat = 50.0
        let fineTimeLabelHeight: CGFloat = 50.0
        let actionButtonHeight: CGFloat = 50.0
        
        /// Adding subviews
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(detailTimeLabel)
        self.contentView.addSubview(fineTimeLabel)
        self.contentView.addSubview(actionButton)
        
        let margins = self.contentView.layoutMarginsGuide
        
        /// levelLabel constraints
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.heightAnchor.constraint(equalToConstant: levelLabelHeight).isActive = true
        levelLabel.widthAnchor.constraint(equalToConstant: levelLabelHeight).isActive = true
        
        /// titleLabel constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.heightAnchor.constraint(equalToConstant: levelLabelHeight).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: titleLabelWidth).isActive = true
        
        /// timeLabel constraints
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -sideGap).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: sideGap).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: timeLabelHeight).isActive = true
        
        /// detailTimeLabel constraints
        detailTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        detailTimeLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor).isActive = true
        detailTimeLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -sideGap).isActive = true
        detailTimeLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: sideGap).isActive = true
        detailTimeLabel.heightAnchor.constraint(equalToConstant: detailTimeLabelHeight).isActive = true
        
        /// fineTimeLabel constraints
        fineTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        fineTimeLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor).isActive = true
        fineTimeLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -sideGap).isActive = true
        fineTimeLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: sideGap).isActive = true
        fineTimeLabel.heightAnchor.constraint(equalToConstant: fineTimeLabelHeight).isActive = true

        /// actionButton constraints
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -bottomGap).isActive = true
        actionButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -sideGap).isActive = true
        actionButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: sideGap).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: actionButtonHeight).isActive = true
        
        let titleStackView = UIStackView(arrangedSubviews: [levelLabel, titleLabel])
        let spacing: CGFloat = 15.0
        titleStackView.axis = .horizontal
        titleStackView.distribution = .equalSpacing
        titleStackView.alignment = .center
        titleStackView.spacing = spacing
        
        self.contentView.addSubview(titleStackView)
        
        let titleStackViewWidth = levelLabelHeight + titleLabelWidth + spacing
        
        /// titleStackView constraints
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        titleStackView.topAnchor.constraint(equalTo: margins.topAnchor, constant: topGap).isActive = true
        titleStackView.heightAnchor.constraint(equalToConstant: titleLabelHeight).isActive = true
        titleStackView.widthAnchor.constraint(equalToConstant: titleStackViewWidth).isActive = true
        
        self.contentView.subviews.forEach { $0.alpha = 0.0 }

    }
    
    private func setupTitleStackView() {
        
    }
    
    private func attributedTextForFineLabel(fine: Double) -> NSMutableAttributedString {
        /// fineTimeLabel attributed text
        let fineString = Strings.Fine + String(format: "%.02f", abs(fine))
        let fineMutableString = NSMutableAttributedString(
            string: fineString,
            attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20.0)]
        )
        fineMutableString.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: titleLabel.textColor,
            range: NSRange(location: 0, length: 6)
        )
        return fineMutableString
    }
    
}
