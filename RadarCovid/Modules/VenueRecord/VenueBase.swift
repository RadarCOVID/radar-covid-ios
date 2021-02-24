//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import Foundation
import UIKit

protocol VenueCanceller {
    var router: Router! { get }
}

class VenueViewController: BaseViewController, VenueCanceller {
    
    var router: Router!
    
    @IBAction func onCancel(_ sender: Any) {
        self.showAlertCancelContinue(
            title: "ALERT_MY_HEALTH_SEND_TITLE".localizedAttributed,
            message: "ALERT_MY_HEALTH_SEND_CONTENT".localizedAttributed,
            buttonOkTitle: "ALERT_CANCEL_SEND_BUTTON".localizedAttributed.string,
            buttonCancelTitle: "ACC_BUTTON_CLOSE".localizedAttributed.string,
            buttonOkVoiceover: "ALERT_CANCEL_SEND_BUTTON".localizedAttributed.string,
            buttonCancelVoiceover: "ACC_BUTTON_CLOSE".localizedAttributed.string,
            okHandler: { [weak self]() in
                guard let self = self else {
                    return
                }
                self.finallyCanceled()
            }, cancelHandler: { () in
            })
    }
    
    func finallyCanceled() {
        self.router.popToRoot(from: self, animated: true)
    }
    
    
}
