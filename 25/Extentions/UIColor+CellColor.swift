//
//  UIColor+Colors.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/17/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var cellDefault: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray4
        } else {
            return #colorLiteral(red: 0.8274509804, green: 0.8235294118, blue: 0.8392156863, alpha: 1)
        }
    }
    
    static var cellRed: UIColor {
        if #available(iOS 13.0, *) {
            return .systemRed
        } else {
            return .red
        }
    }

}
