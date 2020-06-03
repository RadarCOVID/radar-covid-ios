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

/** The Code to be verified */

public struct Code: Codable {

    /** Date the patient indicates that he/she is infected */
    public var date: Date?
    /** 12 digits code */
    public var code: String

    public init(date: Date?, code: String) {
        self.date = date
        self.code = code
    }

}
