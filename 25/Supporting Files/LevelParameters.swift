//
//  LevelParameters.swift
//  25
//
//  Created by Ruslan Gritsenko on 7/31/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation

struct LevelParameters {
    
    let colorModeForLevel = ([1  : false,
                              2  : false,
                              3  : false,
                              4  : false,
                              5  : true,
                              6  : true,
                              7  : true,
                              8  : true,
                              9  : true,
                              10  : true])
    
    let numbersCountForLevel = [1  : 25,
                                2  : 25,
                                3  : 25,
                                4  : 30,
                                5  : 30,
                                6  : 35,
                                7  : 35,
                                8  : 35,
                                9  : 35,
                                10  : 40]
    
    let winkModeForLevel = [1  : false,
                            2  : true,
                            3  : false,
                            4  : true,
                            5  : false,
                            6  : false,
                            7  : true,
                            8  : false,
                            9  : true,
                            10  : true]
    
    let swapModeForLevel = [1  : false,
                            2  : false,
                            3  : false,
                            4  : false,
                            5  : false,
                            6  : false,
                            7  : false,
                            8  : false,
                            9  : false,
                            10  : false]
    
    let shuffleModeForLevel = [1  : false,
                               2  : false,
                               3  : true,
                               4  : false,
                               5  : true,
                               6  : true,
                               7  : false,
                               8  : true,
                               9  : true,
                               10  : true]
    
    let intervalForLevel = [1  : 10.0,
                            2  : 9.5,
                            3  : 9.0,
                            4  : 8.5,
                            5  : 8.0,
                            6  : 7.5,
                            7  : 7.0,
                            8  : 6.5,
                            9  : 6.0,
                            10  : 5.0]

    let goalForLevel = [1  : 20,
                        2  : 25,
                        3  : 30,
                        4  : 35,
                        5  : 40,
                        6  : 45,
                        7  : 50,
                        8  : 55,
                        9  : 60,
                        10  : 65]

}
