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

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var paragraph1TitleLabel: UILabel!
    @IBOutlet weak var paragraph1DescriptionLabel: UILabel!
    @IBOutlet weak var paragraph2TitleLabel: UILabel!
    @IBOutlet weak var paragraph3TitleLabel: UILabel!
    @IBOutlet weak var acceptTermsLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!

    @IBOutlet weak var acceptView: UIView!
    @IBOutlet weak var checkBoxImage: UIImageView!
    @IBOutlet weak var acceptSwitch: UISwitch!
    
    @IBOutlet weak var acceptTermsAndUseView: UIView!
    @IBOutlet weak var acceptTermsAndUseSwitch: UISwitch!
    @IBOutlet weak var checkBoxAcceptTermsAndUseImage: UIImageView!
    
    @IBOutlet weak var acceptButton: UIButton!
    
    var router: AppRouter?
    
    private var privacyAccepted: Bool = false
    private var termsAndUseAccepted: Bool = false
    var termsRepository: TermsAcceptedRepository!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupAccessibility()
    }
    
    @IBAction func onSwithAcceptChange(_ sender: Any) {
        privacyToggle()
    }
    
    @IBAction func onSwithAcceptTermsAndUseChange(_ sender: Any) {
        termsAndUseToggle()
    }

    @IBAction func onOk(_ sender: Any) {
        termsRepository.termsAccepted = true
        router?.route(to: Routes.proximity, from: self)
    }
    
    @objc func userDidTapAccept(tapGestureRecognizer: UITapGestureRecognizer) {
        privacyToggle()
    }
    
    @objc func userDidTapAcceptTermsAndUse(tapGestureRecognizer: UITapGestureRecognizer) {
        termsAndUseToggle()
    }
    
    @objc func userDidTapTerms(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "ONBOARDING_STEP_2_USAGE_CONDITIONS".localized.getUrlFromHref())
    }

    @objc func userDidTapPrivacy(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "ONBOARDING_STEP_2_PRIVACY_POLICY".localized.getUrlFromHref())
    }
    
    private func setupAccessibility() {

        acceptSwitch.tintColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
        acceptSwitch.layer.cornerRadius = acceptSwitch.frame.height / 2
        acceptSwitch.backgroundColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
        acceptSwitch.isAccessibilityElement = false
        
        acceptTermsAndUseSwitch.tintColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
        acceptTermsAndUseSwitch.layer.cornerRadius = acceptTermsAndUseSwitch.frame.height / 2
        acceptTermsAndUseSwitch.backgroundColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
        acceptTermsAndUseSwitch.isAccessibilityElement = false
        
        if UIAccessibility.isVoiceOverRunning {
            paragraph1DescriptionLabel.text = paragraph1DescriptionLabel.text?.lowercased()
            acceptSwitch.isHidden = false
            acceptTermsAndUseSwitch.isHidden = false
        } else {
            acceptSwitch.isHidden = true
            acceptTermsAndUseSwitch.isHidden = true
        }
        
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityLabel = "ACC_CONDITIONS_PRIVACY_TITLE".localized
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)

        subtitleLabel.isAccessibilityElement = true
        subtitleLabel.accessibilityLabel = "ACC_CONDITIONS_PRIVACY_SUBTITLE".localized
        subtitleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)

        paragraph1TitleLabel.isAccessibilityElement = true
        paragraph1TitleLabel.accessibilityLabel = "ACC_CONDITIONS_PRIVACY_PARAGRAPH1_TITLE".localized
        paragraph1TitleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)

        paragraph2TitleLabel.isAccessibilityElement = true
        paragraph2TitleLabel.accessibilityLabel = "ACC_CONDITIONS_PRIVACY_PARAGRAPH2_TITLE".localized
        paragraph2TitleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)

        paragraph3TitleLabel.isAccessibilityElement = true
        paragraph3TitleLabel.accessibilityLabel = "ACC_CONDITIONS_PRIVACY_PARAGRAPH3_TITLE".localized
        paragraph3TitleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)

        acceptTermsLabel.isAccessibilityElement = true
        acceptTermsLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        acceptTermsLabel.accessibilityLabel = "ONBOARDING_STEP_2_USAGE_CONDITIONS".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        acceptTermsLabel.accessibilityHint = "ACC_HINT".localized

        privacyLabel.isAccessibilityElement = true
        privacyLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        privacyLabel.accessibilityLabel = "ONBOARDING_STEP_2_PRIVACY_POLICY".localizedAttributed().string
        privacyLabel.accessibilityHint = "ACC_HINT".localized

        acceptSwitch.isAccessibilityElement = true
        acceptSwitch.accessibilityTraits = UISwitch().accessibilityTraits
        acceptSwitch.accessibilityLabel = "ACC_CHECKBOX_PRIVACY".localized
        acceptSwitch.accessibilityHint = "ACC_HINT".localized
        
        acceptTermsAndUseSwitch.isAccessibilityElement = true
        acceptTermsAndUseSwitch.accessibilityTraits = UISwitch().accessibilityTraits
        acceptTermsAndUseSwitch.accessibilityLabel = "ACC_CHECKBOX_USAGE_CONDITIONS".localized
        acceptTermsAndUseSwitch.accessibilityHint = "ACC_HINT".localized
        
        acceptButton.isAccessibilityElement = true
        acceptButton.accessibilityLabel = "ONBOARDING_CONTINUE_BUTTON".localized
        acceptButton.accessibilityHint = "ACC_HINT".localized
    }
    
    private func setupView() {
        
        acceptButton.setTitle("ONBOARDING_CONTINUE_BUTTON".localized, for: .normal)

        acceptButton.isEnabled = privacyAccepted && termsAndUseAccepted
        
        scrollView.alwaysBounceVertical = false
        
        acceptTermsLabel.isUserInteractionEnabled = true
        privacyLabel.isUserInteractionEnabled = true
        acceptView.isUserInteractionEnabled = true
        acceptTermsAndUseView.isUserInteractionEnabled = true
        
        // Add Gesture
        acceptView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                        action: #selector(userDidTapAccept(tapGestureRecognizer:))))
        
        acceptTermsAndUseView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                        action: #selector(userDidTapAcceptTermsAndUse(tapGestureRecognizer:))))

        acceptTermsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                              action: #selector(userDidTapTerms(tapGestureRecognizer:))))

        privacyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                          action: #selector(userDidTapPrivacy(tapGestureRecognizer:))))
    }
    
    private func privacyToggle() {
        privacyAccepted = !privacyAccepted
        
        if privacyAccepted {
            checkBoxImage.image = UIImage(named: "CheckboxSelected")
        } else {
            checkBoxImage.image = UIImage(named: "CheckboxUnselected")
        }
        
        acceptButton.isEnabled = privacyAccepted && termsAndUseAccepted
    }
    
    private func termsAndUseToggle() {
        termsAndUseAccepted = !termsAndUseAccepted
        
        if termsAndUseAccepted {
            checkBoxAcceptTermsAndUseImage.image = UIImage(named: "CheckboxSelected")
        } else {
            checkBoxAcceptTermsAndUseImage.image = UIImage(named: "CheckboxUnselected")
        }
        
        acceptButton.isEnabled = privacyAccepted && termsAndUseAccepted
    }
}
