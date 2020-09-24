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

    private let disposeBag = DisposeBag()

    var router: AppRouter?
    var onBoardingCompletedUseCase: OnboardingCompletedUseCase?
    var radarStatusUseCase: RadarStatusUseCase?
    var errorHandler: ErrorHandler?

    @IBOutlet weak var activateButton: UIButton!

    @IBOutlet weak var viewTitle: UILabel!
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

    func activationFinished() {
        router?.route(to: .activatePush, from: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        activateButton.setTitle("ALERT_HOME_COVID_NOTIFICATION_OK_BUTTON".localized, for: .normal)
        errorHandler?.alertDelegate = self
        setupAccessibility()
    }

    func setupAccessibility() {
        viewTitle.isAccessibilityElement = true
        viewTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        viewTitle.accessibilityLabel = "ACC_ACTIVATE_COVID_NOTIFICATION_TITLE".localized
    }

}
