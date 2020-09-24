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

    //MARK: - Outlet.
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var withOutContactLabel: UILabel!
    @IBOutlet weak var whatToDoTitleLabel: UILabel!
    @IBOutlet weak var whatToDoLabel: UILabel!
    @IBOutlet weak var moreInfoLabel: UILabel!
    
    // MARK: - Properties
    private let bgImageGreen = UIImage(named: "GradientBackgroundGreen")

    //MARK: - View Life Cycle Methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupAccessibility()
    }

    //MARK: - Action methods.
    
    @objc override func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "EXPOSURE_LOW_INFO_URL".localized)
    }

    @objc func userDidTapWhatToDo(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "EXPOSITION_LOW_SYMPTOMS_WHAT_TO_DO_URL".localized)
    }
}

//MARK: - Accesibility.
extension ExpositionViewController {
    
    func setupAccessibility() {
        
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        titleLabel.accessibilityLabel = "ACC_LOW_EXPOSED_TITLE".localized

        whatToDoTitleLabel.isAccessibilityElement = true
        whatToDoTitleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        whatToDoTitleLabel.accessibilityLabel = "ACC_WHAT_TO_DO_TITLE".localized
        
        whatToDoLabel.isAccessibilityElement = true
        whatToDoLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        whatToDoLabel.attributedText = "EXPOSITION_LOW_SYMPTOMS_WHAT_TO_DO".localizedAttributed()
        whatToDoLabel.isUserInteractionEnabled = true
        
        moreInfoLabel.isAccessibilityElement = true
        moreInfoLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
    }
}

//MARK: - Private.
private extension ExpositionViewController {
    
    func setupView() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = Date.appDateFormat
        
        if let lastCheck = lastCheck {
            withOutContactLabel.attributedText = "EXPOSITION_LOW_DESCRIPTION"
                .localizedAttributed(withParams: [formatter.string(from: lastCheck)])
        } else {
            withOutContactLabel.isHidden = true
        }
        
        whatToDoLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                      action: #selector(userDidTapWhatToDo(tapGestureRecognizer:))))

        expositionBGView.image = bgImageGreen
    }
}
