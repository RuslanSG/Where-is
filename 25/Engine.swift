//
//  Engine.swift
//  25
//
//  Created by Ruslan Gritsenko on 08.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import Foundation

class Game {
        
    private let userDefaults = UserDefaults.standard
    private let levelKey = "level"
    
    let minLevel = 1
    let maxLevel = 5
    
    var level: Int {
        set {
            userDefaults.set(newValue, forKey: levelKey)
            setGameMode(level: newValue - 1)
        }
        get {
            return userDefaults.integer(forKey: levelKey)
        }
    }
    
    var colums  = 5
    var rows = 5 {
        didSet {
            setNumbers(count: maxNumber)
        }
    }

    var shuffleNumbersMode  = false
    var colorfulCellsMode   = false
    var colorfulNumbersMode = false
    var shuffleColorsMode   = false
    var winkMode            = false
    
    let maxPossibleNumber = 35
    let minPossibleNumber = 25
    
    var maxNumber: Int {
        return rows * colums
    }
    
    var nextNumberToTap = 1
    var numbers = [Int]()
    
    private var startTime = TimeInterval()
    private(set) var elapsedTime: Double!
    
    var inGame = false
    
    func numberSelected(_ number: Int) {
        if number == nextNumberToTap {
            nextNumberToTap += 1
        }
    }
    
    func selectedNumberIsRight(_ number: Int) -> Bool {
        return number == nextNumberToTap
    }
    
    func startGame() {
        inGame = true
        startTime = Date.timeIntervalSinceReferenceDate
    }
    
    func finishGame() {
        inGame = false
        let finishTime = Date.timeIntervalSinceReferenceDate
        elapsedTime = finishTime - startTime
        if elapsedTime <= 60.0 {
            level += 1
        }
    }
    
    func newGame() {
        inGame = false
        nextNumberToTap = 1
        elapsedTime = 0.0
        numbers.shuffle()
    }
    
    func shuffleNumbers() {
        numbers.shuffle()
    }
    
    // MARK: - Initialization
    
    init() {
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
            colorfulCellsMode   = false
            shuffleColorsMode   = false
            shuffleNumbersMode  = false
            winkMode            = false
        case 1:
            colorfulCellsMode   = true
            shuffleColorsMode   = false
            shuffleNumbersMode  = false
            winkMode            = false
        case 2:
            colorfulCellsMode   = true
            shuffleColorsMode   = false
            shuffleNumbersMode  = true
            winkMode            = false
        case 3:
            colorfulCellsMode   = true
            shuffleColorsMode   = true
            shuffleNumbersMode  = true
            winkMode            = false
        case 4:
            colorfulCellsMode   = true
            shuffleColorsMode   = true
            shuffleNumbersMode  = true
            winkMode            = true
        default:
            break
        }
    }
    
}
