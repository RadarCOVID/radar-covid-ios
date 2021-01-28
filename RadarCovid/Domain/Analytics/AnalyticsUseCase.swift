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
    
    private let minutesADay: Int64 = 24*60
    
    private let deviceTokenHandler: DeviceTokenHandler
    private let analyticsRepository: AnalyticsRepository
    private let exposureKpiUseCase: ExposureKpiUseCase
    private let settingsRepository: SettingsRepository
    
    private let kpiApi: AppleKpiControllerAPI
    
    private let ebo = ExponentialBackoff()
    
    init(deviceTokenHandler: DeviceTokenHandler,
         analyticsRepository: AnalyticsRepository,
         kpiApi: AppleKpiControllerAPI,
         exposureKpiUseCase: ExposureKpiUseCase,
         settingsRepository: SettingsRepository
    ) {
        self.deviceTokenHandler = deviceTokenHandler
        self.analyticsRepository = analyticsRepository
        self.kpiApi = kpiApi
        self.exposureKpiUseCase = exposureKpiUseCase
        self.settingsRepository = settingsRepository
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
        
        return getValidatedToken().flatMap { [weak self] token -> Observable<Void> in
            guard let self = self else {
                return .empty()
            }
            return self.kpiApi.saveKpi(body: self.getKpis(), token: token.value)
                .retryWhen { errors in
                    self.doRetry(errors, times: 6, exponentialBackoff: self.ebo)
                }.map { _ in
                    self.analyticsRepository.save(lastRun: Date())
                }
        }
    }
    
    private func getKpis() -> [KpiDto] {
        var data = [] as [KpiDto]
        data.append(exposureKpiUseCase.getExposureKpi())
        return data
    }
    
    private func checkIfSend() -> Bool {
        let timeBetweenKpi = TimeInterval((settingsRepository
                                            .getSettings()?.parameters?.timeBetweenKpi ?? minutesADay) * 60)
        if let lastDate = analyticsRepository.getLastRun() {
            let limit = lastDate.addingTimeInterval(timeBetweenKpi)
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
            
            if token.validated {
                return .just(token)
            }
            return self.deviceTokenHandler.generateToken().flatMap { deviceToken -> Observable<Void> in
                self.verifyToken(AppleKpiTokenDto(kpiToken: token.value,
                                             deviceToken: deviceToken.base64EncodedString()))
            }.map { _ in
                token.validated = true
                self.analyticsRepository.save(token: token)
                return token
            }
            
        }
    }
    
    private func verifyToken(_ tokenDto: AppleKpiTokenDto) -> Observable<Void> {
        self.kpiApi.verifyToken(body: tokenDto)
            .flatMap { response -> Observable<Void> in
                if case .authorizationInProgress = response {
                    return .error("In progress")
                }
                return .just(Void())
            }.retryWhen { errors in
                self.doRetry(errors, times: 1, after: .seconds(30))
            }
    }
    
    private func doRetry(_ errors: Observable<Error>, times: Int, after: DispatchTimeInterval) -> Observable<Int64> {
        errors.enumerated().flatMap { (index, error) -> Observable<Int64> in
            if index < times {
                return .timer(after, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            }
            return .error(error)
        }
    }
    
    private func doRetry(_ errors: Observable<Error>, times: Int, exponentialBackoff: ExponentialBackoff) -> Observable<Int64> {
        errors.enumerated().flatMap { (index, error) -> Observable<Int64> in
            if index < times {
                return .timer(.milliseconds(exponentialBackoff.getDelay(for: index)), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            }
            return .error(error)
        }
    }
    

}

class ExponentialBackoff {
    
    private let maxDelay: Int
    private let minDelay: Int
    private let base: Double
    
    init(base: Double = 2.0, minDelay: Int = 1000, maxDelay: Int = 300000) {
        self.maxDelay = maxDelay
        self.minDelay = minDelay
        self.base = Double(base)
    }
    
    func getDelay(for n: Int) -> Int {
        let delay = Int(pow(base, Double(n))) * minDelay
        let jitter = Int.random(in: 0..<minDelay)
        return min(delay + jitter, maxDelay)
    }
}
