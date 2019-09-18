//
//  Game.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/5/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import UIKit

protocol GameDelegate: class {
    
    func game(_ game: Game, didChangeLevelTo level: Level)
    func game(_ game: Game, didFinishSession session: GameSession)
}

final class Game {
    
    // MARK: - Public Properties
    
    weak var delegate: GameDelegate?
    
    let maxLevel = 10

    private(set) var levels = [Level]()
    private(set) var numbers = [Int]()
    private(set) lazy var session = GameSession(level: currentLevel)
    private(set) var isRunning = false
    
    var currentLevel: Level {
        return levels.first { $0.isSelected }!
    }
    
    var lastLevel: Level {
        return levels.last!
    }
    
    // MARK: - Private Properties
    
    private var memoryManager = MemoryManager.shared
    private var intervalTimer: Timer?
    private var gameSessionTimer: Timer?
    
    // MARK: - Initialization
    
    init() {
        loadLevels()
        setNumbers(count: currentLevel.numbersCount)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    // MARK: - Actions
    
    @objc internal func timerSceduled(_ timer: Timer) {
        finish(reason: .timeIsOver)
    }
    
    // MARK: - Public Methods
    
    func numberSelected(_ number: Int) -> Bool { // Returns if selected number is right
        guard number == session.nextNumber else {
            finish(reason: .wrongNumberTapped)
            return false
        }
        
        session.numbersFound += 1
        session.nextNumber += 1
        session.currentNumber += 1
        session.newNumber = number + currentLevel.numbersCount
        
        if number == currentLevel.goal {
            setLevelPassed(index: currentLevel.index)
            
            let nextLevelIndex = currentLevel.index + 1
            
            if levels.indices.contains(nextLevelIndex) {
                setLevelAvailable(index: nextLevelIndex)
                setCurrentLevel(index: nextLevelIndex)
            }
            
            finish(reason: .levelPassed)
            
            return false
        }
        
        guard let index = numbers.firstIndex(of: number) else { fatalError("Current number didn't find in numbers array") }
        numbers[index] = number + numbers.count
        
        intervalTimer?.invalidate()
        setIntevalTimer(to: currentLevel.interval)
        
        return true
    }
    
    func new() {
        setNumbers(count: currentLevel.numbersCount)
        session = GameSession(level: currentLevel)
    }
    
    func start() {
        session.startTime = Date()
        isRunning = true
        setIntevalTimer(to: currentLevel.interval)
    }
    
    func finish(reason: GameSessionFinishingReason) {
        session.finishingReason = reason
        session.finishTime = Date()
        delegate?.game(self, didFinishSession: session)
        isRunning = false
        intervalTimer?.invalidate()
    }
    
    func shuffleNumbers() {
        numbers.shuffle()
    }
    
    func setCurrentLevel(index: Int) {
        let selectedLevelIndex = levels.firstIndex { $0.isSelected }
        if let i = selectedLevelIndex {
            levels[i].isSelected = false
            levels[index].isSelected = true
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
        if let levels = memoryManager.loadLevels() {
            self.levels = levels
        } else {
            self.levels = configureLevels()
            memoryManager.saveLevels(self.levels)
        }
    }
    
    private func configureLevels() -> [Level] {
        let parameters = LevelParameters()
        
        var levels = [Level]()
        
        for i in 1...maxLevel {
            let serial = i
            let index = i - 1
            let numbers = parameters.numbersCountForLevel[i]!
            let interval = 15.0 //parameters.intervalForLevel[i]!
            let goal = 5 //parameters.goalForLevel[i]!
            let colorsModeFor = (numbers: parameters.colorModeFor.numbersForLevel[i]!,
                                 cells: parameters.colorModeFor.cellsForLevel[i]!)
            let winkMode = parameters.winkModeForLevel[i]!
            let swapMode = parameters.swapModeForLevel[i]!
            let shuffleMode = parameters.shuffleModeForLevel[i]!
            
            let level = Level(serial: serial,
                              index: index,
                              isAvailable: true, //i == 1,
                isPassed: false,
                isSelected: i == 1,
                numbersCount: numbers,
                interval: interval,
                goal: goal,
                colorfulNumbers: colorsModeFor.numbers,
                colorfulCells: colorsModeFor.cells,
                winkMode: winkMode,
                swapMode: swapMode,
                shuffleMode: shuffleMode)
            
            levels.append(level)
        }
        
        return levels
    }
    
    private func setLevelPassed(index: Int) {
        levels[index].isPassed = true
    }
    
    private func setLevelAvailable(index: Int) {
        levels[index].isAvailable = true
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
        memoryManager.saveLevels(levels)
    }
}
