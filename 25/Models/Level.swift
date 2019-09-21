//
//  Level.swift
//  StackViewTest
//
//  Created by Ruslan Gritsenko on 4/15/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation

struct Level: Codable, Equatable {
    
    var serial: Int
    var index: Int
    var isAvailable: Bool
    var isPassed: Bool
    var isSelected: Bool
    var record: Int
    
    var numbersCount: Int
    var interval: Double
    var goal: Int
    
    var colorMode: Bool
    var winkMode: Bool
    var swapMode: Bool
    var shuffleMode: Bool
        
}
