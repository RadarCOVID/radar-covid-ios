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

class TermsUpdatedViewController: BaseViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var acceptTermsLabel: UILabel!
    @IBOutlet weak var acceptPrivacyPolicyLabel: UILabel!

    @IBOutlet weak var acceptSwitch: CustomSwitch!
    @IBOutlet weak var acceptTermsAndUseSwitch: CustomSwitch!

    var policyAccepted = false
    var termsAccepted = false
    
    var allTermsAccepted: Bool {
        return policyAccepted && termsAccepted
    }
    
    var router: AppRouter?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAccessibility()
    }
    
    @IBAction func onAcceptButton(_ sender: Any) {
        if self.allTermsAccepted {
            let termsRepo = TermsAcceptedRepository()
            termsRepo.termsAccepted = true
            router?.dissmiss(view: self, animated: true)   
        }
    }
    
    private func setupAccessibility() {
        acceptButton.accessibilityLabel = "ACC_BUTTON_ACCEPT".localized
        acceptButton.accessibilityHint = "ACC_HINT".localized
        
        self.acceptSwitch.setAccesibilityLabel(accessibilityLabel: "ACC_CHECKBOX_PRIVACY".localized)
        self.acceptTermsAndUseSwitch.setAccesibilityLabel(accessibilityLabel: "ACC_CHECKBOX_USAGE_CONDITIONS".localized)
    }
    
    private func setupView() {
        acceptButton.setTitle("ACC_BUTTON_ACCEPT".localized, for: .normal)
        
        self.acceptButton.isEnabled = self.allTermsAccepted
        
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 8
        
        self.acceptSwitch.delegate = self
        self.acceptTermsAndUseSwitch.delegate = self
        
        acceptTermsLabel.isUserInteractionEnabled = true
        acceptPrivacyPolicyLabel.isUserInteractionEnabled = true
        
        acceptPrivacyPolicyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                     action: #selector(userDidTapPolicy)))
        acceptTermsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                     action: #selector(userDidTapTerms)))
        
        setupAccessibility()
    }
    
    @objc func userDidTapTerms() {
        onWebTap(tapGestureRecognizer: nil, urlString: "ONBOARDING_STEP_2_USAGE_CONDITIONS".localized.getUrlFromHref())
    }
    
    @objc func userDidTapPolicy() {
        onWebTap(tapGestureRecognizer: nil, urlString: "ONBOARDING_STEP_2_PRIVACY_POLICY".localized.getUrlFromHref())
    }
    
    private func updateButtonStatus(){
        self.acceptButton.isEnabled = self.allTermsAccepted
        self.allTermsAccepted ?
            self.acceptButton.setBackgroundImage(UIImage(named: "buttonsPrimary"), for: .normal)
            : self.acceptButton.setBackgroundImage(UIImage(named: "ButtonPrimaryDisabled"), for: .normal)

    }
}

extension TermsUpdatedViewController: SwitchStateListener {
    func stateChanged(active: Bool, switcher: CustomSwitch) {
        if switcher.isTermSwitcher {
            self.termsAccepted = active
        }
        else {
            self.policyAccepted = active
        }
        updateButtonStatus()
    }
}
