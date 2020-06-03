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

/** Attenuation factor */

public struct AttenuationFactorDto: Codable {

    public var low: Double?
    public var medium: Double?

    public init(low: Double?, medium: Double?) {
        self.low = low
        self.medium = medium
    }

}
