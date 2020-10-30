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

class BaseViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setAccesibilityBackButton()
    }
    
    private func setAccesibilityBackButton() {
        
        //Set Accesibility logic
        backButton?.isAccessibilityElement = true
        let previous = navigationController?.previousViewController
        if let strTitle = (previous as? AccTitleView)?.accTitle ?? previous?.title {
            backButton?.accessibilityLabel =  "\(strTitle)," + "ACC_BUTTON_BACK_TO".localized 
        } else {
            backButton?.accessibilityLabel = "ACC_BUTTON_BACK".localized
        }
        backButton?.accessibilityHint = "ACC_HINT".localized
    }
}
