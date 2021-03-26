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

enum ExponentialDistribution {
    /// Get a random double using an exponential distribution
    /// - Parameter rate: The inverse of the upper limit
    /// - Returns: A random double between 0 and the limit
    static func sample(rate: Double = 1.0) -> Double {
        assert(rate > 0, "Cannot divide by 0")
        // We use -log(1-U) since U is [0, 1)
        return -log(1 - Double.random(in: 0 ..< 1)) / rate
    }
}

class FakeRequestRepository: UserDefaultsRepository {
    

    private let nextFakeRequestDate = "UserDefaultsFakeRequestUseCase.lastFake"
    var rate: Double
    let daySecs: Double = 24 * 60 * 60

    private var now: Date {
        Date()
    }
    
    private var _nextScheduledFakeRequestDate: Date {
        get {
            userDefaults.value(forKey: nextFakeRequestDate) as? Date
                ?? setNextScheduledFakeRequestDate()
        }
        set(newVal) {
            userDefaults.setValue(newVal, forKey: self.nextFakeRequestDate)
        }
    }
    
    override init() {
        rate = 1.0
        if Config.debug {
            rate = 2
        }
        super.init()
    }
    
    public func getNextScheduledFakeRequestDate() -> Date {
        return self._nextScheduledFakeRequestDate
    }
    
    private func setNextScheduledFakeRequestDate() -> Date {
        let nextFakeDate = Date(timeInterval: ExponentialDistribution.sample(rate: rate) * daySecs, since: now)
        self._nextScheduledFakeRequestDate = nextFakeDate
        print("setting new scheduled fake request date", nextFakeDate, "actualDate", Date())
        return nextFakeDate
    }
    
    public func updateScheduledFakeRequestDate() {
        let _ = self.setNextScheduledFakeRequestDate()
    }
    
}


