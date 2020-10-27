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
import RxSwift
import DP3TSDK
import SafariServices

protocol TermsViewProtocol {
    func hiddenTermsdView()
}

class TermsView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var acceptTermsLabel: UILabel!
    @IBOutlet weak var acceptPrivacyPolicyLabel: UILabel!

    @IBOutlet var switchers: [CustomSwitch]!

    var parentViewController: UIViewController?
    var viewModel: HomeViewModel?
    var policyAccepted = false
    var termsAccepted = false
    var allTermsAccepted: Bool {
        return policyAccepted && termsAccepted
    }
    var delegate: TimeExposedProtocol?

    class func initWithParentViewController(viewController: HomeViewController, delegate: TimeExposedProtocol) {
        
        guard let termsUpdatedView = UINib(nibName: "TermsUpdated", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? TermsView else {
            return
        }
        
        termsUpdatedView.parentViewController = viewController
        termsUpdatedView.delegate = delegate
        termsUpdatedView.viewModel = viewController.viewModel
        termsUpdatedView.initValues()
        
        
        let newFrame = CGRect(x: viewController.view.frame.origin.x,
                              y: viewController.view.frame.origin.y,
                              width: viewController.view.frame.width * 92 / 100,
                              height: viewController.view.frame.height * 85 / 100)
        termsUpdatedView.frame = newFrame
        termsUpdatedView.center = viewController.view.center
        
        viewController.navigationController?.topViewController?.view.addSubview(termsUpdatedView)
        viewController.navigationController?.topViewController?.view.bringSubviewToFront(termsUpdatedView)
        
        UIAccessibility.post(notification: .layoutChanged, argument: termsUpdatedView.titleLabel)
    }
    
    @IBAction func onAcceptButton(_ sender: Any) {
        if self.allTermsAccepted {
            let termsRepo = TermsAcceptedRepository()
            termsRepo.termsAccepted = true
            removePopUpView()
        }
    }
 
    @objc func onWebTap(urlString: String? = nil) {
        guard var urlString = urlString else {
            return
        }

        if !urlString.contains("://") {
            urlString = "https://\(urlString)"
        }
        if let url = URL(string: urlString) {
            let config = SFSafariViewController.Configuration()

            let viewController = SFSafariViewController(url: url, configuration: config)
            parentViewController?.present(viewController, animated: true)
        }
    }
    
    private func setupAccessibility() {
        acceptButton.accessibilityLabel = "ACC_BUTTON_ACCEPT".localized
        acceptButton.accessibilityHint = "ACC_HINT".localized
    }
    
    private func initValues() {
        self.acceptButton.isEnabled = self.allTermsAccepted
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 8
        self.switchers.forEach { (switcher) in
            switcher.delegate = self
        }
        acceptTermsLabel.isUserInteractionEnabled = true
        acceptPrivacyPolicyLabel.isUserInteractionEnabled = true
        acceptPrivacyPolicyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                     action: #selector(userDidTapPolicy)))
        acceptTermsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                     action: #selector(userDidTapTerms)))
        setupAccessibility()
    }
    
    @objc func userDidTapTerms(){
        onWebTap(urlString: "ONBOARDING_STEP_2_USAGE_CONDITIONS".localized.getUrlFromHref())
    }
    
    @objc func userDidTapPolicy(){
        onWebTap(urlString: "ONBOARDING_STEP_2_PRIVACY_POLICY".localized.getUrlFromHref())
    }
    
    private func removePopUpView() {
        self.delegate?.hiddenTimeExposedView()
        for view in parentViewController?.navigationController?.topViewController?.view.subviews ?? [] where view.tag == 1111 {
            view.fadeOut { (_) in
                view.removeFromSuperview()
            }
        }
    }
    
    private func updateButtonStatus(){
        self.acceptButton.isEnabled = self.allTermsAccepted
        self.allTermsAccepted ?
            self.acceptButton.setBackgroundImage(UIImage(named: "buttonsPrimary"), for: .normal)
            : self.acceptButton.setBackgroundImage(UIImage(named: "ButtonPrimaryDisabled"), for: .normal)

    }
}

extension TermsView: SwitchStateListener {
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
