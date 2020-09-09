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

struct ExpositionInfo: Codable, Equatable {

    var level: Level
    var lastCheck: Date?
    var since: Date?
    var error: DomainError?

    public init(level: Level) {
        self.level = level
    }

    enum Level: String, Codable {
         case healthy
         case exposed
         case infected
    }

}
