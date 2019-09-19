//
//  MemoryManager.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/8/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import Foundation

final class MemoryManager {
    
    // MARK: - Public Properties
    
    static let shared = MemoryManager()
    
    // MARK: - Initialization
    
    private init() { }
    
    // MARK: - Public Methods
    
    func saveLevels(_ levels: [Level]) {
        let encoded = try? JSONEncoder().encode(levels)
        UserDefaults.standard.set(encoded, forKey: UserDefaults.Key.levels)
    }
    
    func loadLevels() -> [Level]? {
        guard let encoded = UserDefaults.standard.value(forKey: UserDefaults.Key.levels) as? Data else { return nil }
        guard let levels = try? JSONDecoder().decode([Level].self, from: encoded) else { return nil }
        return levels
    }
    
}
