//
//  Utilities.swift
//  25
//
//  Created by Ruslan Gritsenko on 07.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import UIKit

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

extension UIDevice {
    enum DevicePlatform: String {
        case other          = "Old Device"
        case iPhone6S       = "iPhone 6S"
        case iPhone6SPlus   = "iPhone 6S Plus"
        case iPhone7        = "iPhone 7"
        case iPhone7Plus    = "iPhone 7 Plus"
        case iPhone8        = "iPhone 8"
        case iPhone8Plus    = "iPhone 8 Plus"
        case iPhoneX        = "iPhone X"
        case iPhoneXS       = "iPhone XS"
        case iPhoneXSMax    = "iPhone XS Max"
        case iPhoneXR       = "iPhone XR"
    }
    
    var platform: DevicePlatform {
        get {
            var sysinfo = utsname()
            uname(&sysinfo)
            let platform = String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
            switch platform {
            case "iPhone11,6", "iPhone11,4":
                return .iPhoneXSMax
            case "iPhone11,2":
                return .iPhoneXS
            case "iPhone11,8":
                return .iPhoneXR
            case "iPhone10,3", "iPhone10,6":
                return .iPhoneX
            case "iPhone10,2", "iPhone10,5":
                return .iPhone8Plus
            case "iPhone10,1", "iPhone10,4":
                return .iPhone8
            case "iPhone9,2", "iPhone9,4":
                return .iPhone7Plus
            case "iPhone9,1", "iPhone9,3":
                return .iPhone7
            case "iPhone8,2":
                return .iPhone6SPlus
            case "iPhone8,1":
                return .iPhone6S
            default:
                return .other
            }
        }
    }
    
    var hasTapticEngine: Bool {
        get {
            let tapticEnginePlatforms: [DevicePlatform] = [.iPhone6S, .iPhone6SPlus,
                                                           .iPhone7, .iPhone7Plus,
                                                           .iPhone8, .iPhone8Plus,
                                                           .iPhoneX,
                                                           .iPhoneXR, .iPhoneXS, .iPhoneXSMax]
            
            return tapticEnginePlatforms.contains(platform)
        }
    }
    
    var hasHapticFeedback: Bool {
        get {
            let hapticFeedbackPlatforms: [DevicePlatform] = [.iPhone7, .iPhone7Plus,
                                                             .iPhone8, .iPhone8Plus,
                                                             .iPhoneX,
                                                             .iPhoneXR, .iPhoneXS, .iPhoneXSMax]
            
            return hapticFeedbackPlatforms.contains(platform)
        }
    }
    
    var hasLiquidRetina: Bool {
        get {
            let iPhoneXPlatforms: [DevicePlatform] = [.iPhoneX,
                                                      .iPhoneXR, .iPhoneXS, .iPhoneXSMax]
            
            return iPhoneXPlatforms.contains(platform)
        }
    }
}

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format,
                                                      options: NSLayoutConstraint.FormatOptions(),
                                                      metrics: nil,
                                                      views: viewsDictionary))
    }
}

extension UIButton {
    func show(animated: Bool) {
        self.isEnabled = true
        if animated {
            let duration = 0.2
            let delay = 0.0
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: duration,
                delay: delay,
                options: .curveEaseIn,
                animations: {
                    self.alpha = 1.0
            })
        } else {
            self.alpha = 1.0
        }
    }
    
    func hide(animated: Bool) {
        self.isEnabled = false
        if animated {
            let duration = 0.2
            let delay = 0.0
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: duration,
                delay: delay,
                options: .curveEaseIn,
                animations: {
                    self.alpha = 0.0
            })
        } else {
            self.alpha = 0.0
        }
    }
}

extension Notification.Name {
    static let DarkModeStateDidChange = Notification.Name("DarkModeStateDidChangeNotification")
    static let UserInterfaceColorDidChange = Notification.Name("UserInterfaceColorDidChangeNotification")
    static let InGameStateDidChange = Notification.Name("UserInterfaceColorDidChangeNotification")
    static let UserLocationDidUpdate = Notification.Name("UserLocationDidUpdateNotification")
}

extension Notification {
    enum UserInfoKey {
        static let CellsNotAnimating: String = "CellsNotAnimatingUserInfoKey"
        static let Game: String = "GameUserInfoKey"
        static let Appearance: String = "AppearanceUserInfoKey"
        static let DarkModeState: String = "DarkModeStateUserInfoKey"
        static let UserInterfaceColor: String = "UserInterfaceColorUserInfoKey"
        static let InGame: String = "InGameUserInfoKey"
        static let UserLocation: String = "UserLocationUserInfoKey"
        static let CityName: String = "CityNameUserInfoKey"
    }
}

extension UserDefaults {
    enum Key {
        static let DarkMode: String = "DarkModeUserDefaultsKey"
        static let AutomaticDarkMode: String = "AutomaticDarkModeKey"
        static let Sunrise: String = "SunriseUserDefaultsKey"
        static let Sunset: String = "SunsetUserDefaultsKey"
        static let NotFirstLaunch: String = "NotFirstLaunchUserDefaultsKey"
        static let Level: String = "LevelUserDefaultsKey"
        static let LevelChanger: String = "LevelChangerUserDefaultsKey"
        static let AppearingCount: String = "AppearingCountUserDefaultsKey"
        static let ShowSettingsEventCount: String = "ShowSettingsEventCountUserDefaultsKey"
        static let StopGameEventCount: String = "StopGameEventCountUserDefaultsKey"
        static let AvailableLevels: String = "AvailableLevelsUserDefaultsKey"
        static let InfinityModeScoreRecord: String = "InfinityModeScoreRecordUserDefaultsKey"
        static let GamePassed: String = "GamePassedUserDefaultsKey"
        static let AttemptsCount: String = "AttemptsCountUserDefaultsKey"
    }
}

extension Date {
    var time: Time {
        return Time(self)
    }
}
