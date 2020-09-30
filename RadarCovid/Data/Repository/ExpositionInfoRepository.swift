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

protocol ExpositionInfoRepository {
    func getExpositionInfo() -> ExpositionInfo?
    func save(expositionInfo: ExpositionInfo)
    func isChangedToHealthy() -> Bool?
    func setChangedToHealthy(changed: Bool)
    func clearData()
}

class UserDefaultsExpositionInfoRepository: ExpositionInfoRepository {

    private static let kData = "UserDefaultsExpositionInfoRepository.expositionInfo"
    private static let kChanged = "UserDefaultsExpositionInfoRepository.changedToHealthy"

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private let userDefaults: UserDefaults

    init() {
        userDefaults = UserDefaults(suiteName: Bundle.main.bundleIdentifier) ?? UserDefaults.standard
    }

    func getExpositionInfo() -> ExpositionInfo? {
        if let uncoded = userDefaults.data(forKey: UserDefaultsExpositionInfoRepository.kData), !uncoded.isEmpty {
            return try? decoder.decode(ExpositionInfo.self, from: uncoded)
        }
        return nil
    }

    func save(expositionInfo: ExpositionInfo) {
        guard let encoded = try? encoder.encode(expositionInfo) else { return }
        userDefaults.set(encoded, forKey: UserDefaultsExpositionInfoRepository.kData)
    }

    func isChangedToHealthy() -> Bool? {
        userDefaults.object(forKey: UserDefaultsExpositionInfoRepository.kChanged) as? Bool
    }
    

    func setChangedToHealthy(changed: Bool) {
        userDefaults.set(changed, forKey: UserDefaultsExpositionInfoRepository.kChanged)
    }

    func clearData() {
        userDefaults.removeObject(forKey: UserDefaultsExpositionInfoRepository.kData)
        userDefaults.removeObject(forKey: UserDefaultsExpositionInfoRepository.kChanged)
    }

}
