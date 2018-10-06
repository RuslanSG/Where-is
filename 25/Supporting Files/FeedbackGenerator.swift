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
    
    private let feedbackGenerator: (notification: UINotificationFeedbackGenerator, impact: (light: UIImpactFeedbackGenerator, medium: UIImpactFeedbackGenerator, heavy: UIImpactFeedbackGenerator), selection: UISelectionFeedbackGenerator) = {
        return (notification: UINotificationFeedbackGenerator(), impact: (light: UIImpactFeedbackGenerator(style: .light), medium: UIImpactFeedbackGenerator(style: .medium), heavy: UIImpactFeedbackGenerator(style: .heavy)), selection: UISelectionFeedbackGenerator())
    }()
    
    func playNotificationHapticFeedback(notificationFeedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        if UIDevice.current.hasHapticFeedback {
            feedbackGenerator.notification.notificationOccurred(notificationFeedbackType)
        } else if UIDevice.current.hasTapticEngine, notificationFeedbackType == .error {
            let cancelled = SystemSoundID(1521)
            AudioServicesPlaySystemSound(cancelled)
        } else if notificationFeedbackType == .error {
            let cancelled = SystemSoundID(kSystemSoundID_Vibrate)
            AudioServicesPlaySystemSound(cancelled)
        }
    }
    
    func playImpactHapticFeedback(needsToPrepare: Bool, style: UIImpactFeedbackGenerator.FeedbackStyle) {
        if UIDevice.current.hasHapticFeedback {
            feedbackGenerator.impact.light.impactOccurred()
            if needsToPrepare {
                feedbackGenerator.impact.light.prepare()
            }
        } else if UIDevice.current.hasTapticEngine {
            let peek = SystemSoundID(1519)
            AudioServicesPlaySystemSound(peek)
        }
    }
    
    func playSelectionHapticFeedback() {
        if UIDevice.current.hasHapticFeedback {
            feedbackGenerator.selection.selectionChanged()
        } else if UIDevice.current.hasTapticEngine {
            let peek = SystemSoundID(1519)
            AudioServicesPlaySystemSound(peek)
        }
        feedbackGenerator.selection.prepare()
    }
    
}
