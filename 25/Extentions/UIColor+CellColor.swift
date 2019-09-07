//
//  UIColor+Colors.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/17/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

extension UIColor {

    // MARK: - Default Colors
    
    static var cellDefault: UIColor {
        if #available(iOS 13.0, *) {
            let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                } else {
                    return #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                }
            }
            return dynamicColor
        } else {
            return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }
    
    // MARK: - Hot Colors
    
    static var cellYellow: UIColor {
        if #available(iOS 13.0, *) {
            let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return #colorLiteral(red: 0.9745706916, green: 0.7254121304, blue: 0.2632409632, alpha: 1)
                } else {
                    return #colorLiteral(red: 0.9889556766, green: 0.5467290282, blue: 0.005224304274, alpha: 1)
                }
            }
            return dynamicColor
        } else {
            return #colorLiteral(red: 0.9745706916, green: 0.7254121304, blue: 0.2632409632, alpha: 1)
        }
    }
    
    static var cellPurple: UIColor {
        if #available(iOS 13.0, *) {
            let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return #colorLiteral(red: 0.7501872778, green: 0.4219583273, blue: 0.8242880702, alpha: 1)
                } else {
                    return #colorLiteral(red: 0.5032941103, green: 0.08821157366, blue: 0.4238467216, alpha: 1)
                }
            }
            return dynamicColor
        } else {
            return #colorLiteral(red: 0.7501872778, green: 0.4219583273, blue: 0.8242880702, alpha: 1)
        }
    }
    
    static var cellRed: UIColor {
        if #available(iOS 13.0, *) {
            let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return #colorLiteral(red: 0.9866005778, green: 0.3354937434, blue: 0.305663228, alpha: 1)
                } else {
                    return #colorLiteral(red: 0.555553019, green: 0, blue: 0.09771498293, alpha: 1)
                }
            }
            return dynamicColor
        } else {
            return #colorLiteral(red: 0.9866005778, green: 0.3354937434, blue: 0.305663228, alpha: 1)
        }
    }
    
    // MARK: - Cold Colors
    
    static var cellDarkBlue: UIColor {
        if #available(iOS 13.0, *) {
            let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return #colorLiteral(red: 0, green: 0.2106473744, blue: 0.7617111206, alpha: 1)
                } else {
                    return #colorLiteral(red: 0.04109799117, green: 0.04631247371, blue: 0.5429670215, alpha: 1)
                }
            }
            return dynamicColor
        } else {
            return #colorLiteral(red: 0, green: 0.2106473744, blue: 0.7617111206, alpha: 1)
        }
    }
    
    static var cellBlue: UIColor {
        if #available(iOS 13.0, *) {
            let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return #colorLiteral(red: 0.1781513393, green: 0.6642397046, blue: 0.9883195758, alpha: 1)
                } else {
                    return #colorLiteral(red: 0, green: 0.4386680126, blue: 0.8875405192, alpha: 1)
                }
            }
            return dynamicColor
        } else {
            return #colorLiteral(red: 0.1781513393, green: 0.6642397046, blue: 0.9883195758, alpha: 1)
        }
    }
    
    static var cellTurquoise: UIColor {
        if #available(iOS 13.0, *) {
            let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return #colorLiteral(red: 0.1146891937, green: 0.7476466894, blue: 0.6755729318, alpha: 1)
                } else {
                    return #colorLiteral(red: 0, green: 0.6753467321, blue: 0.4155264497, alpha: 1)
                }
            }
            return dynamicColor
        } else {
            return #colorLiteral(red: 0.1146891937, green: 0.7476466894, blue: 0.6755729318, alpha: 1)
        }
    }
    
    // MARK: - Green Colors
    
    static var cellDarkGreen: UIColor {
        if #available(iOS 13.0, *) {
            let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return #colorLiteral(red: 0.003494717414, green: 0.4192094803, blue: 0.1989500523, alpha: 1)
                } else {
                    return #colorLiteral(red: 0.00633240724, green: 0.2334372699, blue: 0.1090542749, alpha: 1)
                }
            }
            return dynamicColor
        } else {
            return #colorLiteral(red: 0.003494717414, green: 0.4192094803, blue: 0.1989500523, alpha: 1)
        }
    }
    
    static var cellGreen: UIColor {
        if #available(iOS 13.0, *) {
            let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return #colorLiteral(red: 0.07409424335, green: 0.6056019068, blue: 0.1716023386, alpha: 1)
                } else {
                    return #colorLiteral(red: 0, green: 0.5185575485, blue: 0.1541956663, alpha: 1)
                }
            }
            return dynamicColor
        } else {
            return #colorLiteral(red: 0.07409424335, green: 0.6056019068, blue: 0.1716023386, alpha: 1)
        }
    }
    
    static var cellLightGreen: UIColor {
        if #available(iOS 13.0, *) {
            let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return #colorLiteral(red: 0.7584109306, green: 0.8937657475, blue: 0.01139242854, alpha: 1)
                } else {
                    return #colorLiteral(red: 0.6150048375, green: 0.8149619699, blue: 0, alpha: 1)
                }
            }
            return dynamicColor
        } else {
            return #colorLiteral(red: 0.7584109306, green: 0.8937657475, blue: 0.01139242854, alpha: 1)
        }
    }
    
    
    // MARK: - Grey Colors
    
    static var cellDarkGrey: UIColor {
        if #available(iOS 13.0, *) {
            let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return #colorLiteral(red: 0.2156584561, green: 0.2157022655, blue: 0.2156556845, alpha: 1)
                } else {
                    return #colorLiteral(red: 0.1176293567, green: 0.1176572666, blue: 0.1176275685, alpha: 1)
                }
            }
            return dynamicColor
        } else {
            return #colorLiteral(red: 0.2156584561, green: 0.2157022655, blue: 0.2156556845, alpha: 1)
        }
    }
    
    static var cellGrey: UIColor {
        if #available(iOS 13.0, *) {
            let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return #colorLiteral(red: 0.4626919031, green: 0.4627756476, blue: 0.4626866579, alpha: 1)
                } else {
                    return #colorLiteral(red: 0.1686044633, green: 0.1686406434, blue: 0.1686021686, alpha: 1)
                }
            }
            return dynamicColor
        } else {
            return #colorLiteral(red: 0.4626919031, green: 0.4627756476, blue: 0.4626866579, alpha: 1)
        }
    }
    
    static var cellLightGrey: UIColor {
        if #available(iOS 13.0, *) {
            let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return #colorLiteral(red: 0.7018831372, green: 0.7020055652, blue: 0.7018753886, alpha: 1)
                } else {
                    return #colorLiteral(red: 0.3842686117, green: 0.3843396306, blue: 0.3842641115, alpha: 1)
                }
            }
            return dynamicColor
        } else {
            return #colorLiteral(red: 0.7018831372, green: 0.7020055652, blue: 0.7018753886, alpha: 1)
        }
    }
}
