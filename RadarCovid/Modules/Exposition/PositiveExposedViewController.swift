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
    
    //MARK: - Outlet.
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var realInfectedLabel: UILabel!
    @IBOutlet weak var moreInfoLabel: UILabel!
    @IBOutlet weak var whatToDoLabel: UILabel!
    
    // MARK: - Properties
    var since: Date?
    private let bgImageRed = UIImage(named: "GradientBackgroundRed")

    //MARK: - View Life Cycle Methods.

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAccessibility()
    }
    
    //MARK: - Action methods.
    
    @objc override func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "EXPOSURE_INFECTED_INFO_URL".localized)
    }

    @objc func userDidTapMoreInfo(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "EXPOSITION_HIGH_MORE_INFO_URL".localized)
    }
}

//MARK: - Accesibility.
extension PositiveExposedViewController {
    
    func setupAccessibility() {
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        titleLabel.accessibilityLabel = "ACC_POSITIVE_EXPOSED_TITLE".localized

        whatToDoLabel.isAccessibilityElement = true
        whatToDoLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        whatToDoLabel.accessibilityLabel = "ACC_WHAT_TO_DO_TITLE".localized
    }
}

//MARK: - Private.
private extension PositiveExposedViewController {
    
    func setupView() {
        
        moreInfoLabel.isUserInteractionEnabled = true
        moreInfoLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                      action: #selector(userDidTapMoreInfo(tapGestureRecognizer:))))
        expositionBGView.image = bgImageRed
        
        setInfectedText()
    }
    
    func setInfectedText() {
        
        let date = self.since ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = Date.appDateFormat
        
        let actualizado = formatter.string(from: date)

        var daysSinceLastInfection = Date().days(sinceDate: since ?? Date()) ?? 1
        if daysSinceLastInfection == 0 {
            daysSinceLastInfection = 1
        }
        
        realInfectedLabel.attributedText = "EXPOSITION_EXPOSED_DESCRIPTION"
            .localizedAttributed(withParams: [String(daysSinceLastInfection), actualizado])
    }
}
