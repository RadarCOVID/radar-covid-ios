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
import BackgroundTasks

class BluethoothReminderUseCase: NSObject {
    
    var manager:CBCentralManager?
    
    private var notificationHandler: NotificationHandler?
    private var state: CBManagerState?

    func initListener() {
        stopScan()
        self.manager = CBCentralManager(delegate: self, queue: nil)
        self.notificationHandler = NotificationHandler()
    }
    
    func stopScan() {
        self.manager?.stopScan()
    }
    
    private func scheduleNotification(){
        self.notificationHandler?.scheduleNotification(
            title: "NOTIFICATIONS_INACTIVE_BLUETOOTH_TITLE".localized,
            body: "NOTIFICATIONS_INACTIVE_BLUETOOTH_BODY".localized,
            sound: .default)
    }
    
    func getSatus() -> Bool {
        switch state {
        case .poweredOn:
            return true
        default:
            return false
        }
    }
}

extension BluethoothReminderUseCase: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        state = central.state
        
        if central.state != .poweredOn  {
            self.scheduleNotification()
        }
    }
}
