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
        
    }
    
    @objc func userDidTapTerms(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "MY_DATA_TERMS".localized.getUrlFromHref())
    }

    @objc func userDidTapPrivacy(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "MY_DATA_PRIVACY".localized.getUrlFromHref())
    }
    
}
