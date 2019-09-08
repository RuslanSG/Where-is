//
//  AppDelegate.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/2/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var restrictRotation: UIInterfaceOrientationMask = .allButUpsideDown
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        registerUserDefaults()
        
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
    }
    
}

