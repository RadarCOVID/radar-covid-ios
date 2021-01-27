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



public struct KpiDto: Codable {

    public var kpi: String?
    /** KPI date */
    public var timestamp: Date?
    public var value: Int?

    public init(kpi: String?, timestamp: Date?, value: Int?) {
        self.kpi = kpi
        self.timestamp = timestamp
        self.value = value
    }


}

