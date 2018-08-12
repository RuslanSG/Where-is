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
    
    func newGame() {
        nextNumberToTap = 1
        elapsedTime = 0.0
        setNumbers(count: numberOfNumbers)
    }
    
    // MARK: - Initialization
    
    init(numberOfNumbers: Int) {
        setNumbers(count: numberOfNumbers)
    }
    
    // MARK: - Helping Methods
    
    private func setNumbers(count: Int) {
        numberOfNumbers = count
        numbers.removeAll()
        for i in 1...numberOfNumbers {
            numbers.append(i)
        }
        numbers.shuffle()
    }
    
}
