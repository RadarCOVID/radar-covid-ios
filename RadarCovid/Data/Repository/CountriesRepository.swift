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

protocol CountriesRepository {
    
    func getCountries() -> [ItemCountry]?
    func setCountries(_ countries: [ItemCountry])
    
}

class UserDefaultsCountriesRepository: CountriesRepository {
    private static let kCountries = "UserDefaultsLocalizationRepository.kcountries"
    
    private let userDefaults: UserDefaults
    
    init() {
        userDefaults = UserDefaults(suiteName: Bundle.main.bundleIdentifier) ?? UserDefaults.standard
    }
    
    
    func getCountries() -> [ItemCountry]? {
        if let dataCountries = userDefaults.object(forKey: UserDefaultsCountriesRepository.kCountries) as? Data {
            let countries = try! JSONDecoder().decode(Countries.self, from: dataCountries)
            return countries.itemCountries
        }
        return nil
    }
    
    func setCountries(_ countries: [ItemCountry]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Countries.init(itemCountries: countries)) {
            userDefaults.set(encoded, forKey: UserDefaultsCountriesRepository.kCountries)
        }
    }
    
    
}
