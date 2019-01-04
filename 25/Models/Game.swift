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
    func levelChanged(to level: Int)
    func timeIsOut()
    
}

class Game {
    
    // MARK: - Delegate
    
    var delegate: GameDelegate?
    
    // MARK: - Timer
    
    private var timer = Timer()
    
    // MARK: - Constants
    
    /// Level modes
    private let levelsWithColorfulCellsMode = [2, 5, 7, 9, 10, 14, 18, 19, 20, 22, 24, 25, 26, 27, 28, 29, 30]
    private let levelsWithShuffleColorsMode = [5, 9, 10, 18, 19, 20, 24, 25, 26, 27, 28, 29, 30]
    private let levelsWithColorfulNumbersMode = [5, 9, 10, 18, 19, 20, 24, 25, 26, 27, 28, 29, 30]
    
    private let levelsWithWinkNumbersMode = [3, 10, 12, 16, 19, 20, 24, 25, 27, 28, 30]
    private let levelsWithSwapNumbersMode = [8, 17, 23, 29]
    private let levelsWithShuffleNumbersMode = [6, 13, 20, 21, 24, 28, 30]
   
    /// Levels cell count
    private let levelsWith25 = [1, 2, 3, 5, 6, 8, 10, 20]
    private let levelsWith30 = [4, 7, 9, 12, 13, 17, 19, 24]
    private let levelsWith35 = [11, 14, 16, 18, 21, 23, 25, 28]
    private let levelsWith40 = [15, 22, 26, 27, 29, 30]
    
    /// Goals dictionary: [level : goal(sec)]
    private let goals = [1  : 27.5,
                         2  : 34.0,
                         3  : 35.5,
                         4  : 37.5,
                         5  : 40.0,
                         6  : 43.0,
                         7  : 43.5,
                         8  : 45.5,
                         9  : 51.5,
                         10 : 52.0,
                         11 : 53.0,
                         12 : 54.0,
                         13 : 55.0,
                         14 : 59.5,
                         15 : 62.5,
                         16 : 63.0,
                         17 : 63.0,
                         18 : 68.0,
                         19 : 68.0,
                         20 : 70.0,
                         21 : 70.5,
                         22 : 75.0,
                         23 : 77.0,
                         24 : 85.0,
                         25 : 95.0,
                         26 : 95.45,
                         27 : 129.0,
                         28 : 136.5,
                         29 : 142.0,
                         30 : 167.0]
    
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
                delegate?.colorfulCellsModeStateChanged(to: colorfulCellsMode)
            }
            if maxNumber != maxNumberOldValue {
                self.setNumbers(count: maxNumber)
                delegate?.maxNumberChanged(to: maxNumber)
            }
            
            delegate?.levelChanged(to: level)
            
            UserDefaults.standard.set(level, forKey: UserDefaults.Key.Level)
        }
    }
    
    var goal: Double {
        guard let goal = goals[level] else { return 0.0 }
        return goal
    }
    
    var fine = 0.0
    let fineToAdd = 1.0
    
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
        } else {
            self.fine += fineToAdd
            let currentTime = Date.timeIntervalSinceReferenceDate
            let passedTime = currentTime - startTime
            let timeLeft = goal - passedTime - fine

            // Setting timer with fine
            timer.invalidate()
            timer = Timer.scheduledTimer(
                timeInterval: TimeInterval(timeLeft),
                target: self,
                selector: #selector(timerSceduled),
                userInfo: nil,
                repeats: false
            )
        }
    }
    
    func selectedNumberIsRight(_ number: Int) -> Bool {
        return number == nextNumberToTap
    }
    
    func goalAchieved() -> Bool {
        guard let goalTime = goals[level] else { return true }
        return elapsedTime < goalTime
    }
    
    func startGame() {
        inGame = true
        startTime = Date.timeIntervalSinceReferenceDate
        
        // Setting timer
        timer = Timer.scheduledTimer(
                timeInterval: TimeInterval(goal),
                target: self,
                selector: #selector(timerSceduled),
                userInfo: nil,
                repeats: false
        )
    }
    
    func finishGame() {
        inGame = false
        let finishTime = Date.timeIntervalSinceReferenceDate
        elapsedTime = finishTime - startTime
        timer.invalidate()
//        #warning("!")
        Analytics.logEvent("level_\(level)", parameters: ["passed" : "true"])
    }
    
    func newGame() {
        inGame = false
        nextNumberToTap = 1
        elapsedTime = 0.0
        fine = 0.0
        numbers.shuffle()
        timer.invalidate()
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
    
    @objc private func timerSceduled() {
        delegate?.timeIsOut()
        //        #warning("!")
        Analytics.logEvent("level_\(level)", parameters: ["passed" : "false"])
    }
    
}
