//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import UIKit

class CustomSlider: UISlider {
  
    //To set line height value from IB, here ten is default value
    @IBInspectable var trackLineHeight: CGFloat = 18

    //To set custom size of track so here override trackRect function of slider control
    override func trackRect(forBounds bound: CGRect) -> CGRect {
        //Here, set track frame
        return CGRect(origin: bound.origin, size: CGSize(width: bound.width, height: trackLineHeight))
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        if self.value == self.maximumValue {
            self.value = (self.value - 1)
            context.setFillColor(UIColor.twilight.cgColor)
            let path = UIBezierPath(roundedRect: CGRect(origin: rect.origin, size: CGSize(width: rect.width, height: trackLineHeight)), cornerRadius: rect.size.height / 2).cgPath
            context.addPath(path)
            context.fillPath()
        }
    }
}
