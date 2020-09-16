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
    @IBOutlet weak var viewSubtitle: UILabel!
    @IBOutlet weak var paragraph1Title: UILabel!
    @IBOutlet weak var paragraph2Title: UILabel!
    @IBOutlet weak var paragraph3Title: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var checkBoxImage: UIImageView!

    @IBOutlet weak var paragraph_1_description: UILabel!
    @IBOutlet weak var acceptTermsLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!

    @IBOutlet weak var acceptView: UIView!
    @IBOutlet weak var switchAccept: UISwitch!
    
    @IBOutlet weak var acceptButton: UIButton!

    @IBAction func onOk(_ sender: Any) {
        router?.route(to: Routes.proximity, from: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAccessibility()
        acceptButton.setTitle("ONBOARDING_CONTINUE_BUTTON".localized, for: .normal)

        acceptButton.isEnabled = termsAccepted
        scrollView.alwaysBounceVertical = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        acceptTermsLabel.isUserInteractionEnabled = true
        privacyLabel.isUserInteractionEnabled = true
        acceptView.isUserInteractionEnabled = true
        
        acceptView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapAccept(tapGestureRecognizer:))))

        acceptTermsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapTerms(tapGestureRecognizer:))))

        privacyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapPrivacy(tapGestureRecognizer:))))

    }
    
    func setupAccessibility() {
        switchAccept.isOn = false
        if UIAccessibility.isVoiceOverRunning {
            paragraph_1_description.text = paragraph_1_description.text?.lowercased()
            acceptView.isHidden = true
            switchAccept.isHidden = false
        } else {
            switchAccept.isHidden = true
            acceptView.isHidden = false
        }
        viewTitle.isAccessibilityElement = true
        viewTitle.accessibilityLabel = "ACC_CONDITIONS_PRIVACY_TITLE".localized
        viewTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        
        viewSubtitle.isAccessibilityElement = true
        viewSubtitle.accessibilityLabel = "ACC_CONDITIONS_PRIVACY_SUBTITLE".localized
        viewSubtitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        
        paragraph1Title.isAccessibilityElement = true
        paragraph1Title.accessibilityLabel = "ACC_CONDITIONS_PRIVACY_PARAGRAPH1_TITLE".localized
        paragraph1Title.accessibilityTraits.insert(UIAccessibilityTraits.header)
        
        paragraph2Title.isAccessibilityElement = true
        paragraph2Title.accessibilityLabel = "ACC_CONDITIONS_PRIVACY_PARAGRAPH2_TITLE".localized
        paragraph2Title.accessibilityTraits.insert(UIAccessibilityTraits.header)
        
        paragraph3Title.isAccessibilityElement = true
        paragraph3Title.accessibilityLabel = "ACC_CONDITIONS_PRIVACY_PARAGRAPH3_TITLE".localized
        paragraph3Title.accessibilityTraits.insert(UIAccessibilityTraits.header)
        
        acceptTermsLabel.isAccessibilityElement = true
        acceptTermsLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        acceptTermsLabel.accessibilityHint = "ACC_HINT".localized
        
        privacyLabel.isAccessibilityElement = true
        privacyLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        privacyLabel.accessibilityHint = "ACC_HINT".localized
        
        switchAccept.accessibilityTraits = UISwitch().accessibilityTraits
        switchAccept.accessibilityLabel = "ACC_CHECKBOX_PRIVACY".localized

        acceptButton.isAccessibilityElement = true
    }

    @objc func userDidTapAccept(tapGestureRecognizer: UITapGestureRecognizer) {
        termsToggle()
    }
    
    @IBAction func onSwithAcceptChange(_ sender: Any) {
        termsToggle()
    }
    
    private func termsToggle() {
        if !termsAccepted {
            checkBoxImage.image = UIImage(named: "CheckboxSelected")
            checkBoxImage.accessibilityHint = "ACC_HINT_DISABLE".localized
            acceptButton.accessibilityHint = "ACC_HINT".localized
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
