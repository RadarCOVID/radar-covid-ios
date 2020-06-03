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

protocol ExpositionView {
    func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer)
}

class BaseExposed: UIViewController, ExpositionView {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var moreInfoView: UIView!
    @IBOutlet weak var expositionBGView: BackgroundView!
    var lastCheck: Date?

    override func viewDidLoad() {
        moreInfoView.isUserInteractionEnabled = true
        moreInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapLabel(tapGestureRecognizer:))))

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backButton.isAccessibilityElement = true
        let previous = navigationController?.previousViewController
        if let title = (previous as? AccTitleView)?.accTitle ?? previous?.title {
            backButton.accessibilityLabel = "ACC_BUTTON_BACK_TO".localized + " " + title
        } else {
            backButton.accessibilityLabel = "ACC_BUTTON_BACK".localized
        }
    }

    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @objc func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer) {

    }

}
