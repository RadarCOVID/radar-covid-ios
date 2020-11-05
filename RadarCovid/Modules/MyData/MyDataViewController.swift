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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var acceptTermsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var bullet2Label: UILabel!
    @IBOutlet weak var bullet3Label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setFontTextStyle()
        
        setupView()
        setupAccessibility()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIAccessibility.post(notification: .layoutChanged, argument: self.titleLabel)
            }
        }
    }
    
    @objc func userDidTapTerms(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "MY_DATA_TERMS".localized.getUrlFromHref())
    }

    @objc func userDidTapPrivacy(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "MY_DATA_PRIVACY".localized.getUrlFromHref())
    }
    
    private func setupAccessibility() {
        
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        titleLabel.accessibilityLabel = "ACC_MYDATA_TITLE".localized
        
        acceptTermsLabel.isAccessibilityElement = true
        acceptTermsLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        acceptTermsLabel.accessibilityLabel = "MY_DATA_TERMS".localizedAttributed().string
        acceptTermsLabel.accessibilityHint = "ACC_HINT".localized
        
        privacyLabel.isAccessibilityElement = true
        privacyLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        privacyLabel.accessibilityLabel = "MY_DATA_PRIVACY".localizedAttributed().string
        privacyLabel.accessibilityHint = "ACC_HINT".localized
        
        if UIAccessibility.isVoiceOverRunning {
            descriptionLabel.text = descriptionLabel.text?.lowercased()
            bullet2Label.text = bullet2Label.text?.lowercased()
            bullet3Label.text = bullet3Label.text?.lowercased()
        }
    }
    
    private func setupView() {
        acceptTermsLabel.isUserInteractionEnabled = true
        privacyLabel.isUserInteractionEnabled = true

        acceptTermsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                              action: #selector(userDidTapTerms(tapGestureRecognizer:))))

        privacyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                          action: #selector(userDidTapPrivacy(tapGestureRecognizer:))))
    }
}
