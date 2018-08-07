//
//  ViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 07.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        var numbers = [String]()
        for i in 1...buttons.count {
            numbers.append(String(i))
        }
        
        numbers.shuffle()
        
        for i in buttons.indices {
            let button = buttons[i]
            button.setTitle(numbers[i], for: .normal)
        }
    }

}


