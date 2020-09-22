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

enum Endpoints {
    case pre
    case pro
    var config: String {
        switch self {
        case .pre: return "https://radarcovidpre.covid19.gob.es/configuration"
        case .pro: return "https://radarcovid.covid19.gob.es/configuration"
        }
    }
    var kpi: String {
        switch self {
        case .pre: return "https://radarcovidpre.covid19.gob.es/kpi"
        case .pro: return "https://radarcovid.covid19.gob.es/kpi"
        }
    }
    var dpppt: String {
        switch self {
        case .pre: return "https://radarcovidpre.covid19.gob.es/dp3t"
        case .pro: return "https://radarcovid.covid19.gob.es/dp3t"
        }
    }
    var verification: String {
        switch self {
        case .pre: return "https://radarcovidpre.covid19.gob.es/verification"
        case .pro: return "https://radarcovid.covid19.gob.es/verification"
        }
    }
}
