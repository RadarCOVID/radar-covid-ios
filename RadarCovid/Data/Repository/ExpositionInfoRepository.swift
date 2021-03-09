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
    func getExpositionInfo() -> ContactExpositionInfo?
    func save(expositionInfo: ContactExpositionInfo)
    func isChangedToHealthy() -> Bool?
    func setChangedToHealthy(changed: Bool)
    func clearData()
}

class UserDefaultsExpositionInfoRepository: UserDefaultsRepository, ExpositionInfoRepository {

    private static let kData = "UserDefaultsExpositionInfoRepository.expositionInfo"
    private static let kChanged = "UserDefaultsExpositionInfoRepository.changedToHealthy"

    func getExpositionInfo() -> ContactExpositionInfo? {
        if let uncoded = userDefaults.data(forKey: UserDefaultsExpositionInfoRepository.kData), !uncoded.isEmpty {
            return try? decoder.decode(ContactExpositionInfo.self, from: uncoded)
        }
        return nil
    }

    func save(expositionInfo: ContactExpositionInfo) {
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
    }

}
