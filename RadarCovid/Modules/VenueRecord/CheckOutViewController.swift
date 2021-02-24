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

class CheckOutViewController: VenueViewController {
    
    var venueRecordUseCase: VenueRecordUseCase!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func endRegisterTap(_ sender: Any) {
        venueRecordUseCase.checkOut(date: Date())
        router.route(to: .checkOutConfirmation, from: self)
    }
    
    @IBAction func onClose(_ sender: Any) {
        router.pop(from: self, animated: true)
    }
    
    override func finallyCanceled() {
        venueRecordUseCase.cancelCheckIn()
        super.finallyCanceled()
    }
    
}
