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

class QrResultViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
    
    var router: Router!
    
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
            venueRecordUseCase.checkIn(venue: VenueRecord(qr: qrCode, checkIn: Date(), checkOut: nil)).subscribe(
                onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.router.route(to: .checkedIn, from: self)
                },onError: { [weak self] error in
                    debugPrint(error)
                    self?.showAlertOk(
                        title: "",
                        message: "ERROR REGISTER",
                        buttonTitle: "ALERT_ACCEPT_BUTTON".localized)
                    
            }).disposed(by: disposeBag)
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        router.popToRoot(from: self, animated: true)
    }
    
    @IBAction func onBack(_ sender: Any) {
        router.popToRoot(from: self, animated: true)
    }
    
}
