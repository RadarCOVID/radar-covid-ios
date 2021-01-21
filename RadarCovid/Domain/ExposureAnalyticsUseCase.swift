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
import RxSwift

/*
 - Para llamar al servicio final se requiere obtener previamente un "analiticsToken"
 - Para obtener este token se obtiene el device token y se llama un servicio
 - Este servicio devolverá el mismo "analiticsToken" durante un mes (cacheado en redis). Pedirlo si no lo tienes y si lo tienes comprobar la antiguedad y pedirlo de nuevo
 - Finalmente llamar al servicio con el dato de exposición
 */
class ExposureAnalyticsUseCase {
    
    private let expositionInfoRepository: ExpositionInfoRepository
    
    private let deviceTokenHandler: DeviceTokenHandler
    
    init(expositionInfoRepository: ExpositionInfoRepository, deviceTokenHandler: DeviceTokenHandler) {
        self.expositionInfoRepository = expositionInfoRepository
        self.deviceTokenHandler = deviceTokenHandler
    }
    
    func sendExposureAnaltyics(data: Any) -> Observable<Void> {
        
        var exposed = "0"
        var date : Date? = nil
        if let expositionInfo = expositionInfoRepository.getExpositionInfo() {
            if case .exposed = expositionInfo.level {
                exposed = "1"
                date = expositionInfo.since
            }
        }
        
        var kpi: Kpi = Kpi(kpi: "MATCH_CONFIRMED", timestamp: date, value: exposed)
        
        deviceTokenHandler.generateToken()
        
        return .just(())
        
    }
    

    
}

struct Kpi {
    var kpi: String?
    var timestamp: Date?
    var value: String?
}
