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
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func onCancel(_ sender: Any) {
        self.showAlertCancelContinue(
            title: "VENUE_RECORD_CANCEL_TITLE".localizedAttributed,
            message: "VENUE_RECORD_CANCEL_TEXT".localizedAttributed,
            buttonOkTitle: "VENUE_RECORD_CANCEL_CONTINUE".localizedAttributed.string,
            buttonCancelTitle: "ALERT_CANCEL_BUTTON".localizedAttributed.string,
            buttonOkVoiceover: "VENUE_RECORD_CANCEL_CONTINUE".localizedAttributed.string,
            buttonCancelVoiceover: "ALERT_CANCEL_BUTTON".localizedAttributed.string,
            okHandler: {
        
            }, cancelHandler: { [weak self] () in
                self?.finallyCanceled()
            })
    }
    
    func finallyCanceled() {
        router.popToRoot(from: self, animated: true)
    }
    
    func setupAccesibility() {
        cancelButton.isAccessibilityElement = true
        cancelButton.accessibilityHint = "ACC_BUTTON_ALERT_CANCEL".localized
    }
    
    func showGenericError() {
        showAlertOk(title: "ALERT_GENERIC_ERROR_TITLE".localized,
                          message: "ALERT_GENERIC_ERROR_CONTENT".localized,
                          buttonTitle: "ALERT_ACCEPT_BUTTON".localized)
    }
    
    
}
