//
//  StartView.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/9/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class StartGameView: UIVisualEffectView {
    
    // MARK: - Public Properties
    
    var level: Level! {
        didSet {
            updateDetails()
        }
    }
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: cellNumbersFontSize * 0.85, weight: .heavy)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    var detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: cellNumbersFontSize * 0.45, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.alpha = 0.7
        return label
    }()
    
    // MARK: - Private Properties
    
    private let titleLabelDefaultAlpha: CGFloat = 1.0
    private let detailsLabelDefaultAlpha: CGFloat = 0.7
        
    // MARK: - Initialization
    
    init(level: Level) {
        self.level = level
        super.init(effect: nil)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func show() {
        guard isHidden else { return }
        isHidden = false
        isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }
    
    func hide() {
        guard !isHidden else { return }
        isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 0
        }) { _ in
            self.isHidden = true
        }
    }
    
    // MARK: - Private Methods
    
    private func configure() {
        if #available(iOS 13.0, *) {
            effect = UIBlurEffect(style: .systemUltraThinMaterial)
        } else {
            effect = UIBlurEffect(style: .light)
        }
            
        titleLabel.text = NSLocalizedString("START", comment: "Localized kind: start button")
        titleLabel.accessibilityIdentifier = "start_label"
        
        updateDetails()
                
        let stackView = UIStackView(arrangedSubviews: [titleLabel, detailsLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .fill
        stackView.alignment = .center
        
        contentView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func updateDetails() {
        if level.isPassed {
            detailsLabel.text = NSLocalizedString("Record:", comment: "Localized kind: record label") + " " + String(level.record)
            
        } else {
            detailsLabel.text = String(format: NSLocalizedString("Find %d Numbers", comment: "Localized kind: task label"), level.goal) 
            
        }
    }
}
