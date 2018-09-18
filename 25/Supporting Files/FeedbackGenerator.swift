//
//  HapticFeedback.swift
//  25
//
//  Created by Ruslan Gritsenko on 03.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit
import AudioToolbox.AudioServices

class FeedbackGenerator {
    
    enum FeedbackGenerator {
        case notificationFeedbackGenerator
        case impactFeedbackGenerator
    }
    
    var notificationFeedbackGenerator: UINotificationFeedbackGenerator? = nil
    var impactFeedbackGenerator: UIImpactFeedbackGenerator? = nil
    
    func playNotificationHapticFeedback(notificationFeedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        if UIDevice.current.hasHapticFeedback {
            notificationFeedbackGenerator = UINotificationFeedbackGenerator()
            notificationFeedbackGenerator?.notificationOccurred(notificationFeedbackType)
        } else if UIDevice.current.hasTapticEngine, notificationFeedbackType == .error {
            let cancelled = SystemSoundID(1521)
            AudioServicesPlaySystemSound(cancelled)
        } else if notificationFeedbackType == .error {
            let cancelled = SystemSoundID(kSystemSoundID_Vibrate)
            AudioServicesPlaySystemSound(cancelled)
        }
        notificationFeedbackGenerator = nil
    }
    
    func playImpactHapticFeedback(needsToPrepare: Bool, style: UIImpactFeedbackGenerator.FeedbackStyle) {
        if UIDevice.current.hasHapticFeedback {
            impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style)
            impactFeedbackGenerator?.impactOccurred()
            if needsToPrepare {
                impactFeedbackGenerator?.prepare()
            }
        } else if UIDevice.current.hasTapticEngine {
            let peek = SystemSoundID(1519)
            AudioServicesPlaySystemSound(peek)
        }
    }
    
}
