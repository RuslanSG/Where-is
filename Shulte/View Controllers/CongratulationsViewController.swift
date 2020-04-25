//
//  CongratulationsViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/17/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import UIKit

class CongratulationsViewController: ResultsViewController {
    
    // MARK: - Private Properties
    
    private var titleLabel = UILabel()
    private var bodyLabel = UILabel()
    private var rateButton = UIButton(type: .system)
    
    // MARK: - Actions
    
    @objc private func rateButtonPressed(_ sender: UIButton) {
        guard let url = URL(string: "https://apps.apple.com/ua/app/where-is/id1439308784?l=ru") else { return }
        UIApplication.shared.open(url, options: [:])
    }
    
    // MARK: - Private Methods
    
    override func configure() {
        super.configure()
        
        view.addSubview(titleLabel)
        view.addSubview(bodyLabel)
        view.addSubview(rateButton)
        
        // Configure title lable
        titleLabel.text = NSLocalizedString("CONGRATULATIONS!", comment: "Localized kind: title label").uppercased()
        titleLabel.font = .systemFont(ofSize: 35, weight: .black)
        titleLabel.alpha = 0.7
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: vibrancyEffectView.contentView.topAnchor, constant: 30).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: vibrancyEffectView.contentView.leftAnchor, constant: 16).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: vibrancyEffectView.contentView.rightAnchor, constant: -16).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Configure body label
        bodyLabel.text = NSLocalizedString("Congratulations and well done! You have passed all levels and completed a great game! And have proven that you attentiveness is greater than all the powers of Where is. You are the master now. If you enjoyed this game, plaese leave me your feedback. Love.", comment: "Localized kind: game end congratulations text")
        bodyLabel.font = .systemFont(ofSize: 17, weight: .medium)
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        bodyLabel.adjustsFontSizeToFitWidth = true
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bodyLabel.rightAnchor.constraint(equalTo: vibrancyEffectView.contentView.rightAnchor, constant: -16).isActive = true
        bodyLabel.leftAnchor.constraint(equalTo: vibrancyEffectView.contentView.leftAnchor, constant: 16).isActive = true
        bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
        bodyLabel.bottomAnchor.constraint(equalTo: rateButton.topAnchor, constant: -16).isActive = true
        
        // Configure rate button
        rateButton.setTitle(NSLocalizedString("RATE", comment: "Localized kind: title label").uppercased(), for: .normal) 
        rateButton.addTarget(self, action: #selector(rateButtonPressed(_:)), for: .touchUpInside)
        rateButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
        rateButton.layer.cornerRadius = 12
        rateButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            rateButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        } else {
            rateButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        }
        
        rateButton.centerXAnchor.constraint(equalTo: vibrancyEffectView.contentView.centerXAnchor).isActive = true
        rateButton.bottomAnchor.constraint(equalTo: tapAnywhereToHideLabel.topAnchor, constant: -30).isActive = true
        rateButton.widthAnchor.constraint(equalToConstant: rateButton.intrinsicContentSize.width + 30).isActive = true
        rateButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
}
