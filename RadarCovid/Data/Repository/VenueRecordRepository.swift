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


protocol VenueRecordRepository {
    func getCurrentVenue() -> VenueRecord?
    func removeCurrent()
}

class UserDefaultsVenueRecordRepository : UserDefaultsRepository, VenueRecordRepository {
    
    private static let kCurrentVenue = "UserDefaultsVenueRecordRepository.currentVenue"
    
    func getCurrentVenue() -> VenueRecord? {
        if let uncoded = userDefaults.data(forKey: UserDefaultsVenueRecordRepository.kCurrentVenue), !uncoded.isEmpty {
            return try? decoder.decode(VenueRecord.self, from: uncoded)
        }
        return nil
    }
    
    func removeCurrent() {
        userDefaults.removeObject(forKey: UserDefaultsVenueRecordRepository.kCurrentVenue)
    }
    
    
}
