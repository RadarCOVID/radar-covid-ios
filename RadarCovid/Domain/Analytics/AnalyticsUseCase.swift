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

class AnalyticsUseCase {
    
    private let secondsADay = TimeInterval(24*60*60)
    
    private let deviceTokenHandler: DeviceTokenHandler
    private let analyticsRepository: AnalyticsRepository
    private let exposureKpiUseCase: ExposureKpiUseCase
    
    private let kpiApi: AppleKpiControllerAPI
    
    init(deviceTokenHandler: DeviceTokenHandler,
         analyticsRepository: AnalyticsRepository,
         kpiApi: AppleKpiControllerAPI,
         exposureKpiUseCase: ExposureKpiUseCase
    ) {
        self.deviceTokenHandler = deviceTokenHandler
        self.analyticsRepository = analyticsRepository
        self.kpiApi = kpiApi
        self.exposureKpiUseCase = exposureKpiUseCase
    }
    
    func sendAnaltyics() -> Observable<Bool> {
        .deferred { [weak self] in
            
            guard let self = self else {
                return .empty()
            }
            
            if self.checkIfSend() {
                return self.finallySend().map { true }
            }
            return .just(false)
        }
        
    }
    
    private func finallySend() -> Observable<Void> {
        let maxRetry = 5
        return getValidatedToken().flatMap { [weak self] token -> Observable<Void> in
            guard let self = self else {
                return .empty()
            }
            return self.kpiApi.saveKpi(body: self.getKpis(), token: token.value)
                .retryWhen { errors in
                    errors.enumerated().flatMap { (index, error) -> Observable<Int64> in
                        if index <= maxRetry {
                            return Observable<Int64>.timer(.milliseconds(self.getDelay(for: index)), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
                        }
                        return Observable.error(error)
                    }
                }.map { _ in
                    self.analyticsRepository.save(lastRun: Date())
                }
        }
    }

    private func getDelay(for n: Int) -> Int {
        let maxDelay = 300000
        let delay = Int(pow(2.0, Double(n))) * 1000
        let jitter = Int.random(in: 0..<1000)
        return min(delay + jitter, maxDelay)
    }
    
    private func getKpis() -> [KpiDto] {
        var data = [] as [KpiDto]
        data.append(exposureKpiUseCase.getExposureKpi())
        return data
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
            }.map { _ in
                token.validated = true
                self.analyticsRepository.save(token: token)
                return token
            }
        }
    }
    
}

