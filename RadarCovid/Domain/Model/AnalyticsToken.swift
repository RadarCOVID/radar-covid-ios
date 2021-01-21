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

struct AnalyticsToken {
    
    public static let tokenLength: Int = 128
    private static let secondsInDay: Int = 24*60*60
    private static let numDays = 31
    
    var token: String
    var expirationDate: Date
    
    func isExpired() -> Bool {
        expirationDate < Date()
    }
    
    static func generateNew() -> AnalyticsToken {
        return AnalyticsToken(token: String.random(length: tokenLength),
                              expirationDate: newExpirationDate())
    }
    
    private static func newExpirationDate() -> Date {
        let nexmonth = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        let maxShift = numDays * secondsInDay
        let shift = Int.random(in: 0...maxShift)
        return nexmonth.addingTimeInterval(TimeInterval(shift))
    }
}
