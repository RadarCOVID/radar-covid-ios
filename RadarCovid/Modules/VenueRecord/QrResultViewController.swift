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

class QrResultViewController: VenueViewController {
    
    private let disposeBag = DisposeBag()
    
    var venueRecordUseCase: VenueRecordUseCase!
    
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueView: BackgroundView!
    @IBOutlet weak var confirmButton: UIButton!
    
    var qrCode: String?
    var venueRecord: VenueRecord?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAccesibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadVenueInfo()
    }
    
    @IBAction func onConfirmTap(_ sender: Any) {
        if var venueRecord = venueRecord {
            venueRecord.checkInDate = Date()
            venueRecordUseCase.checkIn(venue: venueRecord).subscribe(
                onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.router.route(to: .checkedIn, from: self)
                },onError: { [weak self] error in
                    debugPrint(error.localizedDescription)
                    self?.showGenericError()
            }).disposed(by: disposeBag)
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        onCancel(sender)
    }

    private func setupView() {
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.deepLilac.cgColor
        venueView.image = UIImage(named: "WhiteCard")
        
        confirmButton.setTitle("VENUE_RECORD_CHECKIN_ACTION".localized, for: .normal)
        cancelButton.setTitle("ACC_BUTTON_CLOSE".localized, for: .normal)
    }
    
    private func loadVenueInfo() {
        if let venueRecord = venueRecord {
            loadVenueInfo(venue: venueRecord)
        } else {
            venueRecordUseCase.getVenueInfo(qrCode: qrCode ?? "").subscribe(
                onNext: { [weak self] venueRecord in
                    self?.venueRecord = venueRecord
                    self?.loadVenueInfo(venue: venueRecord)
                },onError: { [weak self] error in
                    debugPrint(error)
                    guard let self = self else { return }
                    self.router.route(to: .qrError, from: self)
            }).disposed(by: disposeBag)
        }
    }
    
    private func loadVenueInfo(venue: VenueRecord) {
        venueNameLabel.text = venue.name
    }
    
    override func setupAccesibility() {
        super.setupAccesibility()
        confirmButton.accessibilityHint = "VENUE_RECORD_CHECKIN_ACTION".localized
        confirmButton.accessibilityHint = "ACC_HINT".localized
        confirmButton.isAccessibilityElement = true
        
        cancelButton.isAccessibilityElement = true
        cancelButton.accessibilityHint = "ACC_BUTTON_ALERT_CANCEL".localized
    }
    
}

extension QrResultViewController: AccTitleView {

    var accTitle: String? {
        get {
            "VENUE_RECORD_CAPTURED_CODE_TITLE".localized
        }
    }
}
