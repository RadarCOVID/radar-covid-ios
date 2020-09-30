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

extension UILabel: XibLocalizable {

    @IBInspectable var locKey: String? {
        get { return nil }
        set(key) {
            
            if key?.isAttributedText ?? false {
                var strValue: String = key ?? ""
                if strValue.isHrefText {
                    //Hyperlink to Link
                    strValue = strValue.localized.replacingOccurrences(of: "<a", with: "<link ")
                    strValue = strValue.localized.replacingOccurrences(of: "</a>", with: "</link>")
                }
                
                attributedText = strValue.localizedAttributed(
                    attributes: attributedText?.attributes(at: 0, effectiveRange: nil) ?? [:])
            } else {
                let finalText = key?.localized
                text = finalText
            }
        }
    }

}
