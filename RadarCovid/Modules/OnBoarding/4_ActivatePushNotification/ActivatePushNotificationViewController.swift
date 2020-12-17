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

class ActivatePushNotificationViewController: BaseViewController {
    
    @IBOutlet weak var allowButton: UIButton!
    
    var router: AppRouter?
    private let disposeBag = DisposeBag()
    var notificationHandler: NotificationHandler?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAccessibility()
    }
    
    @IBAction func onContinue(_ sender: Any) {

        self.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha: 1, nil,
                                 "ACTIVATE_PUSH_NOTIFICATION_POPUP_HOVER", UIColor.black)
        
        self.notificationHandler?.setupNotifications().subscribe(onNext: { [weak self] _ in
            DispatchQueue.main.async {
                self?.navigateHome()
            }
        }).disposed(by: disposeBag)
    }
    
    private func setupAccessibility() {
        
        allowButton.setTitle("ACTIVATE_PUSH_NOTIFICATION_ALLOW_BUTTON".localized, for: .normal)
        allowButton.accessibilityHint = "ACC_HINT".localized
        allowButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)

        titleLabel?.accessibilityLabel = "ACC_ACTIVATE_PUSH_NOTIFICATION_TITLE".localized
    }
    
    private func navigateHome() {
         router?.route(to: .home, from: self)
    }
}
