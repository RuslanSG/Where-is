//
//  AppDelegate.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/2/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit
#if PROD
import Firebase
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var restrictRotation: UIInterfaceOrientationMask = .allButUpsideDown
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        registerUserDefaults()
        
        let firstTime = UserDefaults.standard.bool(forKey: UserDefaults.Key.firstTime)
        if firstTime {
            cleanUserDefaults()
        }
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let viewController = UIStoryboard.instantiateInitialViewController(storyboard)
        window.rootViewController = viewController()
        self.window = window
        self.window?.makeKeyAndVisible()
        
        UIView.appearance().isExclusiveTouch = true
        
        let pageControl = UIPageControl.appearance()
        pageControl.currentPageIndicatorTintColor = .darkGray
        pageControl.pageIndicatorTintColor = .lightGray
        
        #if PROD
        FirebaseApp.configure()
        #endif
        
        #if FASTLANE
        UIView.setAnimationsEnabled(false)
        #endif
                
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.restrictRotation
    }
    
    // MARK: - Helper Methods
    
    private func registerUserDefaults() {
        UserDefaults.standard.register(defaults: [UserDefaults.Key.firstTime : true])
        UserDefaults.standard.register(defaults: [UserDefaults.Key.stopGameHintNeeded : true])
        UserDefaults.standard.register(defaults: [UserDefaults.Key.findNumberHintNeeded : true])
        UserDefaults.standard.register(defaults: [UserDefaults.Key.allLevelPassedCongratulationsNedded : true])
    }
    
    private func cleanUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
}

