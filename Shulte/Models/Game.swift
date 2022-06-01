//
//  Game.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/5/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import UIKit

protocol GameDelegate: AnyObject {
    
    func game(_ game: Game, didChangeLevelTo level: Level)
    func game(_ game: Game, didFinishSession session: GameSession)
}

final class Game {
    
    // MARK: - Public Properties
    
    weak var delegate: GameDelegate?
    
    let maxLevel = 10

    private(set) var levels = [Level]()
    private(set) var numbers = [Int]()
    private(set) var session: GameSession!
    private(set) var isRunning = false
    
    var currentLevel: Level {
        return levels.first { $0.isSelected }!
    }
    
    var nextLevel: Level? {
        let nextLevelIndex = currentLevel.index + 1
        if levels.indices.contains(nextLevelIndex) {
            return levels[nextLevelIndex]
        }
        return nil
    }
    
    var lastLevel: Level {
        return levels.last!
    }
    
    // MARK: - Private Properties
    
    private var memoryManager = MemoryManager.shared
    private var intervalTimer: Timer?
    private var gameSessionTimer: Timer?
    #if PROD
    private let firebaseManager = FirebaseManager()
    #endif
    
    // MARK: - Initialization
    
    init() {
        loadLevels()
        new()
                
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    // MARK: - Actions
    
    @objc internal func timerSceduled(_ timer: Timer) {
        #if !TEST
        finish(reason: .timeIsOver)
        #endif
    }
    
    // MARK: - Public Methods
    
    func numberSelected(_ number: Int) -> Bool { // Returns true if selected number is right
        #if FASTLANE
        setLevelPassed(currentLevel)
        session.levelPassed = true
        session.numbersFound = currentLevel.goal
        finish(reason: .levelPassed)
        return true
        #else
        
        guard number == session.nextNumber else {
            finish(reason: .wrongNumberTapped)
            return false
        }
        
        session.numbersFound += 1
        session.nextNumber += 1
        session.currentNumber += 1
        session.newNumber = number + currentLevel.numbersCount
        
        if number == currentLevel.goal, !currentLevel.isPassed {
            setLevelPassed(currentLevel)
            session.levelPassed = true
            finish(reason: .levelPassed)
            return false
        }
        
        if number > currentLevel.record {
            session.hasNewRecord = true
        }
        
        if currentLevel.shuffleMode {
            shuffleNumbers()
        }
        
        guard let index = numbers.firstIndex(of: number) else {
            fatalError("Current number didn't find in numbers array")
        }
        numbers[index] = number + numbers.count
        
        intervalTimer?.invalidate()
        setIntevalTimer(to: currentLevel.interval)
        
        return true
        #endif
    }
    
    func new() {
        setNumbers(count: currentLevel.numbersCount)
        session = GameSession(level: currentLevel)
        session.nextLevel = nextLevel
    }
    
    func start() {
        session.startTime = Date()
        isRunning = true
        setIntevalTimer(to: currentLevel.interval)
    }
    
    func finish(reason: GameSessionFinishingReason) {
        session.finishingReason = reason
        session.finishTime = Date()
        isRunning = false
        intervalTimer?.invalidate()
        
        if reason != .stopped {
            setNewRecord()
        }
        
        delegate?.game(self, didFinishSession: session)
             
        if reason == .levelPassed {
            openNextLevel()
        }
    }
    
    func shuffleNumbers() {
        numbers.shuffle()
    }
    
    func setCurrentLevel(to index: Int) {
        let selectedLevelIndex = levels.firstIndex { $0.isSelected }
        if let i = selectedLevelIndex {
            levels[i].isSelected = false
            levels[index].isSelected = true
            session.level = currentLevel
            session.nextLevel = nextLevel
            new()
            delegate?.game(self, didChangeLevelTo: levels[index])
        }
    }
    
    // MARK: - Private Methods
    
    private func setNumbers(count: Int) {
        if count <= 0 { return }
        numbers.removeAll()
        for i in 1...count {
            numbers.append(i)
        }
        numbers.shuffle()
    }
    
    private func loadLevels() {
        #if TEST || FASTLANE
        self.levels = configureLevels()
        #else
        if let levels = memoryManager.loadLevels() {
            self.levels = levels
        } else {
            self.levels = configureLevels()
            memoryManager.saveLevels(self.levels)
        }
        #endif
    }
    
    private func configureLevels() -> [Level] {
        let parameters = LevelParameters()
        
        var levels = [Level]()
        
        for i in 1...maxLevel {
            let serial = i
            let index = i - 1
            let numbers = parameters.numbersCountForLevel[i]!
            let interval = parameters.intervalForLevel[i]!
            let goal = parameters.goalForLevel[i]!
            let colorMode = parameters.colorModeForLevel[i]!
            let winkMode = parameters.winkModeForLevel[i]!
            let swapMode = parameters.swapModeForLevel[i]!
            let shuffleMode = parameters.shuffleModeForLevel[i]!
            
            var isAvailable = i == 1
            #if TEST || FASTLANE
            isAvailable = true
            #endif
                        
            let level = Level(serial: serial,
                              index: index,
                              isAvailable: isAvailable,
                              isPassed: false,
                              isSelected: i == 1,
                              record: 0,
                              numbersCount: numbers,
                              interval: interval,
                              goal: goal,
                              colorMode: colorMode,
                              winkMode: winkMode,
                              swapMode: swapMode,
                              shuffleMode: shuffleMode)
            
            levels.append(level)
        }
        
        return levels
    }
    
    private func openNextLevel() {
        if let nextLevel = nextLevel {
            setLevelAvailable(nextLevel)
            setCurrentLevel(to: nextLevel.index)
        }
    }
    
    private func setLevelPassed(_ level: Level) {
        guard let index = levels.firstIndex(of: level) else { return }
        levels[index].isPassed = true
        #if PROD
        firebaseManager.logLevelPassed(levels[index].serial)
        #endif
    }
    
    private func setLevelAvailable(_ level: Level) {
        guard let index = levels.firstIndex(of: level) else { return }
        levels[index].isAvailable = true
    }
    
    private func setNewRecord() {
        if currentLevel.record < session.numbersFound {
            levels[currentLevel.index].record = session.numbersFound
            session.level = currentLevel
        }
    }
    
    private func setIntevalTimer(to time: Double) {
        intervalTimer = Timer.scheduledTimer(timeInterval: time,
                                     target: self,
                                     selector: #selector(timerSceduled(_:)),
                                     userInfo: nil,
                                     repeats: false)
    }
    
}

// MARK: - Notifications

extension Game {
    
    @objc internal func applicationWillResignActive() {
        #if !TEST
        memoryManager.saveLevels(levels)
        #endif
    }
}
