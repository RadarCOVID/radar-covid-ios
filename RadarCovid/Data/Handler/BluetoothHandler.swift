//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import Foundation
import CoreBluetooth
import RxSwift

protocol BluetoothHandler {
    func isActive() -> Observable<Bool>
}

class CentralManagerBluetoothHandler: NSObject, BluetoothHandler, CBCentralManagerDelegate {

    private let subject = PublishSubject<Bool>()

    var centralManager: CBCentralManager?

    func isActive() -> Observable<Bool> {
//        .deferred { [weak self] in
//            self?.centralManager = CBCentralManager(delegate: self, queue: nil)
//            return self?.subject.asObservable() ?? .empty()
//        }
        .just(true)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        var active: Bool = false

        switch central.state {

        case .unauthorized:
            switch CBCentralManager.authorization {
                case .allowedAlways:
                    active = false
                case .denied:
                    active = false
                case .restricted:
                    active = false
                case .notDetermined:
                    active = false
                @unknown default:
                   active = false
                }
        case .unknown:
            active = false
        case .unsupported:
            active = false
        case .poweredOn:
            active = true
        case .poweredOff:
            active = false
        case .resetting:
            active = false
        @unknown default:
            active = false
        }

        subject.onNext(active)

    }

}
