//
//  LevelParametersTest.swift
//  25
//
//  Created by Ruslan Gritsenko on 7/31/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation

struct LevelParametersTest {
    
    let colorModeFor = (cellsForLevel: [1  : false,
                                        2  : false,
                                        3  : true,
                                        4  : true,
                                        5  : true],
                        
                        numbersForLevel: [1  : false,
                                          2  : false,
                                          3  : false,
                                          4  : true,
                                          5  : true])
    
    let numbersCountForLevel = [1  : 25,
                                2  : 25,
                                3  : 30,
                                4  : 30,
                                5  : 40]
    
    let winkModeForLevel = [1  : false,
                            2  : false,
                            3  : true,
                            4  : false,
                            5  : true]
    
    let swapModeForLevel = [1  : false,
                            2  : false,
                            3  : false,
                            4  : false,
                            5  : false]
    
    let shuffleModeForLevel = [1  : false,
                               2  : false,
                               3  : false,
                               4  : true,
                               5  : true]
    
    let intervalForLevel = [1  : 7.0,
                            2  : 7.0,
                            3  : 7.0,
                            4  : 7.0,
                            5  : 7.0]
    
}
