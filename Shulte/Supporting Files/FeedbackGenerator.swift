//
//  HapticFeedback.swift
//  25
//
//  Created by Ruslan Gritsenko on 03.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit
import AudioToolbox.AudioServices
import AVFoundation

final class FeedbackGenerator {
    
    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    private let notifitationFeedbackGenerator = UINotificationFeedbackGenerator()
            
    func playSelectionFeedback() {
        AudioServicesPlaySystemSound(1459)
        selectionFeedbackGenerator.selectionChanged()
    }
    
    func playSucceessFeedback() {
        AudioServicesPlaySystemSound(1394)
    }
    
    func playFailFeedback() {
        AudioServicesPlaySystemSound(1395)
    }
    
    func playNotificationFeedback() {
        AudioServicesPlaySystemSound(1504)
        notifitationFeedbackGenerator.notificationOccurred(.success)
    }
    
}
