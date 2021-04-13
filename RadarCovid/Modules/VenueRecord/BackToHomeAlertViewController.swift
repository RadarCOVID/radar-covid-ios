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

class BackToHomeAlertViewController: BaseViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    weak var delegate: BackToHomeConfirmationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccesibility()
        setupView()
    }
    
    private func setupView() {
        cancelButton.setTitle("ALERT_CANCEL_BUTTON".localized, for: .normal)
        acceptButton.setTitle("VENUE_RECORD_BACK_HOME_BUTTON".localized, for: .normal)
    }
    
    private func setupAccesibility() {
        
        cancelButton.isUserInteractionEnabled = true
        cancelButton.isAccessibilityElement = true
        cancelButton.accessibilityHint = "ACC_HINT".localized
        
        acceptButton.isUserInteractionEnabled = true
        acceptButton.isAccessibilityElement = true
        acceptButton.accessibilityHint = "ACC_HINT".localized
        
        closeButton.isUserInteractionEnabled = true
        closeButton.isAccessibilityElement = true
        closeButton.accessibilityHint = "ACC_HINT".localized
        closeButton.accessibilityLabel = "ACC_BUTTON_CLOSE".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backgroundView.fadeIn(0.82, duration: 0.5)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        close()
    }
    
    @IBAction func onClose(_ sender: Any) {
        close()
    }
    
    @IBAction func onAccept(_ sender: Any) {
        close { [weak self] in
            self?.delegate?.backOK()
        }
    }
    
    private func close(completion: (() -> Void)? = nil) {
        backgroundView.fadeOut()
        dismiss(animated: true, completion: completion)
    }
    
}

protocol BackToHomeConfirmationDelegate: class {
    func backOK()
}
