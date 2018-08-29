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
    let maxLevel = 6
    
    var level: Int {
        set {
            userDefaults.set(newValue, forKey: levelKey)
        }
        get {
            return 0 // userDefaults.integer(forKey: levelKey)
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
    var winkNumbersMode     = false
    var winkColorsMode      = false
    
    /*
    var colorfulCellsMode: Bool {
        return level > 1 ? true : false
    }
    var shuffleNumbersMode: Bool {
        return level > 2 ? true : false
    }
    var shuffleColorsMode: Bool {
        return level > 3 ? true : false
    }
    var winkNumbersMode: Bool {
        return level > 4 ? true : false
    }
    var winkColorsMode: Bool {
        return level > 5 ? true : false
    }
     */
    
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
    
    // MARK: -
    
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
            winkNumbersMode     = false
            winkColorsMode      = false
        case 1:
            colorfulCellsMode   = true
            shuffleColorsMode   = false
            shuffleNumbersMode  = false
            winkNumbersMode     = false
            winkColorsMode      = false
        case 2:
            colorfulCellsMode   = true
            shuffleColorsMode   = false
            shuffleNumbersMode  = true
            winkNumbersMode     = false
            winkColorsMode      = false
        case 3:
            colorfulCellsMode   = true
            shuffleColorsMode   = true
            shuffleNumbersMode  = true
            winkNumbersMode     = false
            winkColorsMode      = false
        case 4:
            colorfulCellsMode   = true
            shuffleColorsMode   = true
            shuffleNumbersMode  = true
            winkNumbersMode     = true
            winkColorsMode      = true
        default:
            break
        }
    }
    
}
