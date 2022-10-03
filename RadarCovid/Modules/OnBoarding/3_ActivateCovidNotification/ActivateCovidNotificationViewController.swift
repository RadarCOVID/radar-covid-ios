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
import ExposureNotification

class ActivateCovidNotificationViewController: BaseViewController {
    
    @IBOutlet weak var activateButton: UIButton!
    
    var router: AppRouter?
    var onBoardingCompletedUseCase: OnboardingCompletedUseCase?
    var radarStatusUseCase: RadarStatusUseCase?
    var errorHandler: ErrorHandler?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAccessibility()
    }
    
    @IBAction func onContinue(_ sender: Any) {
        (UIApplication.shared.delegate as? AppDelegate)?.bluethoothUseCase?.initListener()
        
        self.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha: 1, nil,
                                            "ACTIVATE_COVID_NOTIFICATION_POPUP_HOVER", UIColor.black)
        
        radarStatusUseCase?.changeTracingStatus(active: false)
            .subscribe(
                onError: {_ in
                    self.activationFinished()
                },
                onCompleted:{
                    self.radarStatusUseCase?.restoreLastStateAndSync().subscribe().disposed(by: self.disposeBag)
                    self.activationFinished()
                }).disposed(by: disposeBag)
    }
    
    private func setupAccessibility() {
        activateButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
        activateButton.accessibilityHint = "ACC_HINT".localized
        
        titleLabel?.accessibilityLabel = "ACC_ACTIVATE_COVID_NOTIFICATION_TITLE".localized
    }
    
    private func setupView() {
        activateButton.setTitle("ALERT_HOME_COVID_NOTIFICATION_OK_BUTTON".localized, for: .normal)
        errorHandler?.alertDelegate = self
    }
    
    private func activationFinished() {
        self.view.hideLoading()
        router?.route(to: .activatePush, from: self)
    }
}
