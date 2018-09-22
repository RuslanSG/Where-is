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
    
    private var darkMode = false
    
    // MARK: - Colors
    
    private let cellsColors     = (darkMode: #colorLiteral(red: 0.2203874684, green: 0.2203874684, blue: 0.2203874684, alpha: 1), lightMode: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    private let numbersColors   = (darkMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), lightMode: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    private let mainViewColors  = (darkMode: #colorLiteral(red: 0.09019607843, green: 0.09019607843, blue: 0.09019607843, alpha: 1), lightMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    
    private let colorSets = [[(light: #colorLiteral(red: 0.968627451, green: 0.7254901961, blue: 0.168627451, alpha: 1), dark: #colorLiteral(red: 0.8057276114, green: 0.4694959764, blue: 0.1296572619, alpha: 1)),
                              (light: #colorLiteral(red: 0.9215686275, green: 0.1490196078, blue: 0.1215686275, alpha: 1), dark: #colorLiteral(red: 0.599486165, green: 0.08605109967, blue: 0.05797519395, alpha: 1)),
                              (light: #colorLiteral(red: 0.7882352941, green: 0.1843137255, blue: 0.4823529412, alpha: 1), dark: #colorLiteral(red: 0.5, green: 0.1014612427, blue: 0.3135548154, alpha: 1))]]
    
    var defaultCellsColor: UIColor {
        return darkMode ? cellsColors.darkMode : cellsColors.lightMode
    }
    var textColor: UIColor {
        return darkMode || game.colorfulCellsMode ? numbersColors.darkMode : numbersColors.lightMode
    }
    var mainViewColor: UIColor {
        return darkMode ? mainViewColors.darkMode : mainViewColors.lightMode
    }
    
    lazy var currentColorSet = colorSets[colorSets.count.arc4random]
    
    var randomColor: UIColor {
        let randomColor = darkMode ? currentColorSet[currentColorSet.count.arc4random].dark :
            currentColorSet[currentColorSet.count.arc4random].light
        return randomColor
    }
    
    private var userInterfaceColor: UIColor! {
        didSet {
            stopButton.tintColor = userInterfaceColor
            settingsButton.tintColor = userInterfaceColor
            
            NotificationCenter.default.post(
                name: Notification.Name(UserInterfaceColorDidChangeNotification),
                object: userInterfaceColor
            )
        }
    }
    
}



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
