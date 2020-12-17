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

extension UILabel {
    
    func setLineSpacing(lineSpacing: CGFloat = 2.0, lineHeightMultiple: CGFloat = 1.26) {
        
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        
        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
    
    func setMagnifierFontSize() {
        if self.tag != 22 {
            self.tag = 22
            let bodyFontSize:CGFloat = 20
            let bodyResizedSize = UIFontMetrics(forTextStyle: .body).scaledFont(for: self.font).pointSize
            let resultingSize = bodyResizedSize  / bodyFontSize * self.font.pointSize
            
            if bodyResizedSize != 16 {
                if self.attributedText != nil {
                    let mutableAttributed = self.attributedText!.mutableCopy() as! NSMutableAttributedString
                    mutableAttributed.beginEditing()
                    mutableAttributed.enumerateAttribute(.font, in: NSRange(location: 0, length: mutableAttributed.length)){ (value, range, stop) in
                        if let oldFont = value as? UIFont {
                            let newFont = oldFont.withSize(resultingSize)
                            mutableAttributed.addAttribute(.font, value: newFont, range: range)
                        }
                    }
                    mutableAttributed.endEditing()
                    self.attributedText = mutableAttributed
                }else {
                    self.font = self.font.withSize(resultingSize)
                }
            }
           
        }
       
    }
}
