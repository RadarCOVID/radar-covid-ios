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

class QrResultViewController: VenueViewController {
    
    var venueRecordUseCase: VenueRecordUseCase!
    
    @IBOutlet weak var venueNameLabel: UILabel!
    
    var qrCode: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        venueNameLabel.text = qrCode
    }
    
    @IBAction func onConfirmTap(_ sender: Any) {
        if let qrCode = qrCode {
            venueRecordUseCase.checkIn(venue: VenueRecord(id: qrCode, checkIn: Date(), checkOut: nil))
            router.route(to: .checkedIn, from: self)
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        router.pop(from: self, animated: true)
    }
    
}
