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

class UnsupportedOSViewController: BaseViewController {
    
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var closeAppButton: UIButton!
    @IBOutlet weak var step1: UILabel!
    @IBOutlet weak var step2: UILabel!
    @IBOutlet weak var step3: UILabel!
    @IBOutlet weak var step4: UILabel!
    @IBOutlet weak var steps: UILabel!
    @IBOutlet weak var description1: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAccessibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupAccessibility(){
        
        header.accessibilityTraits.insert(UIAccessibilityTraits.header)
        
        step1.accessibilityLabel = "1, " + step1.text!
        step2.accessibilityLabel = "2, " + step2.text!
        step3.accessibilityLabel = "3, " + step3.text!
        step4.accessibilityLabel = "4, " + step4.text!
        
        closeAppButton.accessibilityHint = "ACC_HINT".localized
        closeAppButton.isUserInteractionEnabled = true
        closeAppButton.isAccessibilityElement = true
        
        steps.accessibilityLabel = "UPDATE_REQUIRED_STEPS".localizedAttributed().string.replacingOccurrences(of: "iOS", with: "ios")
        description1.accessibilityLabel = "UPDATE_REQUIRED_DESCRIPTION".localizedAttributed().string.replacingOccurrences(of: "iOS", with: "ios")
    }
    
    private func setupView() {
        closeAppButton.setTitle("UPDATE_REQUIRED_CLOSE_APP".localized, for: .normal)
        closeAppButton.layer.borderWidth = 1
        closeAppButton.layer.borderColor = UIColor.deepLilac.cgColor
    }
    
    @IBAction func closeAppClicked(_ sender: Any) {
        exit(0)
    }
    
}
