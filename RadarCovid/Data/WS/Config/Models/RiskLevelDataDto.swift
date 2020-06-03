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

public struct RiskLevelDataDto: Codable {

    public var riskLevelValue1: Int?
    public var riskLevelValue2: Int?
    public var riskLevelValue3: Int?
    public var riskLevelValue4: Int?
    public var riskLevelValue5: Int?
    public var riskLevelValue6: Int?
    public var riskLevelValue7: Int?
    public var riskLevelValue8: Int?
    public var riskLevelWeight: Double?

    public init(riskLevelValue1: Int?, riskLevelValue2: Int?, riskLevelValue3: Int?, riskLevelValue4: Int?, riskLevelValue5: Int?, riskLevelValue6: Int?, riskLevelValue7: Int?, riskLevelValue8: Int?, riskLevelWeight: Double?) {
        self.riskLevelValue1 = riskLevelValue1
        self.riskLevelValue2 = riskLevelValue2
        self.riskLevelValue3 = riskLevelValue3
        self.riskLevelValue4 = riskLevelValue4
        self.riskLevelValue5 = riskLevelValue5
        self.riskLevelValue6 = riskLevelValue6
        self.riskLevelValue7 = riskLevelValue7
        self.riskLevelValue8 = riskLevelValue8
        self.riskLevelWeight = riskLevelWeight
    }

}
