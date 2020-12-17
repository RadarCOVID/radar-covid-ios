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

class HelpSettingsViewController: BaseViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var bluetoothImage: UIImageView!
    @IBOutlet weak var radarSwitchImage: UIImageView!
    @IBOutlet weak var radarCovidImage: UIImageView!
    @IBOutlet weak var exposureStateImage: UIImageView!
    @IBOutlet weak var regionImage: UIImageView!
    @IBOutlet weak var shareExposureImage: UIImageView!
    
    var router: AppRouter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAccessibility()
    }
    
    private func setupView() {
        cancelButton.setTitle("ACC_BUTTON_CLOSE".localized, for: .normal)
        cancelButton.layer.borderColor = UIColor.deepLilac.cgColor
    }
    
    private func setupAccessibility() {
        closeButton.accessibilityLabel = "ACC_BUTTON_CLOSE".localized
        closeButton.accessibilityHint = "ACC_HINT".localized
        closeButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
        
        cancelButton.accessibilityLabel = "ACC_BUTTON_CLOSE".localized
        cancelButton.accessibilityHint = "ACC_HINT".localized
        cancelButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
        
        bluetoothImage.accessibilityLabel = "INFO_IMAGE_STEP_1".localized
        radarSwitchImage.accessibilityLabel = "INFO_IMAGE_STEP_2".localized
        radarCovidImage.accessibilityLabel = "INFO_IMAGE_STEP_4".localized
        exposureStateImage.accessibilityLabel = "INFO_IMAGE_STEP_3".localized
        regionImage.accessibilityLabel = "INFO_IMAGE_STEP_5".localized
        shareExposureImage.accessibilityLabel = "INFO_IMAGE_STEP_6".localized
    }
    
    @IBAction func onCloseAction(_ sender: Any) {
        router?.dissmiss(view: self, animated: true)
    }
    
}
