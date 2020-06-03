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

/** iOS version information */

public struct VersionDto: Codable {

    /** Version identifier */
    public var version: String?
    /** Compilation identifier */
    public var compilation: Int?
    /** URL */
    public var bundleUrl: String?

    public init(version: String?, compilation: Int?, bundleUrl: String?) {
        self.version = version
        self.compilation = compilation
        self.bundleUrl = bundleUrl
    }

}
