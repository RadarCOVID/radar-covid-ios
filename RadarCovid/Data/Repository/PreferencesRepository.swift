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

protocol PreferencesRepository {
    
    func isOnBoardingCompleted() -> Bool
    func setOnboarding(completed: Bool)
    
    func isTracingActive() -> Bool
    func setTracing(active: Bool)

    func getLastSync() -> Date?
    func setLastSync(date: Date)

    func isTracingInit() -> Bool
    func setTracing(initialized: Bool)
}

class UserDefaultsPreferencesRepository: PreferencesRepository {

    private static let kOnboarding = "UserDefaultsPreferencesRepository.onboarding"
    private static let kTracing = "UserDefaultsPreferencesRepository.tracing"
    private static let kTracingInit = "UserDefaultsPreferencesRepository.tracingInit"
    private static let kSyncDate = "UserDefaultsPreferencesRepository.syncDate"

    private let userDefaults: UserDefaults

    init() {
        userDefaults = UserDefaults(suiteName: Bundle.main.bundleIdentifier) ?? UserDefaults.standard
    }

    func isOnBoardingCompleted() -> Bool {
        userDefaults.object(forKey: UserDefaultsPreferencesRepository.kOnboarding) as? Bool ?? false
    }

    func setOnboarding(completed: Bool) {
        userDefaults.set(completed, forKey: UserDefaultsPreferencesRepository.kOnboarding)
    }

    func isTracingActive() -> Bool {
        userDefaults.object(forKey: UserDefaultsPreferencesRepository.kTracing) as? Bool ?? true
    }

    func setTracing(active: Bool) {
        userDefaults.set(active, forKey: UserDefaultsPreferencesRepository.kTracing)
    }
    
    func getLastSync() -> Date? {
        userDefaults.object(forKey: UserDefaultsPreferencesRepository.kSyncDate) as? Date
    }

    func setLastSync(date: Date) {
        userDefaults.set(date, forKey: UserDefaultsPreferencesRepository.kSyncDate)
    }

    func isTracingInit() -> Bool {
        userDefaults.object(forKey: UserDefaultsPreferencesRepository.kTracingInit) as? Bool ?? false
    }

    func setTracing(initialized: Bool) {
        userDefaults.set(initialized, forKey: UserDefaultsPreferencesRepository.kTracingInit)
    }

}
