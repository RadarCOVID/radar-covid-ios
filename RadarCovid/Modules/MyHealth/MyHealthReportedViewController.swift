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

    var router: AppRouter?

    @IBOutlet weak var moreinfolabel: UILabel!
    @IBOutlet weak var moreInfoView: UIView!
    @IBOutlet weak var viewTitle: UILabel!
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        moreInfoView.isUserInteractionEnabled = true
        moreInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapLabel(tapGestureRecognizer:))))
        moreinfolabel.isUserInteractionEnabled = true
        moreinfolabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapMoreInfo(tapGestureRecognizer:))))
        viewTitle.isAccessibilityElement = true
        viewTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        viewTitle.accessibilityLabel = "ACC_DIAGNOSTIC_SENT_TITLE".localized
        if UIAccessibility.isVoiceOverRunning {
            viewTitle.isHidden = false
        }else{
            viewTitle.isHidden = true
        }
    }

    @objc func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "EXPOSURE_INFECTED_INFO_URL".localized)
    }
    
    @objc func userDidTapMoreInfo(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "EXPOSITION_HIGH_MORE_INFO_URL".localized)
    }

}
