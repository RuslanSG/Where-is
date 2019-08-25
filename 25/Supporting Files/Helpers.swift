//
//  Helpers.swift
//  25
//
//  Created by Ruslan Gritsenko on 8/8/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

enum Orientation {
    case portrait
    case landscape
}

var orientation: Orientation {
    return UIScreen.main.bounds.width < UIScreen.main.bounds.height ? .portrait : .landscape
}

let globalCellInset: CGFloat = 1.5
let globalCornerRadius: CGFloat = 9.0
