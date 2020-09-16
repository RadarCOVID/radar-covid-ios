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

/** Time between states */

public struct TimeBetweenStatesDto: Codable {

    /** Time, in minutes, to change from high risk to low risk states */
    public var highRiskToLowRisk: Int64?
    /** time, in minutes, to change from infected to healthy states */
    public var infectedToHealthy: Int64?

    public init(highRiskToLowRisk: Int64?, infectedToHealthy: Int64?) {
        self.highRiskToLowRisk = highRiskToLowRisk
        self.infectedToHealthy = infectedToHealthy
    }

}
