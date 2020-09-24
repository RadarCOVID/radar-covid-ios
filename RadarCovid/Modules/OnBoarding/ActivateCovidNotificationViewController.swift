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

    //MARK: - Outlet.
    @IBOutlet weak var activateButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Properties
    var router: AppRouter?
    var onBoardingCompletedUseCase: OnboardingCompletedUseCase?
    var radarStatusUseCase: RadarStatusUseCase?
    var errorHandler: ErrorHandler?
    
    private let disposeBag = DisposeBag()

    //MARK: - View Life Cycle Methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAccessibility()
    }

    //MARK: - Action methods.

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
}

//MARK: - Accesibility.
extension ActivateCovidNotificationViewController {
    
    func setupAccessibility() {
        
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        titleLabel.accessibilityLabel = "ACC_ACTIVATE_COVID_NOTIFICATION_TITLE".localized
    }
}

//MARK: - Private.
private extension ActivateCovidNotificationViewController {
    
    func setupView() {
        activateButton.setTitle("ALERT_HOME_COVID_NOTIFICATION_OK_BUTTON".localized, for: .normal)
        errorHandler?.alertDelegate = self
    }
    
    func activationFinished() {
        router?.route(to: .activatePush, from: self)
    }
}
