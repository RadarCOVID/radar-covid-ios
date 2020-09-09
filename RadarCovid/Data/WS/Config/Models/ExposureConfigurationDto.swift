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

/** Exposure configuration */

public struct ExposureConfigurationDto: Codable {

    public var transmission: RiskLevelDataDto?
    public var duration: RiskLevelDataDto?
    public var days: RiskLevelDataDto?
    public var attenuation: RiskLevelDataDto?

    public init(transmission: RiskLevelDataDto?, duration: RiskLevelDataDto?, days: RiskLevelDataDto?, attenuation: RiskLevelDataDto?) {
        self.transmission = transmission
        self.duration = duration
        self.days = days
        self.attenuation = attenuation
    }

}
