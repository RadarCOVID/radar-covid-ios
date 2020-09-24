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

class MyDataViewController: UIViewController {

    //MARK: - Outlet.
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var acceptTermsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var bullet2Label: UILabel!
    @IBOutlet weak var bullet3Label: UILabel!
    
    //MARK: - View Life Cycle Methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAccessibility()
    }

    //MARK: - Action methods.

    @objc func userDidTapTerms(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "USE_CONDITIONS_URL".localized)
    }

    @objc func userDidTapPrivacy(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "PRIVACY_POLICY_URL".localized)
    }
}

//MARK: - Accesibility.
extension MyDataViewController {
    
    func setupAccessibility() {
        
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        titleLabel.accessibilityLabel = "ACC_MYDATA_TITLE".localized
        
        if UIAccessibility.isVoiceOverRunning {
            descriptionLabel.text = descriptionLabel.text?.lowercased()
            bullet2Label.text = bullet2Label.text?.lowercased()
            bullet3Label.text = bullet3Label.text?.lowercased()
        }
    }
}

//MARK: - Private.
private extension MyDataViewController {
    
    func setupView() {
        acceptTermsLabel.isUserInteractionEnabled = true
        privacyLabel.isUserInteractionEnabled = true

        acceptTermsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                              action: #selector(userDidTapTerms(tapGestureRecognizer:))))

        privacyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                          action: #selector(userDidTapPrivacy(tapGestureRecognizer:))))
    }
}
