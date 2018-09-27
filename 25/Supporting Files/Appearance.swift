//
//  Appearance.swift
//  25
//
//  Created by Ruslan Gritsenko on 16.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import UIKit

class Appearance {
    
    private var view: UIView?
    
    init(view: UIView? = nil) {
        self.view = view
    }
    
    // MARK: - Game View Controller
    
    // MARK: Colors
    
    private let defaultCellsColors    = (darkMode: #colorLiteral(red: 0.2203874684, green: 0.2203874684, blue: 0.2203874684, alpha: 1), lightMode: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    private let numbersColors         = (darkMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), lightMode: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    private let mainViewColors       = (darkMode: #colorLiteral(red: 0.09019607843, green: 0.09019607843, blue: 0.09019607843, alpha: 1), lightMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    
    private let colorfulCellsColors = [[(light: #colorLiteral(red: 0.968627451, green: 0.7254901961, blue: 0.168627451, alpha: 1), dark: #colorLiteral(red: 0.8057276114, green: 0.4694959764, blue: 0.1296572619, alpha: 1)),
                                        (light: #colorLiteral(red: 0.9215686275, green: 0.1490196078, blue: 0.1215686275, alpha: 1), dark: #colorLiteral(red: 0.599486165, green: 0.08605109967, blue: 0.05797519395, alpha: 1)),
                                        (light: #colorLiteral(red: 0.7882352941, green: 0.1843137255, blue: 0.4823529412, alpha: 1), dark: #colorLiteral(red: 0.5, green: 0.1014612427, blue: 0.3135548154, alpha: 1))]]
    
    public let highlightedCellColor = #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1)
    
    public var defaultCellsColor: UIColor {
        return darkMode ? defaultCellsColors.darkMode : defaultCellsColors.lightMode
    }
    public var textColor: UIColor {
        return darkMode ? numbersColors.darkMode : numbersColors.lightMode
    }
    public var mainViewColor: UIColor {
        return darkMode ? mainViewColors.darkMode : mainViewColors.lightMode
    }
    
    public lazy var currentColorSet = colorfulCellsColors[colorfulCellsColors.count.arc4random]
    
    public var randomColor: UIColor {
        return darkMode ? currentColorSet[currentColorSet.count.arc4random].dark :
                          currentColorSet[currentColorSet.count.arc4random].light
    }
    
    public lazy var userInterfaceColor = randomColor
    
    // MARK: Sizes
    
    public var cornerRadius: CGFloat {
        if let view = self.view {
            if view.traitCollection.horizontalSizeClass == .regular,
               view.traitCollection.verticalSizeClass == .regular {
                return 12.0
            } else {
                return 7.0
            }
        } else {
            return 0.0
        }
    }
    
    public var numbersFontSize: CGFloat {
        if let view = self.view {
            return view.bounds.width / 10
        }
        return 0.0
    }
    
    public var gridInset: CGFloat {
        if let view = self.view {
            return view.bounds.width / 200
        }
        return 0.0
    }
    
    public let cellCompressionRatio = 0.90
    
    public let statusBarHeight = UIApplication.shared.statusBarFrame.height
    
    // MARK: - Settings View Comtroller
    
    // MARK: Colors
    
    public let cellsColor                  = (darkMode: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1), lightMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    public let tableViewBackgroundColor    = (darkMode: #colorLiteral(red: 0.09019607843, green: 0.09019607843, blue: 0.09019607843, alpha: 1), lightMode: #colorLiteral(red: 0.9411764706, green: 0.937254902, blue: 0.9607843137, alpha: 1))
    public let tableViewSeparatorColor     = (darkMode: #colorLiteral(red: 0.1764705882, green: 0.1764705882, blue: 0.1843137255, alpha: 1), lightMode: #colorLiteral(red: 0.8274509804, green: 0.8235294118, blue: 0.8392156863, alpha: 1))
    public let swithersTintColor           = (darkMode: #colorLiteral(red: 0.262745098, green: 0.2588235294, blue: 0.2705882353, alpha: 1), lightMode: #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1))
    
    // MARK: - Dark Mode
    
    var i = 1
    
    public var darkMode: Bool {
        set {
            if darkMode != newValue {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.darkMode.rawValue)
                userInterfaceColor = switchColorForAnotherScheme(userInterfaceColor) ?? .blue
                NotificationCenter.default.post(
                    name: Notification.Name(NotificationName.darkModeStateDidChange.rawValue),
                    object: nil,
                    userInfo: [UserInfoKey.darkModeState.rawValue: newValue]
                )
            }
        }
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.darkMode.rawValue)
        }
    }
    
    // MARK: - Helping Methods
    
    public func getAnotherColor(for color: UIColor) -> UIColor? {
        var allColors = currentColorSet.map { darkMode ? $0.dark : $0.light }
        let index = allColors.index(of: color)
        if let index = index {
            allColors.remove(at: index)
            let otherColors = allColors
            return otherColors[otherColors.count.arc4random]
        }
        return nil
    }
    
    public func switchColorForAnotherScheme(_ currentColor: UIColor) -> UIColor? {
        var newColor: UIColor? = nil
        currentColorSet.forEach { (color) in
            if darkMode, currentColor == color.light {
                newColor = color.dark
            } else if !darkMode, currentColor == color.dark {
                newColor = color.light
            }
        }
        return newColor
    }
    
}

// Other colors

//private let colorSetsR = [[(light: #colorLiteral(red: 0.06666666667, green: 0.4666666667, blue: 0.7215686275, alpha: 1), dark: #colorLiteral(red: 0.03137254902, green: 0.3058823529, blue: 0.4941176471, alpha: 1)),
//                           (light: #colorLiteral(red: 0.09803921569, green: 0.6588235294, blue: 0.6117647059, alpha: 1), dark: #colorLiteral(red: 0.06666666667, green: 0.4823529412, blue: 0.462745098, alpha: 1)),
//                           (light: #colorLiteral(red: 0.1607843137, green: 0.6862745098, blue: 0.1137254902, alpha: 1), dark: #colorLiteral(red: 0.05098039216, green: 0.4392156863, blue: 0.05882352941, alpha: 1))],
//
//                          [(light: #colorLiteral(red: 0.968627451, green: 0.7254901961, blue: 0.168627451, alpha: 1), dark: #colorLiteral(red: 0.8057276114, green: 0.4694959764, blue: 0.1296572619, alpha: 1)),
//                           (light: #colorLiteral(red: 0.9215686275, green: 0.1490196078, blue: 0.1215686275, alpha: 1), dark: #colorLiteral(red: 0.599486165, green: 0.08605109967, blue: 0.05797519395, alpha: 1)),
//                           (light: #colorLiteral(red: 0.7882352941, green: 0.1843137255, blue: 0.4823529412, alpha: 1), dark: #colorLiteral(red: 0.5, green: 0.1014612427, blue: 0.3135548154, alpha: 1))],
//
//                          [(light: #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1), dark: #colorLiteral(red: 0.3025199942, green: 0.301058545, blue: 0.3039814435, alpha: 1)),
//                           (light: #colorLiteral(red: 0.5787474513, green: 0.3215198815, blue: 0, alpha: 1), dark: #colorLiteral(red: 0.4634119638, green: 0.2628604885, blue: 0.05822089579, alpha: 1)),
//                           (light: #colorLiteral(red: 0.5738074183, green: 0.5655357838, blue: 0, alpha: 1), dark: #colorLiteral(red: 0.4723546985, green: 0.4624517336, blue: 0.09191328908, alpha: 1))]]
