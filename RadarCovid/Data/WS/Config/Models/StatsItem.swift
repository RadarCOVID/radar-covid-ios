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



public struct StatsItem: Codable {

    public var date: String
    public var applicationsDownloads: Totals
    public var communicatedContagions: Totals

    public init(date: String, applicationsDownloads: Totals, communicatedContagions: Totals) {
        self.date = date
        self.applicationsDownloads = applicationsDownloads
        self.communicatedContagions = communicatedContagions
    }


}

