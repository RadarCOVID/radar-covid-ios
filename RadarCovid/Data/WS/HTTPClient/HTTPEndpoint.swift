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

struct HTTPEndpoint: Equatable {
    public private(set) var address: String
    public private(set) var method: HTTPMethod
}

public func == (lhs: HTTPEndpoint, rhs: HTTPEndpoint) -> Bool {
    return lhs.address == rhs.address && lhs.method == rhs.method
}
