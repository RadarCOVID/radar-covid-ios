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

class TimeExposedViewController: BaseViewController {

    @IBOutlet weak var bullet1Label: UILabel!
    @IBOutlet weak var bullet2Label: UILabel!
    @IBOutlet weak var bullet3Label: UILabel!
    @IBOutlet weak var moreInfoLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var router: AppRouter?
    var viewModel: TimeExposedViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAccessibility()
    }

    @IBAction func onCloseAction(_ sender: Any) {
        router?.dissmiss(view: self, animated: true)
    }
    
    @IBAction func onAcceptButton(_ sender: Any) {
        router?.dissmiss(view: self, animated: true)
    }
    
    @objc func userDidTapClose(tapGestureRecognizer: UITapGestureRecognizer) {
        router?.dissmiss(view: self, animated: true)
    }

    @objc func userDidTapPrecauciones(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "ALERT_HIGH_EXPOSURE_HEALED_BULLET_1".localized.getUrlFromHref())
    }

    @objc func userDidTapSintomas(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "ALERT_HIGH_EXPOSURE_HEALED_BULLET_2".localized.getUrlFromHref())
    }

    @objc func userDidTapInformacion(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "ALERT_HIGH_EXPOSURE_HEALED_MORE_INFO".localized.getUrlFromHref())
    }
    
    private func setupAccessibility() {
        acceptButton.accessibilityLabel = "ACC_BUTTON_ACCEPT".localized
        acceptButton.accessibilityHint = "ACC_HINT".localized
        acceptButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
        
        cancelButton.accessibilityLabel = "ACC_BUTTON_CLOSE".localized
        cancelButton.accessibilityHint = "ACC_HINT".localized
        cancelButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
        
        bullet1Label.isAccessibilityElement = true
        bullet1Label.accessibilityTraits.insert(UIAccessibilityTraits.link)
        bullet1Label.accessibilityLabel = "ALERT_HIGH_EXPOSURE_HEALED_BULLET_1".localizedAttributed().string
        bullet1Label.accessibilityHint = "ACC_HINT".localized
        
        bullet2Label.isAccessibilityElement = true
        bullet2Label.accessibilityTraits.insert(UIAccessibilityTraits.link)
        bullet2Label.accessibilityLabel = "ALERT_HIGH_EXPOSURE_HEALED_BULLET_2".localizedAttributed().string
        bullet2Label.accessibilityHint = "ACC_HINT".localized
        
        moreInfoLabel.isAccessibilityElement = true
        moreInfoLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        moreInfoLabel.accessibilityLabel = "ALERT_HIGH_EXPOSURE_HEALED_MORE_INFO".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        moreInfoLabel.accessibilityHint = "ACC_HINT".localized
    }
    
    private func setupView() {
        acceptButton.setTitle("ACC_BUTTON_ACCEPT".localized, for: .normal)
        cancelButton.setTitle("ACC_BUTTON_CLOSE".localized, for: .normal)

        bullet1Label.isUserInteractionEnabled = true
        bullet2Label.isUserInteractionEnabled = true
        moreInfoLabel.isUserInteractionEnabled = true
        
        cancelButton.layer.borderColor = UIColor.deepLilac.cgColor
        
        bullet1Label.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                     action: #selector(userDidTapPrecauciones(tapGestureRecognizer:))))
        bullet2Label.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                     action: #selector(userDidTapSintomas(tapGestureRecognizer:))))
        moreInfoLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                      action: #selector(userDidTapInformacion(tapGestureRecognizer:))))
    }
}
