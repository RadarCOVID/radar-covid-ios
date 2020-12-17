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
    @IBOutlet weak var titleLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setFontTextStyle()
        
        setAccesibilityBackButton()
        setAccesibilityDefault()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIAccessibility.post(notification: .layoutChanged, argument: self.titleLabel)
            }
        }
    }
    
    func setAccesibilityBackButton() {
        if let backButton = backButton {
            backButton.isAccessibilityElement = true
            let previous = navigationController?.previousViewController
            if let strTitle = (previous as? AccTitleView)?.accTitle ?? previous?.title {
                backButton.accessibilityLabel =  "\(strTitle) " + "ACC_BUTTON_BACK_TO".localized
            } else {
                backButton.accessibilityLabel = "ACC_BUTTON_BACK".localized
            }
            backButton.accessibilityHint = "ACC_HINT".localized
        }
    }
    
    private func setAccesibilityDefault() {
        titleLabel?.isAccessibilityElement = true
        titleLabel?.accessibilityTraits.insert(UIAccessibilityTraits.header)
    }
}
