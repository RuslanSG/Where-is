//
//  Engine.swift
//  25
//
//  Created by Ruslan Gritsenko on 08.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import Firebase

protocol GameDelegate {
    
    func colorfulCellsModeStateChanged(to state: Bool)
    func maxNumberChanged(to maxNumber: Int)
    
}

class Game {
    
    // MARK: - Delegate
    
    var delegate: GameDelegate!
    
    // MARK: - Constants
    
    private let levelsWithColorfulCellsMode = [2, 3, 8, 9, 10, 15, 16, 17, 22, 23, 24, 25, 26, 27, 28, 29, 30]
    private let levelsWithShuffleColorsMode = [3, 9, 10, 16, 17, 23, 24, 25, 26, 27, 28, 29, 30]
    private let levelsWithColorfulNumbersMode = [3, 9, 10, 16, 17, 23, 24, 25, 26, 27, 28, 29, 30]
    
    private let levelsWithWinkNumbersMode = [5, 9, 11, 16, 18, 24, 25, 26, 27, 28, 30]
    private let levelsWithSwapNumbersMode = [4, 12, 19, 29]
    private let levelsWithShuffleNumbersMode = [6, 13, 16, 20, 25, 27, 30]
   
    private let levelsWith25 = [1, 2, 3, 4, 5, 6, 9, 16]
    private let levelsWith30 = [7, 8, 10, 11, 12, 13, 24, 25]
    private let levelsWith35 = [14, 15, 17, 18, 19, 20, 26, 27]
    private let levelsWith40 = [21, 22, 23, 28, 29, 30]
    
    let minLevel = 1
    let maxLevel = 30
    
    private enum LevelChanger {
        case up
        case down
    }
    
    private var needsToUpLevel: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Key.LevelChanger)
        }
        get {
            guard let levelChanger = UserDefaults.standard.value(forKey: UserDefaults.Key.LevelChanger) as? Bool else { return true }
            return levelChanger
        }
    }
    
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
        Analytics.logEvent("level_\(level)", parameters: ["time" : NSNumber(floatLiteral: elapsedTime)])
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
    
    func changeLevel() {
        if self.level == maxLevel {
            needsToUpLevel = false
        } else if self.level == minLevel {
            needsToUpLevel = true
        }
        if self.needsToUpLevel {
            level += 1
        } else {
            level -= 1
        }
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
