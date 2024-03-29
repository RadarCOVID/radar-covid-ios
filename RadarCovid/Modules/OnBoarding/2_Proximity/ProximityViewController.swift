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

class ProximityViewController: BaseViewController {

    @IBOutlet weak var continueButton: UIButton!

    var router: AppRouter?
    var radarStatusUseCase: RadarStatusUseCase?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAccessibility()
    }
    
    @IBAction func onContinue(_ sender: Any) {
        if radarStatusUseCase!.isTracingInit() {
            router!.route(to: .home, from: self)
        } else {
            router!.route(to: .home, from: self)
        }
    }
    
    private func setupAccessibility() {
        
        continueButton.setTitle("ONBOARDING_CONTINUE_BUTTON".localized, for: .normal)
        continueButton.accessibilityHint = "ACC_HINT".localized
        continueButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
        
        titleLabel?.accessibilityLabel = "ACC_HOW_WORKS_TITLE".localized
    }
}
