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

var cellInset: CGFloat {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return 3
    }
    return 1.5
}

var cellCornerRadius: CGFloat {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return 14
    }
    return 9
}

var cellNumbersFontSize: CGFloat {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return 50
    }
    return 31
}
