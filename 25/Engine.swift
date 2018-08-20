//
//  Engine.swift
//  25
//
//  Created by Ruslan Gritsenko on 08.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import Foundation

class Game {
    
    static var shared = Game()
    
    private let userDefaults = UserDefaults.standard
    private let levelKey = "level"
    
    let maxLevel = 4
    
    var level: Int {
        set {
            userDefaults.set(newValue, forKey: levelKey)
            setGameMode(level: newValue)
        }
        get {
            let value = userDefaults.integer(forKey: levelKey)
            if value < maxLevel - 1 {
                return value
            } else {
                return maxLevel - 1
            }
        }
    }
    
    var colums  = 5
    var rows = 5 {
        didSet {
            setNumbers(count: maxNumber)
        }
    }

    var shuffleNumbersMode  = false
    var colorMode           = false
    var shuffleColorsMode   = false
    
    let maxPossibleNumber = 35
    var maxNumber: Int {
        return rows * colums
    }
    
    var nextNumberToTap = 1
    var numbers = [Int]()
    
    private var startTime = TimeInterval()
    private(set) var elapsedTime: Double!
    
    func startGame() {
        startTime = Date.timeIntervalSinceReferenceDate
    }
    
    func numberSelected(_ number: Int) {
        if number == nextNumberToTap {
            nextNumberToTap += 1
        }
    }
    
    func selectedNumberIsRight(_ number: Int) -> Bool {
        return number == nextNumberToTap
    }
    
    func finishGame() {
        let finishTime = Date.timeIntervalSinceReferenceDate
        elapsedTime = finishTime - startTime
        if elapsedTime <= 60.0 {
            level += 1
        }
    }
    
    func newGame() {
        nextNumberToTap = 1
        elapsedTime = 0.0
        numbers.shuffle()
    }
    
    func shuffleNumbers() {
        numbers.shuffle()
    }
    
    // MARK: - Initialization
    
    private init() {
        setNumbers(count: maxNumber)
        setGameMode(level: level)
    }
    
    // MARK: - Helping Methods
    
    private func setNumbers(count: Int) {
        numbers.removeAll()
        for i in 1...count {
            numbers.append(i)
        }
        numbers.shuffle()
    }
    
    private func setGameMode(level: Int) {
        switch level {
        case 0:
            colorMode           = false
            shuffleColorsMode   = false
            shuffleNumbersMode  = false
        case 1:
            colorMode           = true
            shuffleColorsMode   = false
            shuffleNumbersMode  = false
        case 2:
            colorMode           = true
            shuffleColorsMode   = false
            shuffleNumbersMode  = true
        case 3:
            colorMode           = true
            shuffleColorsMode   = true
            shuffleNumbersMode  = true
        default:
            break
        }
    }
    
}
