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
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueView: BackgroundView!
    
    var qrCode: String?
    private var venueRecord: VenueRecord?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadVenueInfo()
    }
    
    @IBAction func onConfirmTap(_ sender: Any) {
        if var venueRecord = venueRecord {
            venueRecord.checkIn = Date()
            venueRecordUseCase.checkIn(venue: venueRecord).subscribe(
                onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.router.route(to: .checkedIn, from: self)
                },onError: { [weak self] error in
                    debugPrint(error.localizedDescription)
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
    
    private func setupView() {
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.deepLilac.cgColor
        venueView.image = UIImage(named: "WhiteCard")
    }
    
    private func loadVenueInfo() {
        venueRecordUseCase.getVenueInfo(qrCode: qrCode ?? "").subscribe(
            onNext: { [weak self] venueRecord in
                self?.venueRecord = venueRecord
                self?.venueNameLabel.text = venueRecord.name
            },onError: { [weak self] error in
                debugPrint(error)
                guard let self = self else { return }
                self.router.route(to: .qrError, from: self)
        }).disposed(by: disposeBag)
    }
    
}
