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
        
    var currentNumber: Int
    var nextNumber: Int
    var numbersFound: Int
    var newNumber: Int

    var finishingReason: GameSessionFinishingReason?
    
    var startTime: Date?
    var finishTime: Date?
    var timeTaken: TimeInterval? {
        if let startTime = startTime, let finishTime = finishTime {
            return finishTime.timeIntervalSinceReferenceDate - startTime.timeIntervalSinceReferenceDate
        }
        return nil
    }
    
    // MARK: - Initialization
    
    init(level: Level) {
        currentNumber = 0
        nextNumber = 1
        numbersFound = 0
        newNumber = -1
        self.level = level
    }
}
