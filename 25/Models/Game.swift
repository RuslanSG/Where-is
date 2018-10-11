//
//  Engine.swift
//  25
//
//  Created by Ruslan Gritsenko on 08.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import Foundation

protocol GameDelegate {
    
    func colorfulCellsModeStateChanged(to state: Bool)
    func maxNumberChanged(to maxNumber: Int)
    
}

class Game {
    
    // MARK: - Delegate
    
    var delegate: GameDelegate!
    
    // MARK: - Constants
    
    private let levelsWithShuffleNumbersMode = [13, 17, 19]
    private let levelsWithColorfulNumbersMode = [4, 8, 10, 13, 15, 16, 17, 18, 19]
    private let levelsWithWinkNumbersMode = [8, 13, 16, 17, 18, 19]
    private let levelsWithSwapNumbersMode = [5]
    private let levelsWithColorfulCellsMode = [2, 3, 4, 7, 8, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19]
    private let levelsWithShuffleColorsMode = [2, 3, 4, 8, 9, 10, 13, 14, 15, 16, 17, 18, 19]
   
    private let levelsWith25 = [1, 2, 3, 4, 5, 8, 13]
    private let levelsWith30 = [6, 7, 9, 10, 16, 17]
    private let levelsWith35 = [11, 12, 14, 15, 18, 19]
    private let levelsWith40 = [Int]()
    
    let minLevel = 1
    let maxLevel = 19
    
    var level: Int {
        didSet {
            let colorfulCellModeOldValue = levelsWithColorfulCellsMode.contains(oldValue)
            let maxNumberOldValue = maxNumber(for: oldValue)
            
            if colorfulCellsMode != colorfulCellModeOldValue {
                delegate.colorfulCellsModeStateChanged(to: colorfulCellsMode)
            }
            if maxNumber != maxNumberOldValue {
                self.setNumbers(count: maxNumber)
                delegate.maxNumberChanged(to: maxNumber)
            }
            
            UserDefaults.standard.set(level, forKey: UserDefaults.Key.Level)
        }
    }
    
    var colums = 5
    var rows: Int {
        set {
            setNumbers(count: maxNumber)
        }
        get {
            return self.maxNumber / colums
        }
    }
    
    let maxPossibleNumber = 40
    let minPossibleNumber = 25
    
    var maxNumber: Int {
        return maxNumber(for: level)
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
    
    // MARK: - Game Modes
    
    var shuffleNumbersMode: Bool {
        if self.levelsWithShuffleNumbersMode.contains(level) {
            return true
        }
        return false
    }
    
    var colorfulNumbersMode: Bool {
        if self.levelsWithColorfulNumbersMode.contains(level) {
            return true
        }
        return false
    }
    
    var winkNumbersMode: Bool {
        if self.levelsWithWinkNumbersMode.contains(level) {
            return true
        }
        return false
    }
    
    var swapNumbersMode: Bool {
        if self.levelsWithSwapNumbersMode.contains(level) {
            return true
        }
        return false
    }
    
    var colorfulCellsMode: Bool {
        if self.levelsWithColorfulCellsMode.contains(level) {
            return true
        }
        return false
    }
    
    var shuffleColorsMode: Bool {
        if self.levelsWithShuffleColorsMode.contains(level) {
            return true
        }
        return false
    }
    
    // MARK: - Game Actions
    
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
        let level = UserDefaults.standard.integer(forKey: UserDefaults.Key.Level)
        self.level = level == 0 ? 1 : level

        self.setNumbers(count: maxNumber)
    }
    
    // MARK: - Helping Methods
    
    private func setNumbers(count: Int) {
        numbers.removeAll()
        for i in 1...count {
            numbers.append(i)
        }
        numbers.shuffle()
    }
    
    private func maxNumber(for level: Int) -> Int {
        if levelsWith25.contains(level) {
            return 25
        } else if levelsWith30.contains(level) {
            return 30
        } else if levelsWith35.contains(level) {
            return 35
        } else if levelsWith40.contains(level) {
            return 40
        }
        return 0
    }
    
}
