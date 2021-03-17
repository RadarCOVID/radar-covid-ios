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

struct VenueRecord: Codable {
    var qr: String
    var checkOutId: String?
    var hidden: Bool = false
    var exposed: Bool = false
    var notified: Bool = false
    var name: String?
    var checkInDate: Date
    var checkOutDate: Date?
}
