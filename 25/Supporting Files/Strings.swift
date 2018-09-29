//
//  Strings.swift
//  25
//
//  Created by Ruslan Gritsenko on 22.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import Foundation

// MARK: - Notifications

public enum NotificationName: String {
    case darkModeStateDidChange = "DarkModeStateDidChangeNotification"
    case userInterfaceColorDidChange = "UserInterfaceColorDidChangeNotification"
}

// MARK: - User Defaults

public enum UserDefaultsKey: String {
    case darkMode = "darkModeUserDefaultsKey"
    case automaticDarkMode = "automaticDarkModeKey"
    case sunrise = "sunriseUserDefaultsKey"
    case sunset = "sunsetUserDefaultsKey"
    case notFirstLaunch = "notFirstLaunch"
}

// MARK: - User Info

public enum UserInfoKey: String {
    case cellsNotAnimating = "cellsNotAnimatingUserInfoKey"
    case game = "gameUserInfoKey"
    case appearance = "appearanceUserInfoKey"
    case darkModeState = "DarkModeStateUserInfoKey"
    case userInterfaceColor = "UserInterfaceColorUserInfoKey"
}

// MARK: - View Controllers Identifiers

public enum ViewControllerIdentifier: String {
    case rootViewController = "rootViewController"
    case greetingsViewController = "greetingsViewController"
    case sensViewController = "sensViewController"
    case tutorialViewController = "tutorialViewController"
    case remindersViewController = "remindersViewController"
    case darkModeViewController = "darkModeViewController"
    case welcomeViewController = "welcomeViewController"
}
