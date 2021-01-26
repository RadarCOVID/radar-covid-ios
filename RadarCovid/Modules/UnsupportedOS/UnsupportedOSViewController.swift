//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import Foundation
import UIKit

class UnsupportedOSViewController: UIViewController {
    
    @IBOutlet weak var openSettingsButton: UIButton!
    @IBOutlet weak var closeAppButton: UIButton!
    @IBOutlet weak var step1: UILabel!
    @IBOutlet weak var step2: UILabel!
    @IBOutlet weak var step3: UILabel!
    @IBOutlet weak var step4: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAccessibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupAccessibility(){
        step1.accessibilityLabel = "1, " + "UPDATE_REQUIRED_STEP_1".localized
        step2.accessibilityLabel = "2, " + "UPDATE_REQUIRED_STEP_2".localized
        step3.accessibilityLabel = "3, " + "UPDATE_REQUIRED_STEP_3".localized
        step4.accessibilityLabel = "4, " + "UPDATE_REQUIRED_STEP_4".localized
    }
    
    private func setupView() {
        openSettingsButton.setTitle("UPDATE_REQUIRED_GO_TO_SETTINGS".localized, for: .normal)
        closeAppButton.layer.borderWidth = 1
        closeAppButton.layer.borderColor = UIColor.deepLilac.cgColor
        closeAppButton.setTitle("UPDATE_REQUIRED_CLOSE_APP".localized, for: .normal)
    }
    
    @IBAction func openSettingsClicked(_ sender: Any) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func closeAppClicked(_ sender: Any) {
        exit(0)
    }
    
}
