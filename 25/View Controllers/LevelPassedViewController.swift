//
//  LevelPassedViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/16/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import UIKit

class LevelPassedViewController: ResultsViewController {
    
    // MARK: - Public Properties
    
    var game: Game!
    
    // MARK: - Private Properties

    private var titleLabel = UILabel()
    private var detailsLabel = UILabel()
            
    // MARK: - Private Methods
    
    override func configure() {
        super.configure()
        
        // Configure title lable
        vibrancyEffectView.contentView.addSubview(titleLabel)
        
        titleLabel.text = "Level passed!"
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 30)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: vibrancyEffectView.contentView.topAnchor, constant: 30).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: vibrancyEffectView.contentView.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: vibrancyEffectView.contentView.rightAnchor).isActive = true
        
        // Configure detials label
        vibrancyEffectView.contentView.addSubview(detailsLabel)
        
        detailsLabel.text = "Level \(game.currentLevel.serial) is available!"
        detailsLabel.textAlignment = .center
        detailsLabel.numberOfLines = 0
        detailsLabel.font = .systemFont(ofSize: titleLabel.font.pointSize)
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = view.layoutMarginsGuide
        detailsLabel.centerXAnchor.constraint(equalTo: vibrancyEffectView.contentView.centerXAnchor).isActive = true
        detailsLabel.centerYAnchor.constraint(equalTo: vibrancyEffectView.contentView.centerYAnchor).isActive = true
        detailsLabel.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
        detailsLabel.leftAnchor.constraint(equalTo: margins.leftAnchor).isActive = true
    }
}
