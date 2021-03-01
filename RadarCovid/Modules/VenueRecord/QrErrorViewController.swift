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

class QrErrorViewController: BaseViewController {
    
    var router: AppRouter!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAccesibility()
    }
    
    @IBAction func onOk(_ sender: Any) {
        router.pop(from: self, animated: true)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        router.pop(from: self, animated: true)
    }
    
    @IBAction func onBack(_ sender: Any) {
        router.pop(from: self, animated: true)
    }
    
    private func setupView() {
        self.title = "QR_ERROR_PAGE_TITLE".localized
        cancelButton.setTitle("ACC_BUTTON_CLOSE".localized, for: .normal)
    }
    
    private func setupAccesibility() {
        cancelButton.accessibilityLabel = "ACC_BUTTON_CLOSE".localized
        cancelButton.accessibilityHint = "ACC_HINT".localized
        cancelButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
    }

}

extension QrErrorViewController: AccTitleView {

    var accTitle: String? {
        get {
            "QR_ERROR_PAGE_TITLE".localized
        }
    }
}
