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

protocol QrCheckRepository {
    func getLastReminder() -> Date?
    func save(lastReminder: Date)
    func getSyncTag() -> String?
    func save(syncTag: String?)
}

class UserDefaultsQrCheckRepository: UserDefaultsRepository, QrCheckRepository {
    
    private static let kLastReminder = "UserDefaultsQrCheckRepository.kLastReminder"
    private static let kSyncTag = "UserDefaultsQrCheckRepository.kSyncTag"
    
    func getLastReminder() -> Date? {
        let uncoded = userDefaults.data(forKey: UserDefaultsQrCheckRepository.kLastReminder) ?? Data()
        if uncoded.isEmpty {
            return nil
        }
        return try? decoder.decode(Date.self, from: uncoded)
    }
    
    func save(lastReminder: Date) {
        guard let encoded = try? encoder.encode(lastReminder) else { return }
        userDefaults.set(encoded, forKey: UserDefaultsQrCheckRepository.kLastReminder)
    }
    
    func getSyncTag() -> String? {
        userDefaults.string(forKey: UserDefaultsQrCheckRepository.kSyncTag)
    }
    
    func save(syncTag: String?) {
        userDefaults.set(syncTag, forKey: UserDefaultsQrCheckRepository.kSyncTag)
    }
    

}
