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

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension String {
    var htmlToAttributedString: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return NSMutableAttributedString() }
        do {
            return try NSMutableAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
        } catch {
            return NSMutableAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    var getStringFromFile : String {
        if let fileURL = Bundle.main.url(forResource: self, withExtension: "") {
            do {
                let text = try String(contentsOf: fileURL, encoding: .utf8).replacingOccurrences(of: "\n", with: "")
                return text
            }
            catch {
                return ""
            }
        }
      
        return ""
    }

}

extension NSMutableAttributedString {

    /// Replaces the base font (typically Times) with the given font, while preserving traits like bold and italic
    func setBaseFont(baseFont: UIFont, preserveFontSizes: Bool = false) -> NSMutableAttributedString {
        let baseDescriptor = baseFont.fontDescriptor
        let wholeRange = NSRange(location: 0, length: length)
        beginEditing()
        enumerateAttribute(.font, in: wholeRange, options: []) { object, range, _ in
            guard let font = object as? UIFont else { return }
            // Instantiate a font with our base font's family, but with the current range's traits
            let traits = font.fontDescriptor.symbolicTraits
            guard let descriptor = baseDescriptor.withSymbolicTraits(traits) else { return }
            let newSize = preserveFontSizes ? descriptor.pointSize : baseDescriptor.pointSize
            let newFont = UIFont(descriptor: descriptor, size: newSize)
            self.removeAttribute(.font, range: range)
            self.addAttribute(.font, value: newFont, range: range)
        }
        endEditing()
        return self
    }

}

extension NSAttributedString {

    func formatHtmlString(withBaseFont font: UIFont?, perserveFont: Bool = false) -> NSMutableAttributedString {
            let attributedString = self
            let fontFamily =  font ?? UIFont.systemFont(ofSize: 16)
            return NSMutableAttributedString(
                attributedString: attributedString
            ).setBaseFont(baseFont: fontFamily, preserveFontSizes: perserveFont)
    }

}
