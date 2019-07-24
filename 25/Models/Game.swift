//
//  Game.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/5/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation

enum GameFinishingReason {
    case wrongNumberTapped, timeIsOver
}

protocol GameDelegate: class {
    
    func gameFinished(reason: GameFinishingReason, numbersFound: Int)
}

final class Game {
    
    weak var delegate: GameDelegate?
    
    private(set) var numbers = [Int]()
    private(set) var nextNumber = 1
    private(set) var isRunning = false
    private(set) var selectedNumberIsRight = false
    private(set) var numbersFound = 0
    private(set) var interval = 5.0
    
    var level: Level {
        return levels[0] //levels[currentLevelIndex]
    }
    
    private var timer: Timer?
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
    
    // MARK: - Actions
    
    @objc internal func timerSceduled(_ timer: Timer) {
        delegate?.gameFinished(reason: .timeIsOver, numbersFound: numbersFound)
    }
    
    // MARK: - Public Methods
    
    func numberSelected(_ number: Int) {
        if number == nextNumber {
            selectedNumberIsRight = true
            numbersFound += 1
            nextNumber += 1
            guard let index = numbers.firstIndex(of: number) else { return }
            numbers[index] = number + numbers.count
            timer?.invalidate()
            setTimer(to: interval)
        } else {
            delegate?.gameFinished(reason: .wrongNumberTapped, numbersFound: numbersFound)
            selectedNumberIsRight = false
        }
    }
    
    func newGame() {
        finishGame()
        setNumbers(count: level.numbers)
        nextNumber = 1
        numbersFound = 0
    }
    
    func startGame() {
        isRunning = true
        setTimer(to: interval)
    }
    
    func finishGame() {
        isRunning = false
        timer?.invalidate()
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
        numbers.shuffle()
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
    
    private func setTimer(to time: Double) {
        timer = Timer.scheduledTimer(timeInterval: time,
                                     target: self,
                                     selector: #selector(timerSceduled(_:)),
                                     userInfo: nil,
                                     repeats: false)
    }
    
}
