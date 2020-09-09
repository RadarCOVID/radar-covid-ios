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

protocol SettingsRepository {
    func getSettings() -> Settings?

    func save(settings: Settings?)
}

class UserDefaultsSettingsRepository: SettingsRepository {

    private static let kData = "UserDefaultsSettingsRepository.settings"

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private let userDefaults: UserDefaults

    init() {
        userDefaults = UserDefaults(suiteName: Bundle.main.bundleIdentifier) ?? UserDefaults.standard
    }

    func getSettings() -> Settings? {
        let uncoded = userDefaults.data(forKey: UserDefaultsSettingsRepository.kData) ?? Data()
        if uncoded.isEmpty {
            return nil
        }
        return try? decoder.decode(Settings.self, from: uncoded)
    }

    func save(settings: Settings?) {
        guard let encoded = try? encoder.encode(settings) else { return }
        userDefaults.set(encoded, forKey: UserDefaultsSettingsRepository.kData)
    }

}
