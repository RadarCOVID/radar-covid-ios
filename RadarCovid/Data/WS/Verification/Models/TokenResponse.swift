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

public struct TokenResponse: Codable {

    /** Token JWT to be used by application once verification code has been validated */
    public var token: String

    public init(token: String) {
        self.token = token
    }

}
