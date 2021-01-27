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
class AnalyticsUseCase {
    
    private let secondsADay = TimeInterval(24*60*60)
    
    private let expositionInfoRepository: ExpositionInfoRepository
    private let deviceTokenHandler: DeviceTokenHandler
    private let analyticsRepository: AnalyticsRepository
    
    private let analyticsAPI = AnalyticsAPI()
    
    init(expositionInfoRepository: ExpositionInfoRepository, deviceTokenHandler: DeviceTokenHandler, analyticsRepository: AnalyticsRepository) {
        self.expositionInfoRepository = expositionInfoRepository
        self.deviceTokenHandler = deviceTokenHandler
        self.analyticsRepository = analyticsRepository
    }
    
    func sendExposureAnaltyics() -> Observable<Void> {
        .deferred {
            if checkIfSend() {
                
            }
            return .just(Void())
        }
        
        
        var exposed = "0"
        var date : Date? = nil
        if let expositionInfo = expositionInfoRepository.getExpositionInfo() {
            if case .exposed = expositionInfo.level {
                exposed = "1"
                date = expositionInfo.since
            }
        }
        
        let kpi: Kpi = Kpi(kpi: "MATCH_CONFIRMED", timestamp: date, value: exposed)
        let data = AnalyticsData(kpis: [kpi])
        
        return getValidatedToken().flatMap { [weak self] token -> Observable<Void> in
            self?.analyticsAPI.sendKpis(data: data).map { _ in Void() } ?? .empty()
        }
        
    }
    
    private func finallySend(data: Any) {
        
    }
    
    private func checkIfSend() -> Bool {
        if let lastDate = analyticsRepository.getLastRun() {
            let limit = lastDate.addingTimeInterval(secondsADay)
            return Date() > limit
        }
        return true
    }
    
    private func getAnalyticsToken() -> AnalyticsToken {

        if let token = analyticsRepository.getToken(), !token.isExpired() {
            return token
        }
        let token = AnalyticsToken.generateNew()
        analyticsRepository.save(token: token)
        return token
        
    }
    
    private func getValidatedToken() -> Observable<AnalyticsToken> {
        .deferred { [weak self] in
            guard let token = self?.getAnalyticsToken() else {
                return .empty()
            }
            if (token.validated) {
                return .just(token)
            }
            return self?.deviceTokenHandler.generateToken().flatMap {  deviceToken -> Observable<Bool> in
                self?.analyticsAPI.validateToken(analytics: token.value, device: deviceToken) ?? .empty()
            }.map { valid in
                token
            } ?? .empty()
        }
    }
    
}

class AnalyticsAPI {
    func validateToken(analytics: String, device: Data) -> Observable<Bool> {
         .just(true)
    }
    
    func sendKpis(data: AnalyticsData) -> Observable<AnalyticsData> {
        .just(data)
    }
}

struct Kpi {
    var kpi: String?
    var timestamp: Date?
    var value: String?
}

struct AnalyticsData {
    var kpis: [Kpi]
}
