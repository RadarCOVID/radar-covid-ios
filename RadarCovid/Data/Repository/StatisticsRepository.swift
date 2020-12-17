//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import Foundation

protocol StatisticsRepository {
    
    func getStatistics() -> [StatsItemModel]?
    func setStatistics(_ stats: [StatsItemModel])
    
}

class UserDefaultsStatisticsRepository: StatisticsRepository {
    
    private static let kStats = "UserDefaultsStatisticsRepository.kstats"
    
    private let userDefaults: UserDefaults
    
    init() {
        userDefaults = UserDefaults(suiteName: Bundle.main.bundleIdentifier) ?? UserDefaults.standard
    }
    
    func getStatistics() -> [StatsItemModel]? {
        if let statsData = userDefaults.object(forKey: UserDefaultsStatisticsRepository.kStats) as? Data {
            let stats = try! JSONDecoder().decode(StatsModel.self, from: statsData)
            return stats.stats
        }
        return nil
    }
    
    func setStatistics(_ stats: [StatsItemModel]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(StatsModel.init(stats: stats)) {
            userDefaults.set(encoded, forKey: UserDefaultsStatisticsRepository.kStats)
        }
    }
    
   
    
 
    
    
}
