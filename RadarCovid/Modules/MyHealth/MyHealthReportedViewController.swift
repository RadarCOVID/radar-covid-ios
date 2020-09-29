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

class MyHealthReportedViewController: UIViewController {

    //MARK: - Outlet.
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreinfoLabel: UILabel!
    @IBOutlet weak var moreInfoView: UIView!
    
    // MARK: - Properties
    var router: AppRouter?

    //MARK: - View Life Cycle Methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAccessibility()
    }

    //MARK: - Action methods.
    
    @IBAction func onBack(_ sender: Any) {
        router?.popToRoot(from: self, animated: true)
    }
    
    @objc func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "MORE_INFO_INFECTED".localized.getUrlFromHref())
    }

    @objc func userDidTapMoreInfo(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "MY_HEALTH_REPORTED_MORE_INFO".localized.getUrlFromHref())
    }

}

//MARK: - Accesibility.
extension MyHealthReportedViewController {
    
    func setupAccessibility() {
        
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        titleLabel.accessibilityLabel = "ACC_DIAGNOSTIC_SENT_TITLE".localized
        
        moreInfoView.isAccessibilityElement = true
        moreInfoView.accessibilityTraits.insert(UIAccessibilityTraits.link)
        moreInfoView.accessibilityLabel = "MORE_INFO_INFECTED".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        moreInfoView.accessibilityHint = "ACC_HINT".localized
        
        moreinfoLabel.isAccessibilityElement = true
        moreinfoLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        moreinfoLabel.accessibilityLabel = "MY_HEALTH_REPORTED_MORE_INFO".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        moreinfoLabel.accessibilityHint = "ACC_HINT".localized
        
        if UIAccessibility.isVoiceOverRunning {
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }
    }
}

//MARK: - Private.
private extension MyHealthReportedViewController {
    
    func setupView() {
        
        moreInfoView.isUserInteractionEnabled = true
        moreInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                          action: #selector(userDidTapLabel(tapGestureRecognizer:))))
        moreinfoLabel.isUserInteractionEnabled = true
        moreinfoLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                           action: #selector(userDidTapMoreInfo(tapGestureRecognizer:))))
    }
}
