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

    //MARK: - Outlet.
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var paragraph1TitleLabel: UILabel!
    @IBOutlet weak var paragraph1DescriptionLabel: UILabel!
    @IBOutlet weak var paragraph2TitleLabel: UILabel!
    @IBOutlet weak var paragraph3TitleLabel: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var checkBoxImage: UIImageView!
    
    @IBOutlet weak var acceptTermsLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!

    @IBOutlet weak var acceptView: UIView!
    @IBOutlet weak var acceptSwitch: UISwitch!

    @IBOutlet weak var acceptButton: UIButton!

    // MARK: - Properties
    var router: AppRouter?
    private var termsAccepted: Bool = false

    //MARK: - View Life Cycle Methods.
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupAccessibility()
    }

    //MARK: - Action methods.
    
    @IBAction func onSwithAcceptChange(_ sender: Any) {
        termsToggle()
    }

    @IBAction func onOk(_ sender: Any) {
        router?.route(to: Routes.proximity, from: self)
    }
    
    @objc func userDidTapAccept(tapGestureRecognizer: UITapGestureRecognizer) {
        termsToggle()
    }
    
    @objc func userDidTapTerms(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "USE_CONDITIONS_URL".localized)
    }

    @objc func userDidTapPrivacy(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "PRIVACY_POLICY_URL".localized)
    }
}

//MARK: - Accesibility.
extension OnBoardingViewController {
    
    func setupAccessibility() {
        
        acceptSwitch.tintColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
        acceptSwitch.layer.cornerRadius = acceptSwitch.frame.height / 2
        acceptSwitch.backgroundColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
        
        acceptSwitch.isOn = false
        
        if UIAccessibility.isVoiceOverRunning {
            paragraph1DescriptionLabel.text = paragraph1DescriptionLabel.text?.lowercased()
            acceptView.isHidden = true
            acceptSwitch.isHidden = false
        } else {
            acceptSwitch.isHidden = true
            acceptView.isHidden = false
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
        acceptTermsLabel.accessibilityHint = "ACC_HINT".localized

        privacyLabel.isAccessibilityElement = true
        privacyLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        privacyLabel.accessibilityHint = "ACC_HINT".localized

        acceptView.accessibilityTraits = UISwitch().accessibilityTraits
        acceptView.accessibilityLabel = "ACC_CHECKBOX_PRIVACY".localized

        acceptButton.isAccessibilityElement = true
    }
}

//MARK: - Private.
private extension OnBoardingViewController {
    
    func setupView() {
        
        acceptButton.setTitle("ONBOARDING_CONTINUE_BUTTON".localized, for: .normal)

        acceptButton.isEnabled = termsAccepted
        scrollView.alwaysBounceVertical = false
        
        acceptTermsLabel.isUserInteractionEnabled = true
        privacyLabel.isUserInteractionEnabled = true
        acceptView.isUserInteractionEnabled = true

        // Add Gesture
        acceptView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                        action: #selector(userDidTapAccept(tapGestureRecognizer:))))

        acceptTermsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                              action: #selector(userDidTapTerms(tapGestureRecognizer:))))

        privacyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                          action: #selector(userDidTapPrivacy(tapGestureRecognizer:))))
    }
    
    func termsToggle() {
        
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
}
