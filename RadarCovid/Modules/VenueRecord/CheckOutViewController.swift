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

class CheckOutViewController: VenueViewController {
    
    private let disposeBag = DisposeBag()
    
    var venueRecordUseCase: VenueRecordUseCase!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func endRegisterTap(_ sender: Any) {
        
        venueRecordUseCase.checkOut(date: Date()).subscribe(
            onNext: { [weak self] exposition in
                guard let self = self else { return }
                self.router.route(to: .checkOutConfirmation, from: self)
            }, onError: { [weak self] error in
                self?.showAlertOk(
                    title: "",
                    message: "ERROR REGISTER",
                    buttonTitle: "ALERT_ACCEPT_BUTTON".localized)
                
            }).disposed(by: disposeBag)
    }
    
    @IBAction func onClose(_ sender: Any) {
        router.pop(from: self, animated: true)
    }
    
    override func finallyCanceled() {
        venueRecordUseCase.cancelCheckIn()
        super.finallyCanceled()
    }
    
}
