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
    
    private let deviceTokenHandler: DeviceTokenHandler
    private let analyticsRepository: AnalyticsRepository
    
    private let kpiApi: AppleKpiControllerAPI
    
    init(deviceTokenHandler: DeviceTokenHandler,
         analyticsRepository: AnalyticsRepository,
         kpiApi: AppleKpiControllerAPI
    ) {
        self.deviceTokenHandler = deviceTokenHandler
        self.analyticsRepository = analyticsRepository
        self.kpiApi = kpiApi
        
    }
    
    func sendAnaltyics() -> Observable<Void> {
        .deferred { [weak self] in
            
            guard let self = self else {
                return .just(Void())
            }
            
            if self.checkIfSend() {
                return self.finallySend()
            }
            return .just(Void())
        }
        
    }
    
    private func finallySend() -> Observable<Void> {
        
        let data = [] as [KpiDto]
        
        return getValidatedToken().flatMap { [weak self] token -> Observable<Void> in
            self?.kpiApi.saveKpi(body: data, token: token.value).map { _ in Void() } ?? .empty()
        }
        
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
            
            guard let self = self else {
                return .empty()
            }
            
            var token = self.getAnalyticsToken()
            
            if (token.validated) {
                return .just(token)
            }
            return self.deviceTokenHandler.generateToken().flatMap {  deviceToken -> Observable<Void> in
                self.kpiApi.verifyToken(body: AppleKpiTokenDto(kpiToken: token.value,
                                                               deviceToken: deviceToken.base64EncodedString()))
            }.map { [weak self] _ in
                token.validated = true
                self?.analyticsRepository.save(token: token)
                return token
            }
        }
    }
    
}

