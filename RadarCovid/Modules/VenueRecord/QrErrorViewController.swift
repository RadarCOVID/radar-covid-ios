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
import CrowdNotifierSDK

class QrErrorViewController: BaseViewController {
    
    var router: AppRouter!
    
    var error: Error?
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAccesibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleError()
    }
    
    @IBAction func onOk(_ sender: Any) {
        router.pop(from: self, to: QrScannerViewController.self, animated: true)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        router.pop(from: self, to: QrScannerViewController.self, animated: true)
    }
    
    @IBAction func onBack(_ sender: Any) {
        router.pop(from: self, to: QrScannerViewController.self, animated: true)
    }
    
    private func setupView() {
        self.title = "VENUE_RECORD_ERROR_CODE_TITLE".localized
        
        cancelButton.setTitle("ACC_BUTTON_CLOSE".localized, for: .normal)
        
        okButton.setTitle("VENUE_HOME_BUTTON_START".localized, for: .normal)
    }
    
    private func setupAccesibility() {
        cancelButton.accessibilityLabel = "ACC_BUTTON_CLOSE".localized
        cancelButton.accessibilityHint = "ACC_HINT".localized
        cancelButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
        
        okButton.accessibilityLabel = "VENUE_HOME_BUTTON_START".localized
        okButton.accessibilityHint = "ACC_HINT".localized
        okButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
    }
    
    private func handleError() {
        if let error = self.error {
            if case CrowdNotifierError.validFromError = error {
                errorLabel.text = "QR_NOT_VALID_YET_ERROR".localized
            } else if case CrowdNotifierError.validToError = error {
                errorLabel.text = "QR_OUTDATED_ERROR".localized
            } else {
                errorLabel.text = "VENUE_RECORD_ERROR_CODE_PARAGRAPH_1".localized
            }
        } else {
            errorLabel.text = "VENUE_RECORD_ERROR_CODE_PARAGRAPH_1".localized
        }
    }
}

extension QrErrorViewController: AccTitleView {

    var accTitle: String? {
        get {
            "QR_ERROR_PAGE_TITLE".localized
        }
    }
}
