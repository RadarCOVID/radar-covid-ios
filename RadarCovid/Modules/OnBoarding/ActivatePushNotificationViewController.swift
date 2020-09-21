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

class ActivatePushNotificationViewController: UIViewController {
    private let disposeBag = DisposeBag()
    var router: AppRouter?

    @IBOutlet weak var viewTitle: UILabel!
    var notificationHandler: NotificationHandler?

    @IBOutlet weak var allowButton: UIButton!

    @IBAction func onContinue(_ sender: Any) {

        self.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha: 1, nil,
                                 "ACTIVATE_PUSH_NOTIFICATION_POPUP_HOVER".localizedAttributed(), UIColor.white)

        self.notificationHandler?.setupNotifications().subscribe(onNext: { [weak self] _ in
            DispatchQueue.main.async {
                self?.navigateHome()
            }
        }).disposed(by: disposeBag)

    }

    private func navigateHome() {
         router?.route(to: .home, from: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccessibility()
    }

    func setupAccessibility() {
        allowButton.setTitle("ACTIVATE_PUSH_NOTIFICATION_ALLOW_BUTTON".localized, for: .normal)
        allowButton.isAccessibilityElement = true
        allowButton.accessibilityHint = "ACC_HINT".localized

        viewTitle.isAccessibilityElement = true
        viewTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        viewTitle.accessibilityLabel = "ACC_ACTIVATE_PUSH_NOTIFICATION_TITLE".localized
    }

}
