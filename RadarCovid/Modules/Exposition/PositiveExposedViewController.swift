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

class PositiveExposedViewController: BaseExposed {
    private let bgImageRed = UIImage(named: "GradientBackgroundRed")

    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var moreinfo: UILabel!
    @IBOutlet weak var realInfectedText: UILabel!
    var since: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewTitle.isAccessibilityElement = true
        viewTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        viewTitle.accessibilityLabel = "ACC_POSITIVE_EXPOSED_TITLE".localized
        setInfectedText()
        moreinfo.isUserInteractionEnabled = true
        moreinfo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapMoreInfo(tapGestureRecognizer:))))
        expositionBGView.image = bgImageRed
        super.viewDidLoad()
    }

    func setInfectedText() {
        let date = self.since ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY"
        let actualizado = formatter.string(from: date)

        var daysSinceLastInfection = Date().days(sinceDate: since ?? Date()) ?? 1
        if daysSinceLastInfection == 0 {
            daysSinceLastInfection = 1
        }
        realInfectedText.attributedText = "EXPOSITION_EXPOSED_DESCRIPTION".localizedAttributed(withParams: [String(daysSinceLastInfection), actualizado])
    }

    @objc override func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "EXPOSURE_INFECTED_INFO_URL".localized)
    }
    
    @objc func userDidTapMoreInfo(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "EXPOSITION_HIGH_MORE_INFO_URL".localized)
    }

}
