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

enum FontType {
    case regular
    case bold
    case italic
}

enum FontSize: CGFloat {
    case five = 5.0
    case eight = 8.0
    case nine = 9.0
    case ten = 10.0
    case eleven = 11.0
    case twelve = 12.0
    case thirteen = 13.0
    case fourteen = 14.0
    case fifteen = 15.0
    case sixteen = 16.0
    case seventeen = 17.0
    case eighteen = 18.0
    case twenty = 20.0
    case twentytwo = 22.0
    case twentyfour = 24.0
    case twentysix = 26.0
    case twentyeight = 28.0
    case thirtysix = 36.0
}

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
    
    class func mainFont(size: FontSize, fontType: FontType) -> UIFont {
        let fontSizeScale: CGFloat = 1.0

        let fontSizeScaled = size.rawValue * fontSizeScale

        switch fontType {
        case .regular:
            return UIFont.init(name: "HelveticaNeue", size: fontSizeScaled)! //.systemFont(ofSize: fontSizeScaled)
        case .bold:
            return UIFont.init(name: "HelveticaNeue-Bold", size: fontSizeScaled)!
        case .italic:
            return UIFont.init(name: "HelveticaNeue-Italic", size: fontSizeScaled)!
        }
    }
}
