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

class MyHealthStep0ViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    var router: AppRouter?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupAccessibility()
    }
    
    private func setupView() {
        startButton.setTitle("MY_HEALTH_STEP0_START".localized, for: .normal)
        self.title = "MY_HEALTH_TITLE_PAGE".localized
    }
    
    private func setupAccessibility() {
        startButton.isAccessibilityElement = true
        startButton.accessibilityLabel = "MY_HEALTH_STEP0_ALERT_START".localized
        
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        titleLabel.accessibilityLabel = "ACC_MY_DIAGNOSTIC_TITLE".localized
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.showAlertCancelContinue(
            title: "ALERT_MY_HEALTH_SEND_TITLE".localizedAttributed.string,
            message: "ALERT_MY_HEALTH_SEND_CONTENT".localizedAttributed.string,
            buttonOkTitle: "ALERT_OK_BUTTON".localizedAttributed.string,
            buttonCancelTitle: "ALERT_CANCEL_BUTTON".localizedAttributed.string,
            buttonOkVoiceover: "ACC_BUTTON_ALERT_OK".localizedAttributed.string,
            buttonCancelVoiceover: "ACC_BUTTON_ALERT_CANCEL".localizedAttributed.string,
            okHandler: { (_) in
                self.router?.pop(from: self, animated: true)
        }, cancelHandler: { (_) in
        })
    }
    
    @IBAction func onStart(_ sender: Any) {
        self.router?.route(to: Routes.myHealthStep1, from: self)
    }
}
