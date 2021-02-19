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


protocol AnalyticsRepository {
    
    func getLastRun() -> Date?
    func save(lastRun: Date)
    
}

class UserDefaultsAnalyticsRepository: UserDefaultsRepository, AnalyticsRepository {
        
    private static let kLastRun = "UserDefaultsSettingsRepository.lastRun"
    
    func getLastRun() -> Date? {
        let uncoded = userDefaults.data(forKey: UserDefaultsAnalyticsRepository.kLastRun) ?? Data()
        if uncoded.isEmpty {
            return nil
        }
        return try? decoder.decode(Date.self, from: uncoded)
    }
    
    func save(lastRun: Date) {
        guard let encoded = try? encoder.encode(lastRun) else { return }
        userDefaults.set(encoded, forKey: UserDefaultsAnalyticsRepository.kLastRun)
    }
    
    
}


