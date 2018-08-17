//
//  Engine.swift
//  25
//
//  Created by Ruslan Gritsenko on 08.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import Foundation

class Game {
    
    static var shared = Game()
    
    var rows = 5 {
        didSet {
            setNumbers(count: numberOfNumbers)
        }
    }
    var colums  = 5

    var shuffleNumbersMode  = false
    var colorMode           = false
    var shuffleColorsMode   = false
    
    var numberOfNumbers: Int {
        return rows * colums
    }
    var nextNumberToTap = 1
    var numbers = [Int]()
    
    private var startTime = TimeInterval()
    private(set) var elapsedTime: Double!
    
    func startGame() {
        startTime = Date.timeIntervalSinceReferenceDate
    }
    
    func numberSelected(_ number: Int) {
        nextNumberToTap += 1
        print(number)
    }
    
    func finishGame() {
        let finishTime = Date.timeIntervalSinceReferenceDate
        elapsedTime = finishTime - startTime
    }
    
    func newGame() {
        nextNumberToTap = 1
        elapsedTime = 0.0
        numbers.shuffle()
    }
    
    func shuffleNumbers() {
        numbers.shuffle()
    }
    
    // MARK: - Initialization
    
    private init() {
        setNumbers(count: numberOfNumbers)
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
