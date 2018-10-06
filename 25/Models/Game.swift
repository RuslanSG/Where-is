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
    var colorfulNumbersMode = false
    var winkNumbersMode     = false
    var swapNumbersMode     = false
    
    var colorfulCellsMode   = false {
        didSet {
            if !colorfulCellsMode {
                shuffleColorsMode = false
                winkColorsMode = false
                colorfulNumbersMode = false
            }
        }
    }
    var shuffleColorsMode   = false
    var winkColorsMode      = false
    
    let maxPossibleNumber = 40
    let minPossibleNumber = 25
    
    var maxNumber: Int {
        return rows * colums
    }
    
    var nextNumberToTap = 1
    var numbers = [Int]()
    
    private var startTime = TimeInterval()
    private(set) var elapsedTime: Double!
    
    var inGame = false {
        didSet {
             NotificationCenter.default.post(
                name: Notification.Name.InGameStateDidChange,
                object: nil,
                userInfo: [Notification.UserInfoKey.InGame : inGame]
            )
        }
    }
    
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
    
}
