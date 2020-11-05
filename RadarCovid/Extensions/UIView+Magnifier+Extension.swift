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

extension UIView {

    private func getLabelsInView(view: UIView) -> [UILabel] {
        var results = [UILabel]()
        for subview in view.subviews as [UIView] {
            if let labelView = subview as? UILabel {
                results += [labelView]
            } else {
                results += getLabelsInView(view: subview)
            }
        }
        return results
    }
    
    private func getButtonsInView(view: UIView) -> [UIButton] {
        var results = [UIButton]()
        for subview in view.subviews as [UIView] {
            if let button = subview as? UIButton {
                results += [button]
            } else {
                results += getButtonsInView(view: subview)
            }
        }
        return results
    }

    private func setHeightForButton(button: UIButton) {
        guard let estimateHeight = button.titleLabel?.textHeight(withWidth: button.frame.size.width) else {
            return
        }
        if estimateHeight > button.frame.size.height {
            
            let heightCons = button.constraints.filter {
                $0.firstAttribute == NSLayoutConstraint.Attribute.height
            }
            heightCons.forEach({self.removeConstraint($0)})
            
            
            let heightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: estimateHeight + 20)
            NSLayoutConstraint.activate([heightConstraint])
        }
    }
    
    func setFontTextStyle(){
        let styles = [UIFont.TextStyle.caption2, UIFont.TextStyle.caption1, UIFont.TextStyle.subheadline, UIFont.TextStyle.callout, UIFont.TextStyle.body,  UIFont.TextStyle.headline, UIFont.TextStyle.title3, UIFont.TextStyle.title2, UIFont.TextStyle.title1, UIFont.TextStyle.largeTitle ]
        let sizes = [15.0, 16.0, 17.0, 18.0, 20.0, 22.0, 24.0, 26.0, 28.0, 32.0]
        for label in self.getLabelsInView(view: self) {
            let fontSize = label.font.pointSize
            if (sizes.contains(Double(fontSize)) && label.tag != 55){
                label.tag = 55
                let index = sizes.firstIndex(of: Double(fontSize))
                let fontStyle = styles[index ?? 0]
                let metrics = UIFontMetrics(forTextStyle: fontStyle)
                label.font = metrics.scaledFont(for: label.font)
                label.adjustsFontForContentSizeCategory = true
                
            }
        }
        
        for button in self.getButtonsInView(view: self) {
            
            guard let label = button.titleLabel else {
                return
            }
            let fontSize = label.font.pointSize
            if (sizes.contains(Double(fontSize)) && button.tag != 55 && button.titleLabel?.text != nil){
                button.tag = 55
                let index = sizes.firstIndex(of: Double(fontSize))
                let fontStyle = styles[index ?? 0]
                let metrics = UIFontMetrics(forTextStyle: fontStyle)
                button.titleLabel?.font = metrics.scaledFont(for: label.font)
                self.setHeightForButton(button: button)
                
            }
        }
    }
}

