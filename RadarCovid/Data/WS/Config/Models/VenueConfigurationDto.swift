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


/** Venue configuration */

public struct VenueConfigurationDto: Codable {

    public var recordNotification: Int64?
    public var autoCheckout: Int64?
    public var troubledPlaceCheck: Int64?
    public var quarentineAfterExposed: Int64?

    public init(recordNotification: Int64? = nil, autoCheckout: Int64? = nil, troubledPlaceCheck: Int64? = nil, quarentineAfterExposed: Int64? = nil) {
        self.recordNotification = recordNotification
        self.autoCheckout = autoCheckout
        self.troubledPlaceCheck = troubledPlaceCheck
        self.quarentineAfterExposed = quarentineAfterExposed
    }


}
