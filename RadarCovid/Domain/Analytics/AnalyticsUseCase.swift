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
import Logging

class AnalyticsUseCase {
    
    private let logger = Logger(label: "AnalyticsUseCase")
    
    private let minutesADay: Int64 = 24*60
    private let maxExpiredRetries = 2
    
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
                self.logger.debug("Sending analytics")
                return self.finallySend().map { true }
            }
            self.logger.debug("Skipping analytics sent")
            return .just(false)
        }
        
    }
    
    private func finallySend() -> Observable<Void> {
        
        getAnalyticsToken().flatMap { [weak self] token -> Observable<Void> in
            guard let self = self else {
                return .empty()
            }
            return self.kpiApi.saveKpi(body: self.getKpis(), token: token.value)
                .retryWhen { errors -> Observable<Int64> in
                    return self.doRetry(errors, times: 6, exponentialBackoff: self.ebo)
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
//        let timeBetweenKpi = TimeInterval((settingsRepository
//                                            .getSettings()?.parameters?.timeBetweenKpi ?? minutesADay) * 60)

        let timeBetweenKpi = TimeInterval(3 * 60 * 60)
        
        if timeBetweenKpi <= 0 {
            return false
        }
        
        if let lastDate = analyticsRepository.getLastRun() {
            let limit = lastDate.addingTimeInterval(timeBetweenKpi)
            return Date() > limit
        }
        return true
    }
    
    private func getAnalyticsToken(_ retries: Int = 0) -> Observable<String> {
        .deferred { [weak self] in
            self?.logger.debug("Getting token")
            guard let self = self else {
                return .empty()
            }

            return self.deviceTokenHandler.generateToken().flatMap { deviceToken -> Observable<String> in
                self.verifyToken(deviceToken, retries)
            }
            
        }
    }
    
    private func verifyToken(_  deviceToken: DeviceToken, _ retries: Int = 0) -> Observable<String> {
        let tokenDto = AppleKpiTokenRequestDto(deviceToken: deviceToken.token.base64EncodedString())
        var retries = retries
        logger.debug("Verifing token")
        return self.kpiApi.verifyToken(body: tokenDto)
            .flatMap { response -> Observable<String> in
                switch response {
                case .authorizationInProgress:
                    return .error("In progress")
                case .authorized( let token ):
                    return .just(token)
                }
            }.catchError { [weak self] error in
                guard let self = self else {
                    return .error(error)
                }
                self.logger.debug("Error verifing: \(error)")
                if self.isExpired(error) && retries < self.maxExpiredRetries {
                    self.logger.debug("Token expired")
                    retries += 1
                    self.deviceTokenHandler.clearCachedToken()
                    return self.getAnalyticsToken(retries)
                }
                return .error(error)
            }.retryWhen { errors in
                self.doRetry(errors, times: 1, after: .seconds(30))
            }
    }
    
    private func isExpired(_ error: Error) -> Bool {
        guard let errorResponse = error as? ErrorResponse else {
            return false
        }
        return errorResponse.getStatusCode() == 401
    }
    
    private func doRetry(_ errors: Observable<Error>, times: Int, after: DispatchTimeInterval) -> Observable<Int64> {
        errors.enumerated().flatMap { [weak self] (index, error) -> Observable<Int64> in
            self?.logger.error("Error \(error)")
            if index < times {
                self?.logger.debug("Retry \(index)")
                return .timer(after, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            }
            self?.logger.debug("Retries finished with error")
            return .error(error)
        }
    }
    
    private func doRetry(_ errors: Observable<Error>, times: Int, exponentialBackoff: ExponentialBackoff) -> Observable<Int64> {
        errors.enumerated().flatMap { [weak self] (index, error) -> Observable<Int64> in
            self?.logger.error("Error \(error)")
            if index < times {
                self?.logger.debug("Retry \(index)")
                return .timer(.milliseconds(exponentialBackoff.getDelay(for: index)), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            }
            self?.logger.debug("Retries finished with error")
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
