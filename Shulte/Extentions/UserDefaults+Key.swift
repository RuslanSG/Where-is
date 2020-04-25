//
//  UserDefaults+Key.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/15/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum Key {
        static let firstTime  = "FirstTimeUserDefaultsKey_2.0"
        static let stopGameHintNeeded = "StopGameHintNeededUserDefaultsKey"
        static let findNumberHintNeeded = "FindNumberHintNeededUserDefaultsKey"
        static let levels  = "LevelsUserDefaultsKey"
        static let allLevelPassedCongratulationsNedded = "allLevelPassedCongratulationsNeddedUserDefaultsKey"
    }
}
