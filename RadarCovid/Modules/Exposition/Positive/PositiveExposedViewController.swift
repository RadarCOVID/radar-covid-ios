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
    
    @IBOutlet weak var realInfectedLabel: UILabel!
    @IBOutlet weak var moreInfoLabel: UILabel!
    @IBOutlet weak var whatToDoLabel: UILabel!
    
    var since: Date?
    private let bgImageRed = UIImage(named: "GradientBackgroundRed")

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupAccessibility()
    }
    
    @objc override func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "MORE_INFO_INFECTED".localized.getUrlFromHref())
    }

    @objc func userDidTapMoreInfo(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "EXPOSITION_HIGH_MORE_INFO".localized.getUrlFromHref())
    }
    
    private func setupAccessibility() {
        titleLabel?.accessibilityLabel = "ACC_POSITIVE_EXPOSED_TITLE".localized

        moreInfoLabel.isAccessibilityElement = true
        moreInfoLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        moreInfoLabel.accessibilityTraits.remove(UIAccessibilityTraits.button)
        moreInfoLabel.accessibilityLabel = "EXPOSITION_HIGH_MORE_INFO".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        moreInfoLabel.accessibilityHint = "ACC_HINT".localized
        
        moreInfoView.isAccessibilityElement = true
        moreInfoView.accessibilityTraits.insert(UIAccessibilityTraits.link)
        moreInfoView.accessibilityLabel = "MORE_INFO_HEALTH_REPORTED".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        moreInfoView.accessibilityHint = "ACC_HINT".localized
        
        whatToDoLabel.isAccessibilityElement = true
        whatToDoLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        whatToDoLabel.accessibilityLabel = "ACC_WHAT_TO_DO_TITLE".localized
    }
    
    private func setupView() {
        
        moreInfoLabel.isUserInteractionEnabled = true
        moreInfoLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                      action: #selector(userDidTapMoreInfo(tapGestureRecognizer:))))
        expositionBGView.image = bgImageRed
        
        setInfectedText()
    }
    
    private func setInfectedText() {
        
        let date = self.since ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = Date.appDateFormat
        
        let actualizado = formatter.string(from: date)
        var sinceDay = since ?? Date()
        sinceDay = sinceDay.getStartOfDay()
        
        let daysSinceLastInfection = Date().days(sinceDate: sinceDay) ?? 1
        
        realInfectedLabel.attributedText = "EXPOSITION_EXPOSED_DESCRIPTION".localizedAttributed(withParams: [String(daysSinceLastInfection), actualizado])
        
        realInfectedLabel.setMagnifierFontSize()
        
        realInfectedLabel.accessibilityLabel = "EXPOSITION_EXPOSED_DESCRIPTION"
            .localizedAttributed(withParams: [String(daysSinceLastInfection), date.getAccesibilityDate() ?? ""]).string
        
        self.view.setFontTextStyle()
    }
}
