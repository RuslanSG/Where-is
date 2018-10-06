//
//  Strings.swift
//  25
//
//  Created by Ruslan Gritsenko on 22.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import Foundation

struct StringKeys {
    
    // MARK: - User Defaults
    
    public enum UserDefaultsKey {
        static let DarkMode: String = "darkModeUserDefaultsKey"
        static let AutomaticDarkMode: String = "automaticDarkModeKey"
        static let Sunrise: String = "sunriseUserDefaultsKey"
        static let Sunset: String = "sunsetUserDefaultsKey"
        static let NotFirstLaunch: String = "notFirstLaunch"
    }
    
    // MARK: - View Controllers Identifiers
    
    public enum ViewControllerIdentifier {
        static let RootViewController: String = "rootViewController"
        static let GreetingsViewController: String = "greetingsViewController"
        static let SensViewController: String = "sensViewController"
        static let TutorialViewController: String = "tutorialViewController"
        static let RemindersViewController: String = "remindersViewController"
        static let DarkModeViewController: String = "darkModeViewController"
        static let WelcomeViewController: String = "welcomeViewController"
    }
}

