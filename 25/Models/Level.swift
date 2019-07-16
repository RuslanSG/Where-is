//
//  Level.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/15/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation

class Level {
    
    var description: String {
        return "Index: \(index)\n" +
            "Numbers Count: \(numbers)\n" +
            "Passed:\(passed)\n" +
            "Available\(available)\n" +
            "Colorful Numbers: \(colorModeFor.numbers)\n" +
            "Colorful Cells: \(colorModeFor.cells)\n" +
            "Wink Mode: \(winkMode)\n" +
            "Swap Mode: \(swapMode)\n" +
        "Shuffle Mode \(shuffleMode)\n"
    }
    
    var index: Int
    var numbers: Int
    var goal: Double
    var available: Bool
    var passed: Bool
    
    var colorModeFor: (numbers: Bool, cells: Bool)
    var winkMode: Bool
    var swapMode: Bool
    var shuffleMode: Bool
    
    init(index: Int, numbersCount: Int, goal: Double, colorModeFor: (numbers: Bool, cells: Bool), winkMode: Bool, swapMode: Bool, shuffleMode: Bool) {
        self.index = index
        self.numbers = numbersCount
        self.goal = goal
        self.colorModeFor = colorModeFor
        self.winkMode = winkMode
        self.swapMode = swapMode
        self.shuffleMode = shuffleMode
        self.available = true
        self.passed = false
    }
    
}

