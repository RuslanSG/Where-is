//
//  Engine.swift
//  25
//
//  Created by Ruslan Gritsenko on 08.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import Foundation

class Game {
    
    var numberOfNumbers: Int!
    var nextNumberToTap = 1
    var numbers = [Int]()
    var elapsedTime: Double!
    
    private var startTime = TimeInterval()
    
    func startGame() {
        startTime = Date.timeIntervalSinceReferenceDate
    }
    
    func numberSelected() {
        nextNumberToTap += 1
    }
    
    func finishGame() {
        let finishTime = Date.timeIntervalSinceReferenceDate
        elapsedTime = finishTime - startTime
    }
    
    // MARK: - Initialization
    
    init(numberOfNumbers: Int) {
        self.numberOfNumbers = numberOfNumbers
        
        for i in 1...numberOfNumbers {
            numbers.append(i)
        }
        numbers.shuffle()
    }
    
}
