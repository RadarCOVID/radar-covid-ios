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

class CheckedInViewController: VenueViewController {
    
    private let disposeBag = DisposeBag()
    
    private var currentVenue: VenueRecord?
    private var timer: Timer?
    
    var venueRecordUseCase: VenueRecordUseCase!
    
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var backgroundView: BackgroundView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAccesibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCurrentVenue()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    @IBAction func onBack(_ sender: Any) {
        router.route(to: .home, from: self)
    }
    
    override func finallyCanceled() {
        venueRecordUseCase.cancelCheckIn().subscribe(onNext: {
            super.finallyCanceled()
        }, onError: { [weak self] error in
            debugPrint(error)
            self?.showGenericError()
        }).disposed(by: disposeBag)
    }
    
    @IBAction func onCheckOutTap(_ sender: Any) {
        router.route(to: .checkOut, from: self)
    }
    
    private func setupView() {
        
        self.title = "VENUE_RECORD_CHECKIN_TITLE".localized
        
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.deepLilac.cgColor
        
        backgroundView.image = UIImage(named: "WhiteCard")
        
        confirmButton.setTitle("VENUE_RECORD_CHECKOUT_ACTION".localized, for: .normal)
        cancelButton.setTitle("ALERT_CANCEL_BUTTON".localized, for: .normal)
        
    }
    
    internal override func setupAccesibility() {
        super.setupAccesibility()
        
        confirmButton.accessibilityHint = "VENUE_RECORD_CHECKOUT_ACTION".localized
        confirmButton.accessibilityHint = "ACC_HINT".localized
        confirmButton.isAccessibilityElement = true
        
        cancelButton.isAccessibilityElement = true
        cancelButton.accessibilityHint = "ACC_BUTTON_ALERT_CANCEL".localized
    }
    
    private func loadCurrentVenue() {
        venueRecordUseCase.getCurrentVenue().subscribe(onNext: { [weak self] venue in
            if let venue = venue {
                self?.load(current: venue)
            }
        }, onError: { [weak self] error in
            debugPrint(error)
            self?.showGenericError()
        }).disposed(by: disposeBag)
    }
    
    private func load(current: VenueRecord) {
        currentVenue = current
        venueNameLabel.text = current.name
        updateTime()
        runUpdateTimer()
    }
    
    private func updateTime() {
        if let currentVenue = currentVenue {
            timeLabel.text = Date().timeIntervalSince(currentVenue.checkInDate).toFormattedString()
        }
    }
    
    private func runUpdateTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
    }
    
    
}

extension CheckedInViewController: AccTitleView {

    var accTitle: String? {
        get {
            "VENUE_RECORD_CHECKIN_TITLE".localized
        }
    }
}
