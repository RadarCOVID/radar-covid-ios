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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
        listButton.layer.borderWidth = 1
        listButton.layer.borderColor = UIColor.deepLilac.cgColor
    }
}
