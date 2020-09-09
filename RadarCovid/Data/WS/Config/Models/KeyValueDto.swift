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

public struct KeyValueDto: Codable {

    public var id: String?
    public var description: String?

    public init(id: String?, description: String?) {
        self.id = id
        self.description = description
    }

    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case description = "description"
    }

}
