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
import UIKit

extension UIFont {
    func defaultFont(
        withSize size: CGFloat,
        _ light: Bool = false,
        _ cursive: Bool = false,
        _ bold: Bool = false
    ) -> UIFont {
        var fontName = "Muli-Regular"
        if light {
            fontName = "Muli-Light"
        } else if cursive {
            fontName = "Muli-Italic"
        } else if bold {
            fontName = "Muli-Bold"
        }

        return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
