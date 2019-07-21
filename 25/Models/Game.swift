//
//  Game.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/5/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation

class Game {
    
    var numbers = [Int]()
    var nextNumber = 1
    var isRunning = false
    var level: Level {
        return levels[currentLevelIndex]
    }
    
    private var levels = [Level]()
    private var maxLevel = 30
    private var currentLevelIndex: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserDefaults.Key.levelIndex)
        }
        set {
            UserDefaults.standard.set(level, forKey: UserDefaults.Key.levelIndex)
        }
    }
    
    // MARK: - Initialization
    
    init() {
        setLevels()
        setNumbers(count: level.numbers)
        registerDefaults()
    }
    
    // MARK: - Public Methods
    
    func numberSelected(_ number: Int) {
        if number == nextNumber {
            nextNumber += 1
        }
    }
    
    func newGame(numbers: Int) {
        setNumbers(count: numbers)
        nextNumber = 1
        isRunning = false
    }
    
    func startGame() {
        isRunning = true
    }
    
    func finishGame() {
        isRunning = false
    }
    
    func shuffleNumbers() {
        numbers.shuffle()
    }
    
    func setLevel(_ levelIndex: Int) {
        currentLevelIndex = levelIndex
    }
    
    // MARK: - Private Methods
    
    private func setNumbers(count: Int) {
        if count <= 0 { return }
        numbers.removeAll()
        for i in 1...count {
            numbers.append(i)
        }
//        numbers.shuffle()
    }
    
    private func setLevels() {
        let parameters = LevelParameters()
        for i in 0...maxLevel {
            let index = i
            let numbersCount = parameters.numbersCountForLevel[i]!
            let goal = parameters.goalForLevel[i]!
            let colorsModeFor = (numbers: parameters.colorModeFor.numbersForLevel[i]!,
                                 cells: parameters.colorModeFor.cellsForLevel[i]!)
            let winkMode = parameters.winkModeForLevel[i]!
            let swapMode = parameters.swapModeForLevel[i]!
            let shuffleMode = parameters.shuffleModeForLevel[i]!
            
            let level = Level(index: index,
                              numbersCount: numbersCount,
                              goal: goal,
                              colorModeFor: colorsModeFor,
                              winkMode: winkMode,
                              swapMode: swapMode,
                              shuffleMode: shuffleMode)
            
            levels.append(level)
        }
    }
    
    // MARK: - Helper Methods
    
    private func registerDefaults() {
        let key = UserDefaults.Key.levelIndex
        let dictionary: [String: Any] = [key: 1]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
}
