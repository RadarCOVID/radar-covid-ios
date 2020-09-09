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

public struct MessageResponse: Codable {

    public var code: Int?
    public var message: String?

    public init(code: Int?, message: String?) {
        self.code = code
        self.message = message
    }

}
