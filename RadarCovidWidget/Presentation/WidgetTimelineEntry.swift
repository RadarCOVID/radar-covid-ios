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
import WidgetKit
import SwiftUI

struct WidgetTimelineEntry: TimelineEntry {
    let exposition: ExpositionInfo
    let date: Date
    var error: Error? {
        return exposition.error
    }

    var text: String {
        switch exposition.level {
        case .exposed: return "Expuesto"
        case .healthy: return "Sin exposición"
        case .infected: return "Infectado"
        case .unknown: return "Desconocido"
        }
    }

    var textColor: Color {
        switch exposition.level {
        case .exposed: return Color("darkText")
        case .healthy: return Color("lightText")
        case .infected: return Color("darkText")
        case .unknown: return Color("darkText")
        }
    }

    var color: Color {
        switch exposition.level {
        case .exposed: return Color(#colorLiteral(red: 0.9254901961, green: 0.8, blue: 0.4078431373, alpha: 1))
        case .healthy: return Color(#colorLiteral(red: 0.3449999988, green: 0.6899999976, blue: 0.4160000086, alpha: 1))
        case .infected: return Color(#colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1))
        case .unknown: return Color(#colorLiteral(red: 0.6431372549, green: 0.6901960784, blue: 0.7450980392, alpha: 1))
        }
    }
}
