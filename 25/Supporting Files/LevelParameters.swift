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
                              3  : true,
                              4  : false,
                              5  : false,
                              6  : false,
                              7  : false,
                              8  : true,
                              9  : true,
                              10  : true])
    
    let numbersCountForLevel = [1  : 25,
                                2  : 30,
                                3  : 25,
                                4  : 30,
                                5  : 30,
                                6  : 30,
                                7  : 35,
                                8  : 35,
                                9  : 35,
                                10  : 40]
    
    let winkModeForLevel = [1  : false,
                            2  : false,
                            3  : false,
                            4  : true,
                            5  : false,
                            6  : true,
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
                               3  : false,
                               4  : false,
                               5  : true,
                               6  : false,
                               7  : false,
                               8  : true,
                               9  : true,
                               10  : true]
    
    let intervalForLevel = [1  : 15.0,
                            2  : 14.0,
                            3  : 12.0,
                            4  : 11.0,
                            5  : 10.0,
                            6  : 9.0,
                            7  : 8.0,
                            8  : 8.0,
                            9  : 8.0,
                            10  : 7.0]

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
