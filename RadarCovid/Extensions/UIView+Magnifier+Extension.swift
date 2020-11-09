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
    
    private func setFontSizeThatFitSize(size: Double, font: UIFont) -> UIFont{
        let styles = [UIFont.TextStyle.caption2, UIFont.TextStyle.caption1, UIFont.TextStyle.subheadline, UIFont.TextStyle.callout, UIFont.TextStyle.body,  UIFont.TextStyle.headline, UIFont.TextStyle.title3, UIFont.TextStyle.title2, UIFont.TextStyle.title1, UIFont.TextStyle.largeTitle ]
        let sizes = [15.0, 16.0, 17.0, 18.0, 20.0, 22.0, 24.0, 26.0, 28.0, 32.0]
        
        if (sizes.contains(size)) {
            let index = sizes.firstIndex(of: size)
            let fontStyle = styles[index ?? 0]
            
            return UIFontMetrics(forTextStyle: fontStyle).scaledFont(for: font)
        }
        
        return font
    }
    
    private func setLabelFontSize(label: UILabel) {
        if label.tag != 55 && ((label.text?.isEmpty) != nil) {
            label.tag = 55
            
            let fontSize = Double(label.font.pointSize)
            label.font = self.setFontSizeThatFitSize(size: fontSize, font: label.font)
            label.adjustsFontForContentSizeCategory = true
        }
    }
    
    private func setButtonFontSize(button: UIButton) {
        if let label = button.titleLabel,
           button.tag != 55 && ((label.text?.isEmpty) != nil) {

            button.tag = 55
            
            if label.font != nil {
                let fontSize = Double(label.font.pointSize)
                label.font = self.setFontSizeThatFitSize(size: fontSize, font: label.font)
            }

            self.setHeightForButton(button: button)
        }
    }
    
    func setFontTextStyle(){
        for label in self.getLabelsInView(view: self) {
            self.setLabelFontSize(label: label)
        }
        
        for button in self.getButtonsInView(view: self) {
            self.setButtonFontSize(button: button)
        }
    }
}

