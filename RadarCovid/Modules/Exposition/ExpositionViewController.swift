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

class ExpositionViewController: BaseExposed {

    private let bgImageGreen = UIImage(named: "GradientBackgroundGreen")

    @IBOutlet weak var sincontactos: UILabel!

    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var whatToDoTitle: UILabel!
    @IBOutlet weak var whatToDo: UILabel!
    @IBOutlet weak var moreinfo: UILabel!

    private let formatter = DateFormatter()

    override func viewDidLoad() {

        super.viewDidLoad()

        formatter.dateFormat = "dd.MM.YYYY"

        setupAccessibility()
        whatToDo.isAccessibilityElement = true
        whatToDo.accessibilityTraits.insert(UIAccessibilityTraits.link)
        whatToDo.attributedText = "EXPOSITION_LOW_SYMPTOMS_WHAT_TO_DO".localizedAttributed()
        whatToDo.isUserInteractionEnabled = true
        whatToDo.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                      action: #selector(userDidTapWhatToDo(tapGestureRecognizer:))))

        moreinfo.isAccessibilityElement = true
        moreinfo.accessibilityTraits.insert(UIAccessibilityTraits.link)

        expositionBGView.image = bgImageGreen

    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        if let lastCheck = lastCheck {
            sincontactos.attributedText = "EXPOSITION_LOW_DESCRIPTION"
                .localizedAttributed(withParams: [formatter.string(from: lastCheck)])
        } else {
            sincontactos.isHidden = true
        }
    }

    func setupAccessibility() {
        viewTitle.isAccessibilityElement = true
        viewTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        viewTitle.accessibilityLabel = "ACC_LOW_EXPOSED_TITLE".localized

        whatToDoTitle.isAccessibilityElement = true
        whatToDoTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        whatToDoTitle.accessibilityLabel = "ACC_WHAT_TO_DO_TITLE".localized
    }

    @objc override func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "EXPOSURE_LOW_INFO_URL".localized)
    }

    @objc func userDidTapWhatToDo(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "EXPOSITION_LOW_SYMPTOMS_WHAT_TO_DO_URL".localized)
    }

}
