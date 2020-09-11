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
import RxSwift

class ProximityViewController: UIViewController {

    private let disposeBag = DisposeBag()

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var viewTitle: UILabel!
    
    var router: AppRouter?
    var radarStatusUseCase: RadarStatusUseCase?

    @IBAction func onContinue(_ sender: Any) {
        if radarStatusUseCase!.isTracingInit() {
            router!.route(to: .activatePush, from: self)
        } else {
            router!.route(to: .activateCovid, from: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccessibility()
    }
    
    func setupAccessibility() {
        continueButton.setTitle("ONBOARDING_CONTINUE_BUTTON".localized, for: .normal)
        continueButton.isAccessibilityElement = true
        continueButton.accessibilityTraits.insert(UIAccessibilityTraits.button)
        continueButton.accessibilityHint = "ACC_HINT".localized
        
        viewTitle.isAccessibilityElement = true
        viewTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        viewTitle.accessibilityLabel = "ACC_HOW_WORKS_TITLE".localized
    }

}
