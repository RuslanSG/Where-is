//
//  Utilities.swift
//  25
//
//  Created by Ruslan Gritsenko on 07.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import UIKit

#warning("Add the new iPhones!")

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
            let platform = String(bytes: Data(bytes: &sysinfo.machine,
                                              count: Int(_SYS_NAMELEN)),
                                  encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
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
