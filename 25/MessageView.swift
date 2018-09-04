//
//  MessageView.swift
//  25
//
//  Created by Ruslan Gritsenko on 05.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class MessageView: UIVisualEffectView {

    let label = UILabel()
    
    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        
        contentView.addSubview(label)
        contentView.addConstraintsWithFormat(format: "H:|[v0]|", views: label)
        contentView.addConstraintsWithFormat(format: "V:|[v0]|", views: label)
        
        label.text = "Tap any cell to start"
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
