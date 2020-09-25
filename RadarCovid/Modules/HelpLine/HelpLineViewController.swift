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

    //MARK: - Outlet.
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var phoneView: BackgroundView!
    @IBOutlet weak var faqWebLabel: UILabel!
    @IBOutlet weak var infoWebLabel: UILabel!
    @IBOutlet weak var otherWebLabel: UILabel!
    
    // MARK: - Properties
    var router: AppRouter?
    var preferencesRepository: PreferencesRepository?
    
    private let disposeBag = DisposeBag()

    //MARK: - View Life Cycle Methods.

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAccessibility()
        setupView()
    }

    //MARK: - Action methods.
    
    @objc func onCallTap(tapGestureRecognizer: UITapGestureRecognizer) {
        open(phone: "CONTACT_PHONE".localized)
    }

    @objc func userDidTapFaq(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "HELPLINE_FAQS_WEB_URL".localized)
    }

    @objc func userDidTapWeb(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "HELPLINE_INFO_WEB_URL".localized)
    }

    @objc func userDidTapOther(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "HELPLINE_OTHER_WEB_URL".localized)
    }
}

//MARK: - Accesibility.
extension HelpLineViewController {
    
    func setupAccessibility() {
        
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        titleLabel.accessibilityLabel = "ACC_MORE_INFO".localized

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
}

//MARK: - MFMailComposeViewControllerDelegate.
extension HelpLineViewController {
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

//MARK: - Private.
private extension HelpLineViewController {
    
    func setupView() {
        
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
}
