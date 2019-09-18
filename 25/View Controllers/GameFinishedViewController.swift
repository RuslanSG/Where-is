//
//  LevelFailedViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/16/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import UIKit

class GameFinishedViewController: ResultsViewController {
    
    // MARK: - Public Properties
    
    var session: GameSession!
    
    // MARK: - Private Properties
    
    private var titleLabel = UILabel()
    private var reasonLabel = UILabel()
    private var numbersCountLabel = UILabel()
    private var numbersFoundLabel = UILabel()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    // MARK: - Private Methods
    
    override func configure() {
        super.configure()
        
        // Configure title lable
        vibrancyEffectView.contentView.addSubview(titleLabel)
        
        titleLabel.text = "Title"
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 30)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: vibrancyEffectView.contentView.topAnchor, constant: 30).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: vibrancyEffectView.contentView.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: vibrancyEffectView.contentView.rightAnchor).isActive = true
        
        // Configure reason label
        
        
        // Configure numbers count label
        vibrancyEffectView.contentView.addSubview(numbersCountLabel)
        numbersCountLabel.text = String(session.numbersFound)
        numbersCountLabel.textAlignment = .center
        numbersCountLabel.font = .systemFont(ofSize: 80)
        
        numbersCountLabel.translatesAutoresizingMaskIntoConstraints = false
        numbersCountLabel.centerXAnchor.constraint(equalTo: vibrancyEffectView.contentView.centerXAnchor).isActive = true
        numbersCountLabel.centerYAnchor.constraint(equalTo: vibrancyEffectView.contentView.centerYAnchor).isActive = true
                
        /// Configure "Numbers Found" label
        vibrancyEffectView.contentView.addSubview(numbersFoundLabel)
        numbersFoundLabel.text = "Numbers Found:"
        numbersFoundLabel.textAlignment = .center
        numbersFoundLabel.font = .systemFont(ofSize: 15)
        
        numbersFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        numbersFoundLabel.centerXAnchor.constraint(equalTo: vibrancyEffectView.contentView.centerXAnchor).isActive = true
        numbersFoundLabel.bottomAnchor.constraint(equalTo: numbersCountLabel.topAnchor, constant: -10).isActive = true
    }
    
    
}
