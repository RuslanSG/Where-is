//
//  GameSession.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/18/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation

enum GameSessionFinishingReason {
    case wrongNumberTapped, timeIsOver, levelPassed, stopped
}

struct GameSession {
    
    var level: Level
    var nextLevel: Level?
        
    var currentNumber = 0
    var nextNumber = 1
    var numbersFound = 0
    var newNumber = -1
    var hasNewRecord = false
    var levelPassed = false
    var goalAchieved: Bool {
        return level.goal <= numbersFound
    }

    var finishingReason: GameSessionFinishingReason?
    
    var startTime: Date?
    var finishTime: Date?
    var timeTaken: TimeInterval? {
        if let startTime = startTime, let finishTime = finishTime {
            return finishTime.timeIntervalSinceReferenceDate - startTime.timeIntervalSinceReferenceDate
        }
        return nil
    }

}
