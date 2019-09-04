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
        static let availableLevels      = "AvailableLevelsUserDefaultsKey"
        static let levelIndex           = "LevelUserDefaultsKey"
        static let firstTime            = "FirstTimeUserDefaultsKey"
        static let stopGameHintNeeded   = "StopGameHintNeededUserDefaultsKey"
        static let findNumberHintNeeded = "FindNumberHintNeededUserDefaultsKey"
    }
}
