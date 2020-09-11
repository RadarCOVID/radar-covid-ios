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

class OnBoardingViewController: UIViewController {

    var router: AppRouter?

    private var termsAccepted: Bool = false
    @IBOutlet weak var viewTitle: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var checkBoxImage: UIImageView!

    @IBOutlet weak var paragraph_1_description: UILabel!
    @IBOutlet weak var acceptTermsLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!

    @IBOutlet weak var acceptView: UIView!
    @IBOutlet weak var switchAccept: UISwitch!
    
    @IBOutlet weak var acceptButton: UIButton!

    @IBAction func onSwithAcceptChange(_ sender: Any) {
        let active = switchAccept.isOn
        if active {
            checkBoxImage.image = UIImage(named: "CheckboxSelected")
            checkBoxImage.accessibilityHint = "ACC_HINT_DISABLE".localized
            termsAccepted = true
        } else {
            checkBoxImage.image = UIImage(named: "CheckboxUnselected")
            checkBoxImage.accessibilityHint = "ACC_HINT".localized
            termsAccepted = false
        }
        acceptButton.isEnabled = termsAccepted
    }
    @IBAction func onOk(_ sender: Any) {
        router?.route(to: Routes.proximity, from: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        acceptButton.setTitle("ONBOARDING_CONTINUE_BUTTON".localized, for: .normal)

        acceptButton.isEnabled = termsAccepted
        scrollView.alwaysBounceVertical = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        switchAccept.isOn = false
        // test to lower case if voiceover is active
        if UIAccessibility.isVoiceOverRunning {
            paragraph_1_description.text = paragraph_1_description.text?.lowercased()
            checkBoxImage.isHidden = true
            switchAccept.isHidden = false
        }else{
            switchAccept.isHidden = true
            checkBoxImage.isHidden = false
        }

        viewTitle.isAccessibilityElement = true
        viewTitle.accessibilityLabel = "ACC_CONDITIONS_PRIVACY_TITLE".localized
        viewTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        //Adding tapgesture to the Accept terms checkboxImage and label
        acceptTermsLabel.isUserInteractionEnabled = true
        privacyLabel.isUserInteractionEnabled = true
        acceptView.isUserInteractionEnabled = true
        acceptTermsLabel.isAccessibilityElement = true;
        acceptTermsLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        acceptTermsLabel.accessibilityHint = "ACC_HINT".localized
        privacyLabel.isAccessibilityElement = true;
        privacyLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        privacyLabel.accessibilityHint = "ACC_HINT".localized
        checkBoxImage.isAccessibilityElement = true
        checkBoxImage.accessibilityTraits.insert(UIAccessibilityTraits.allowsDirectInteraction)
        checkBoxImage.accessibilityTraits.insert(UIAccessibilityTraits.button)
        checkBoxImage.accessibilityLabel = "ACC_CHECKBOX_PRIVACY".localized
        checkBoxImage.accessibilityHint = "ACC_HINT".localized
        switchAccept.isAccessibilityElement = true
        switchAccept.accessibilityTraits.insert(UIAccessibilityTraits.button)
        switchAccept.accessibilityLabel = "ACC_CHECKBOX_PRIVACY".localized
        switchAccept.accessibilityHint = "ACC_HINT".localized
        acceptButton.isAccessibilityElement = true
        acceptButton.accessibilityTraits.insert(UIAccessibilityTraits.button)
        acceptButton.accessibilityHint = "ACC_HINT".localized

        acceptView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapAccept(tapGestureRecognizer:))))

        acceptTermsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapTerms(tapGestureRecognizer:))))

        privacyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapPrivacy(tapGestureRecognizer:))))

    }

    @objc func userDidTapAccept(tapGestureRecognizer: UITapGestureRecognizer) {
        if !termsAccepted {
            checkBoxImage.image = UIImage(named: "CheckboxSelected")
            checkBoxImage.accessibilityHint = "ACC_HINT_DISABLE".localized
            termsAccepted = true
        } else {
            checkBoxImage.image = UIImage(named: "CheckboxUnselected")
            checkBoxImage.accessibilityHint = "ACC_HINT".localized
            termsAccepted = false
        }
        acceptButton.isEnabled = termsAccepted
    }

    @objc func userDidTapTerms(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "USE_CONDITIONS_URL".localized)
    }

    @objc func userDidTapPrivacy(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "PRIVACY_POLICY_URL".localized)
    }

}
