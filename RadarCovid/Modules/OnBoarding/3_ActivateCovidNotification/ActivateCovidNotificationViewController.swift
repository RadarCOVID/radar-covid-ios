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

class ActivateCovidNotificationViewController: UIViewController {

    @IBOutlet weak var activateButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var router: AppRouter?
    var onBoardingCompletedUseCase: OnboardingCompletedUseCase?
    var radarStatusUseCase: RadarStatusUseCase?
    var errorHandler: ErrorHandler?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setFontTextStyle()
        
        setupView()
        setupAccessibility()
    }

    @IBAction func onContinue(_ sender: Any) {
        
        self.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha: 1, nil,
                            "ACTIVATE_COVID_NOTIFICATION_POPUP_HOVER".localizedAttributed(), UIColor.black)
        
        radarStatusUseCase?.restoreLastStateAndSync().subscribe(
                onError: { [weak self] error in
                self?.errorHandler?.handle(error: error)
                self?.activationFinished()
            }, onCompleted: { [weak self] in
                self?.activationFinished()
        }).disposed(by: disposeBag)
    }
    
    private func setupAccessibility() {
        activateButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
        activateButton.accessibilityHint = "ACC_HINT".localized
        
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        titleLabel.accessibilityLabel = "ACC_ACTIVATE_COVID_NOTIFICATION_TITLE".localized
    }
    
    private func setupView() {
        activateButton.setTitle("ALERT_HOME_COVID_NOTIFICATION_OK_BUTTON".localized, for: .normal)
        errorHandler?.alertDelegate = self
    }
    
    private func activationFinished() {
        router?.route(to: .activatePush, from: self)
    }
}
