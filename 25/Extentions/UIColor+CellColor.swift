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
            return .systemGray5
        } else {
            return #colorLiteral(red: 0.8978924155, green: 0.8978005052, blue: 0.9142544866, alpha: 1)
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
