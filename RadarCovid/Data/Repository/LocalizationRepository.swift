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

protocol LocalizationRepository {

    func getLocale() -> String?
    func setLocale(_ locale: String)

    func getLocales() -> [String: String?]?
    func setLocales(_ locales: [String: String?])

    func setTexts(_ texts: [String: String])
    func getTexts() -> [String: String]?

    func setCurrent(ca: CaData)
    func getCurrentCA() -> CaData?
}

class UserDefaultsLocalizationRepository: LocalizationRepository {

    private static let kLocale = "UserDefaultsLocalizationRepository.locale"
    private static let kLocales = "UserDefaultsLocalizationRepository.kLocales"
    private static let kTexts = "UserDefaultsLocalizationRepository.texts"
    private static let kCCAA = "UserDefaultsLocalizationRepository.kCCAA"
    private static let kCurrentCA = "UserDefaultsLocalizationRepository.kCurrentCa"

    private let userDefaults: UserDefaults

    init() {
        userDefaults = UserDefaults(suiteName: Bundle.main.bundleIdentifier) ?? UserDefaults.standard
    }

    func getLocale() -> String? {
        userDefaults.object(forKey: UserDefaultsLocalizationRepository.kLocale) as? String ?? self.getLocales()?.keys.filter({ (key) -> Bool in
            key.contains("es")
        }).first
    }

    func setLocale(_ locale: String) {
         userDefaults.set(locale, forKey: UserDefaultsLocalizationRepository.kLocale)
    }

    func setTexts(_ texts: [String: String]) {
        userDefaults.set(texts, forKey: UserDefaultsLocalizationRepository.kTexts)
    }

    func getTexts() -> [String: String]? {
        userDefaults.object(forKey: UserDefaultsLocalizationRepository.kTexts) as? [String: String]
    }

    func getCurrentCA() -> CaData? {
        try? PropertyListDecoder().decode(CaData.self, from: userDefaults.object(forKey: UserDefaultsLocalizationRepository.kCurrentCA) as? Data ?? Data())
    }

    func setCurrent(ca: CaData) {
        let data = try? PropertyListEncoder().encode(ca)
        userDefaults.set(data, forKey: UserDefaultsLocalizationRepository.kCurrentCA)
    }

    func getLocales() -> [String: String?]? {
         userDefaults.object(forKey: UserDefaultsLocalizationRepository.kLocales) as? [String: String?]
    }

    func setLocales(_ localea: [String: String?]) {
        userDefaults.set(localea, forKey: UserDefaultsLocalizationRepository.kLocales)
    }

}
