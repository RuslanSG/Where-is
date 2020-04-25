//
//  FirebaseManager.swift
//  25
//
//  Created by Ruslan Gritsenko on 30.01.2020.
//  Copyright © 2020 Ruslan Gritsenko. All rights reserved.
//

#if PROD
import Firebase

class FirebaseManager {
    func logLevelPassed(_ level: Int) {
        Analytics.logEvent("level_\(level)_passed", parameters: nil)
    }
}
#endif
