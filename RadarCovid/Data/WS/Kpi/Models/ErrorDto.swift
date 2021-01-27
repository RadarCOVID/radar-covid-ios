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



public struct ErrorDto: Codable {

    public var timestamp: Int64?
    public var status: Int?
    public var message: String?
    public var path: String?

    public init(timestamp: Int64?, status: Int?, message: String?, path: String?) {
        self.timestamp = timestamp
        self.status = status
        self.message = message
        self.path = path
    }


}

