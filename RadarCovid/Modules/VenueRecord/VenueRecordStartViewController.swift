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

class VenueRecordStartViewController: BaseViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var router: AppRouter!
    var venueRecordUseCase : VenueRecordUseCase!
    
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var scanButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAccesibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        venueRecordUseCase.isCheckedIn().subscribe( onNext: { [weak self] checkedIn in
            guard let self = self else { return }
            if checkedIn {
                self.router.route(to: .checkedIn, from: self, parameters: true)
            }
        }).disposed(by: disposeBag)
    }
    
    @IBAction func onScanTap(_ sender: Any) {
        router.route(to: .qrScanner, from: self)
    }
    
    private func setupView() {
        
        scanButton.setTitle("VENUE_HOME_BUTTON_START".localized, for: .normal)
        
        listButton.layer.borderWidth = 1
        listButton.layer.borderColor = UIColor.deepLilac.cgColor
    }
    
    private func setupAccesibility() {
        scanButton.accessibilityLabel = "VENUE_HOME_BUTTON_START".localized
        scanButton.accessibilityHint = "ACC_HINT".localized
        scanButton.isAccessibilityElement = true
        
        listButton.isAccessibilityElement = true
        listButton.accessibilityLabel = "ACC_VENUE_HOME_PLACES".localized
        listButton.accessibilityHint = "ACC_HINT".localized
    }
}


extension VenueRecordStartViewController: AccTitleView {

    var accTitle: String? {
        get {
            "VENUE_HOME_TITLE".localized
        }
    }
}
