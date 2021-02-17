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


/** Token to be evaluated */

public struct AppleKpiTokenDto: Codable {

    public var kpiToken: String
    public var deviceToken: String

    public init(kpiToken: String, deviceToken: String) {
        self.kpiToken = kpiToken
        self.deviceToken = deviceToken
    }


}

