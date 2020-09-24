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

    //MARK: - Outlet.
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Properties
    var router: AppRouter?
    var radarStatusUseCase: RadarStatusUseCase?
    
    private let disposeBag = DisposeBag()

    //MARK: - View Life Cycle Methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccessibility()
    }
    
    //MARK: - Action methods.
    
    @IBAction func onContinue(_ sender: Any) {
        
        if radarStatusUseCase!.isTracingInit() {
            router!.route(to: .activatePush, from: self)
        } else {
            router!.route(to: .activateCovid, from: self)
        }
    }
}

//MARK: - Accesibility.
extension ProximityViewController {
    
    func setupAccessibility() {
        
        continueButton.setTitle("ONBOARDING_CONTINUE_BUTTON".localized, for: .normal)
        continueButton.isAccessibilityElement = true
        continueButton.accessibilityTraits.insert(UIAccessibilityTraits.button)
        continueButton.accessibilityHint = "ACC_HINT".localized

        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        titleLabel.accessibilityLabel = "ACC_HOW_WORKS_TITLE".localized
    }
}
