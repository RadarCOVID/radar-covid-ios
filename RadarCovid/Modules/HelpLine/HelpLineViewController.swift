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
import MessageUI
import RxSwift

class HelpLineViewController: BaseViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var phoneView: BackgroundView!
    @IBOutlet weak var faqWebLabel: UILabel!
    @IBOutlet weak var infoWebLabel: UILabel!
    @IBOutlet weak var otherWebLabel: UILabel!
    
    @IBOutlet weak var acceptTermsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var bullet2Label: UILabel!
    @IBOutlet weak var bullet3Label: UILabel!
    
    var router: AppRouter?
    var preferencesRepository: PreferencesRepository?
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAccessibility()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIAccessibility.post(notification: .layoutChanged, argument: self.titleLabel)
            }
        }
    }
    
    @objc func onCallTap(tapGestureRecognizer: UITapGestureRecognizer) {
        open(phone: "CONTACT_PHONE".localized)
    }

    @objc func userDidTapFaq(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "HELPLINE_FAQS_WEB_TITLE".localized.getUrlFromHref())
    }

    @objc func userDidTapWeb(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "HELPLINE_INFO_WEB_TITLE".localized.getUrlFromHref())
    }

    @objc func userDidTapOther(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "HELPLINE_OTHER_WEB_TITLE".localized.getUrlFromHref())
    }
    
    private func setupAccessibility() {
        
        titleLabel?.accessibilityLabel = "ACC_MORE_INFO".localized

        faqWebLabel.isAccessibilityElement = true
        faqWebLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        faqWebLabel.accessibilityLabel = ((faqWebLabel.text?.components(separatedBy: " ") ?? [""]).compactMap { $0.uppercased().contains("FAQ") ? " " + ($0.enumerated().map {"\($1)."}).joined() : " \($0)" }).joined()
        faqWebLabel.accessibilityHint = "ACC_HINT".localized

        infoWebLabel.isAccessibilityElement = true
        infoWebLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        infoWebLabel.accessibilityHint = "ACC_HINT".localized

        otherWebLabel.isAccessibilityElement = true
        otherWebLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        otherWebLabel.accessibilityHint = "ACC_HINT".localized
        
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
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    private func setupView() {
        
        phoneView.image = UIImage(named: "WhiteCard")

        faqWebLabel.isUserInteractionEnabled = true
        faqWebLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                        action: #selector(userDidTapFaq(tapGestureRecognizer:))))

        infoWebLabel.isUserInteractionEnabled = true
        infoWebLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                        action: #selector(userDidTapWeb(tapGestureRecognizer:))))

        otherWebLabel.isUserInteractionEnabled = true
        otherWebLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                        action: #selector(userDidTapOther(tapGestureRecognizer:))))
        
        acceptTermsLabel.isUserInteractionEnabled = true
        privacyLabel.isUserInteractionEnabled = true

        acceptTermsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                              action: #selector(userDidTapTerms(tapGestureRecognizer:))))

        privacyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                          action: #selector(userDidTapPrivacy(tapGestureRecognizer:))))
    }
    
    @objc func userDidTapTerms(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "MY_DATA_TERMS".localized.getUrlFromHref())
    }

    @objc func userDidTapPrivacy(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "MY_DATA_PRIVACY".localized.getUrlFromHref())
    }
    
}
