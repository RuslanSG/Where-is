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
        
        vibrancyEffectView.contentView.addSubview(titleLabel)
        vibrancyEffectView.contentView.addSubview(bodyLabel)
        vibrancyEffectView.contentView.addSubview(rateButton)
        
        // Configure title lable
        titleLabel.text = "Congratulations!"
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 30)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: vibrancyEffectView.contentView.topAnchor, constant: 30).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: vibrancyEffectView.contentView.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: vibrancyEffectView.contentView.rightAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        // Configure body label
        bodyLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer sem elit, tempus efficitur magna et, blandit sodales nunc. Aenean tempus porta facilisis. Sed venenatis dolor a nisi viverra, ac egestas orci viverra. Suspendisse dignissim accumsan sapien quis accumsan. Etiam dapibus, urna eget consectetur rutrum, felis nunc malesuada nisl, eget gravida diam purus vel urna. Mauris maximus magna vitae purus lacinia blandit. Nullam faucibus, erat sed mattis scelerisque, risus tellus tincidunt sapien, sit amet molestie ipsum metus vel metus. Cras malesuada erat eu elit blandit, at egestas ex pharetra."
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        bodyLabel.adjustsFontSizeToFitWidth = true
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bodyLabel.rightAnchor.constraint(equalTo: vibrancyEffectView.contentView.rightAnchor, constant: -16).isActive = true
        bodyLabel.leftAnchor.constraint(equalTo: vibrancyEffectView.contentView.leftAnchor, constant: 16).isActive = true
        bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
        bodyLabel.bottomAnchor.constraint(equalTo: rateButton.topAnchor, constant: -16).isActive = true
        
        // Configure rate button
        rateButton.setTitle("Оставить отзыв", for: .normal)
        rateButton.addTarget(self, action: #selector(rateButtonPressed(_:)), for: .touchUpInside)
        rateButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
        rateButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        rateButton.layer.cornerRadius = 12
        rateButton.translatesAutoresizingMaskIntoConstraints = false
        
        rateButton.centerXAnchor.constraint(equalTo: vibrancyEffectView.contentView.centerXAnchor).isActive = true
        rateButton.bottomAnchor.constraint(equalTo: tapAnywhereToHideLabel.topAnchor, constant: -30).isActive = true
        rateButton.widthAnchor.constraint(equalToConstant: rateButton.intrinsicContentSize.width + 30).isActive = true
        rateButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
}
