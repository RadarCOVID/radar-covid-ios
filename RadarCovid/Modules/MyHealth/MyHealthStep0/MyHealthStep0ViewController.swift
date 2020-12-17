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
        startButton.accessibilityHint = "MY_HEALTH_STEP0_ALERT_START".localized
        startButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
        
        titleLabel?.accessibilityLabel = "ACC_MY_DIAGNOSTIC_TITLE".localized
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.showAlertCancelContinue(
            title: "ALERT_MY_HEALTH_SEND_TITLE".localizedAttributed,
            message: "ALERT_MY_HEALTH_SEND_CONTENT".localizedAttributed,
            buttonOkTitle: "ALERT_CANCEL_SEND_BUTTON".localizedAttributed.string,
            buttonCancelTitle: "ACC_BUTTON_CLOSE".localizedAttributed.string,
            buttonOkVoiceover: "ALERT_CANCEL_SEND_BUTTON".localizedAttributed.string,
            buttonCancelVoiceover: "ACC_BUTTON_CLOSE".localizedAttributed.string,
            okHandler: { () in
                self.router?.pop(from: self, animated: true)
        }, cancelHandler: { () in
        })
    }
    
    @IBAction func onStart(_ sender: Any) {
        self.router?.route(to: Routes.myHealthStep1, from: self)
    }
}

extension MyHealthStep0ViewController: AccTitleView {

    var accTitle: String? {
        get {
            "MY_HEALTH_TITLE_PAGE".localized
        }
    }
}
