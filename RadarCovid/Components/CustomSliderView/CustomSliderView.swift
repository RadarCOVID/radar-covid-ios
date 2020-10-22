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

class CustomSliderView: UIView, XibInstantiatable {

    @IBOutlet weak var slider: CustomSlider!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        instantiate()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instantiate()
    }
    
    func configure(indexStep: Int, totalStep: Int, accesibilityHelper: String? = nil) {

        stepLabel.text = "MY_HEALTH_RANGER".localized
        stepLabel.text = stepLabel.text?.replacingOccurrences(of: "$1", with: "\(indexStep)")
        stepLabel.text = stepLabel.text?.replacingOccurrences(of: "$2", with: "\(totalStep)")

        if let strAccesibility = accesibilityHelper {
            viewContainer.accessibilityLabel = strAccesibility
        }
        
        //Config slider
        slider.maximumValue = 1
        slider.maximumValue = Float(totalStep)
        slider.value = Float(indexStep)
    }
}
