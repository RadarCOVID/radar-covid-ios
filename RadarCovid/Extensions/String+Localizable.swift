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

extension String: Localizable {

    var localized: String {
        return LocalizationHolder.localizationMap?[self] ?? NSLocalizedString(self, comment: "")
    }

    var isHrefText: Bool {
        localized.contains("href=")
    }
    
    var isAttributedText: Bool {
        localized.contains("</") || localized.contains("<br")
    }

    var localizedAttributed: NSAttributedString {
        return localizedAttributed()
    }

    func localizedAttributed(
        withParams params: [String],
        attributes: [NSAttributedString.Key: Any] = [:]
    ) -> NSAttributedString {
        var string = self.localized
        if string.contains("%@") {
            string = String(format: string, arguments: params)
        }
        return string.localizedAttributed

    }

    func localizedAttributed(attributes: [NSAttributedString.Key: Any] = [:]) -> NSAttributedString {

        let string = LocalizationHolder.localizationMap?[self] ?? NSLocalizedString(self, comment: "")

        let attributed = string.htmlToAttributedString?.formatHtmlString(
            withBaseFont: attributes[NSAttributedString.Key.font] as? UIFont,
            perserveFont: false) ?? NSMutableAttributedString(string: string
        )
        if let color = attributes[NSAttributedString.Key.foregroundColor] {
            attributed.addAttribute(
                NSAttributedString.Key.foregroundColor,
                value: color,
                range: NSRange(location: 0, length: attributed.length)
            )
        }

        return attributed

    }

}
