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

class VenueRecordStartViewController: BaseViewController {
    
    var router: AppRouter!
    var venueRecordUseCase : VenueRecordUseCase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if venueRecordUseCase.isCheckedIn() {
            router.route(to: .checkedIn, from: self, parameters: true)
        }
    }
    
    @IBAction func onScanTap(_ sender: Any) {
        router.route(to: .qrScanner, from: self)
    }
}
