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
    public var timestamp: String?
    public var value: Int?

    public init(kpi: String?, timestamp: Date?, value: Int?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        self.kpi = kpi
        if let timestamp = timestamp {
            self.timestamp = dateFormatter.string(from: timestamp)
        }
        self.value = value
    }


}

