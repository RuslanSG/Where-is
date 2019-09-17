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
            return .lightGray
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
