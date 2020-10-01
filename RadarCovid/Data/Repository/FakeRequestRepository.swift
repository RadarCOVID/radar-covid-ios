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
class FakeRequestRepository {
    
    private var userDefaults: UserDefaults
    private let lastFake = "UserDefaultsFakeRequestUseCase.lastFake"
    
    private var dateThreeHoursAgo:Date {
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.hour = 3
        return Calendar.current.date(
            byAdding: dateComponent,
            to: currentDate)
            ?? Date()
    }

    private var _fakeRequestDate: Date?
    var fakeRequestDate: Date {
        get {
            self._fakeRequestDate ??
                userDefaults.value(forKey: lastFake) as? Date
                ?? self.dateThreeHoursAgo
        }
        set(newDate) {
            self._fakeRequestDate = newDate
            userDefaults.set(newDate, forKey: lastFake)
            userDefaults.synchronize()
        }
    }
    
    init() {
        self.userDefaults = UserDefaults.standard
    }
   
}
