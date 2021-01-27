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


protocol ExposureKpiRepository {
    func getLastExposition() -> Date?
    func save(lastExposition: Date?)
}

class UserDefaultsExposureKpiRepository: ExposureKpiRepository {
        
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private let userDefaults: UserDefaults

    init() {
        userDefaults = UserDefaults(suiteName: Bundle.main.bundleIdentifier) ?? UserDefaults.standard
    }
    
    private static let kLastExposition = "UserDefaultsExposureKpiRepository.lastExposition"
    
    func getLastExposition() -> Date? {
        let uncoded = userDefaults.data(forKey: UserDefaultsExposureKpiRepository.kLastExposition) ?? Data()
        if uncoded.isEmpty {
            return nil
        }
        return try? decoder.decode(Date.self, from: uncoded)
    }
    
    func save(lastExposition: Date?) {
        guard let encoded = try? encoder.encode(lastExposition) else { return }
        userDefaults.set(encoded, forKey: UserDefaultsExposureKpiRepository.kLastExposition)
    }
    
    
}
