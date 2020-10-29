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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var withOutContactLabel: UILabel!
    @IBOutlet weak var whatToDoTitleLabel: UILabel!
    @IBOutlet weak var whatToDoLabel: UILabel!
    @IBOutlet weak var moreInfoLabel: UILabel!

    private let bgImageGreen = UIImage(named: "GradientBackgroundGreen")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setFontTextStyle()

        setupView()
        setupAccessibility()
    }

    @objc override func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "MORE_INFO_EXPOSURE_LOW".localized.getUrlFromHref())
    }

    @objc func userDidTapWhatToDo(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "EXPOSITION_LOW_SYMPTOMS_WHAT_TO_DO".localized.getUrlFromHref())
    }
    
    private func setupAccessibility() {
        
        titleLabel.isAccessibilityElement = true

        titleLabel.accessibilityLabel = "EXPOSITION_LOW_TITLE_2".localized

        whatToDoTitleLabel.isAccessibilityElement = true
        whatToDoTitleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        whatToDoTitleLabel.accessibilityLabel = "ACC_WHAT_TO_DO_TITLE".localized
        
        whatToDoLabel.isAccessibilityElement = true
        whatToDoLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        whatToDoLabel.accessibilityLabel = "EXPOSITION_LOW_SYMPTOMS_WHAT_TO_DO".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        whatToDoLabel.accessibilityHint = "ACC_HINT".localized
        
        moreInfoView.isAccessibilityElement = true
        moreInfoView.accessibilityTraits.insert(UIAccessibilityTraits.link)
        moreInfoView.accessibilityLabel = "MORE_INFO_EXPOSURE_LOW".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        moreInfoView.accessibilityHint = "ACC_HINT".localized
        
        moreInfoLabel.isAccessibilityElement = true
        moreInfoLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
    }
    
    private func setupView() {
        
        whatToDoLabel.attributedText = "EXPOSITION_LOW_SYMPTOMS_WHAT_TO_DO".localizedAttributed()
        
        let formatter = DateFormatter()
        formatter.dateFormat = Date.appDateFormat
        
        if let lastCheck = lastCheck {
            withOutContactLabel.attributedText = "EXPOSITION_LOW_DESCRIPTION"
                .localizedAttributed(withParams: [formatter.string(from: lastCheck)])
        } else {
            withOutContactLabel.isHidden = true
        }
        
        whatToDoLabel.isUserInteractionEnabled = true
        whatToDoLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                      action: #selector(userDidTapWhatToDo(tapGestureRecognizer:))))

        expositionBGView.image = bgImageGreen
    }
}
