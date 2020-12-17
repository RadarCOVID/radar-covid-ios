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
import UIKit
import RxSwift

class AppInfoUseCase {

    private let appInfo: AppInformation
    
    init() {
        self.appInfo = AppInformation.init(version: "1.0.0", radarStatus: false, notificationStatus: false, bluetooth: false, lastSync: Date(), lastUpdate: Date(),so: "", model: "");
    }
    
    func getAppInfo() -> Observable<AppInformation> {
        return Observable.create { observer in
            
            //Version
            let bundleVersion = Config.version
            
            //Radar TODO
            let radarStatus:Bool = false
            
            //Bluetooth
            let bluetoothStatus:Bool = (UIApplication.shared.delegate as? AppDelegate)?.bluethoothUseCase?.getSatus() ?? false
            
            //LastSync TODO
            let lastSync: Date = Date()
            
            //LastUpdate TODO
            let lastUpdate: Date = Date()
            
            //Veresion
            let systemVersion = "\(UIDevice.current.systemName) (\(UIDevice.current.systemVersion))"
            
            //Model
            let model = UIDevice.modelName
            
            //Notification
            var notificationStatus: Bool = false
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { (settings) in
                if(settings.authorizationStatus == .authorized){
                    notificationStatus = true
                    observer.onNext(AppInformation.init(version: bundleVersion,
                                                        radarStatus: radarStatus,
                                                        notificationStatus: notificationStatus,
                                                        bluetooth: bluetoothStatus,
                                                        lastSync: lastSync,
                                                        lastUpdate: lastUpdate,
                                                        so: systemVersion,
                                                        model: model))
                }
            }
            
            observer.onNext(AppInformation.init(version: bundleVersion,
                                                radarStatus: radarStatus,
                                                notificationStatus: notificationStatus,
                                                bluetooth: bluetoothStatus,
                                                lastSync: lastSync,
                                                lastUpdate: lastUpdate,
                                                so: systemVersion,
                                                model: model))
            
            observer.onCompleted()
            
            return Disposables.create {
            }
        }
    }

}
