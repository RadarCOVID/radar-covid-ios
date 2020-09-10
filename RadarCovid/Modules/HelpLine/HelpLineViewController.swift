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

class HelpLineViewController: UIViewController, MFMailComposeViewControllerDelegate {

    var router: AppRouter?
    var preferencesRepository: PreferencesRepository?
    private let disposeBag = DisposeBag()

    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var phoneView: BackgroundView!
    @IBOutlet weak var faqWebLabel: UILabel!
    @IBOutlet weak var infoWebLabel: UILabel!
    @IBOutlet weak var otherWebLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        viewTitle.isAccessibilityElement = true
        viewTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        viewTitle.accessibilityLabel = "ACC_MORE_INFO".localized
        phoneView.image = UIImage(named: "WhiteCard")

        faqWebLabel.isUserInteractionEnabled = true
        faqWebLabel.isAccessibilityElement = true
        faqWebLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        faqWebLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapFaq(tapGestureRecognizer:))))

        infoWebLabel.isUserInteractionEnabled = true
        infoWebLabel.isAccessibilityElement = true
        infoWebLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        infoWebLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapWeb(tapGestureRecognizer:))))

        otherWebLabel.isUserInteractionEnabled = true
        otherWebLabel.isAccessibilityElement = true
        otherWebLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        otherWebLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapOther(tapGestureRecognizer:))))

    }

    @objc func onCallTap(tapGestureRecognizer: UITapGestureRecognizer) {
        open(phone: "CONTACT_PHONE".localized)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @objc func userDidTapFaq(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "HELPLINE_FAQS_WEB_URL".localized)
    }
    
    @objc func userDidTapWeb(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "HELPLINE_INFO_WEB_URL".localized)
    }
    
    @objc func userDidTapOther(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "HELPLINE_OTHER_WEB_URL".localized)
    }


}
