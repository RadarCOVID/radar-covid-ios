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


protocol BackgroundTasksUseCase {
    func runTasks() -> Observable<Void>
}

class BackgroundTasksUseCaseImpl: BackgroundTasksUseCase {
    
    private let logger = Logger(label: "BackgroundTasksUseCase")
    private let disposeBag = DisposeBag()
    
    private let analyticsUseCase: AnalyticsUseCase
    private let fakeRequestUseCase: FakeRequestUseCase
    private let expositionCheckUseCase: ExpositionCheckUseCase
    private let configurationUseCase: ConfigurationUseCase
    private let checkInInprogressUseCase: CheckInInProgressUseCase
    private let problematicEventsUseCase: ProblematicEventsUseCase
    
    init(analyticsUseCase: AnalyticsUseCase, fakeRequestUseCase: FakeRequestUseCase, expositionCheckUseCase: ExpositionCheckUseCase, checkInInprogressUseCase: CheckInInProgressUseCase, configurationUseCase: ConfigurationUseCase, problematicEventsUseCase: ProblematicEventsUseCase) {
        self.analyticsUseCase = analyticsUseCase
        self.fakeRequestUseCase = fakeRequestUseCase
        self.expositionCheckUseCase = expositionCheckUseCase
        self.configurationUseCase = configurationUseCase
        self.checkInInprogressUseCase = checkInInprogressUseCase
        self.problematicEventsUseCase = problematicEventsUseCase
    }
    
    
    func runTasks() -> Observable<Void> {
        logger.debug("Running Background Tasks...")
        return configurationUseCase.loadConfig()
            .catchError { [weak self] error in
                self?.logger.error("Error loading config \(error.localizedDescription)")
                return .just(Settings())
            }.flatMap { [weak self] _  -> Observable<Void> in
            guard let self = self else { return .empty() }
            return .zip(self.callBackToHealthy(),
                        self.callSendAnalytics(),
                        self.callFakeRequest(),
                        self.callVenueRecordTasks()) { backToHealthy, analyticsSent, fakeSent, venueRecord in
                 self.logger.debug("Analytics sent:\(analyticsSent)")
                 self.logger.debug("Expostion Check, back to healthy \(backToHealthy)")
                 self.logger.debug("Fake Sent: \(fakeSent)")
                 self.logger.debug("Venue management done: \(venueRecord)")
                 return Void()
            }
        }
    }
    
    private func callBackToHealthy() -> Observable<Bool> {
        expositionCheckUseCase.checkBackToHealthy().catchError { [weak self] error in
            self?.logger.error("Error checking exposed to healthy state \(error.localizedDescription)")
            return .just(false)
        }
    }
    
    private func callSendAnalytics() -> Observable<Bool> {
        analyticsUseCase.sendAnaltyics().catchError { [weak self] error in
            self?.logger.error("Error sending analytics: \(error.localizedDescription)")
            return .just(false)
        }
    }
    
    private func callFakeRequest() -> Observable<Bool> {
        fakeRequestUseCase.sendFalsePositiveFromBackgroundDP3T().catchError { [weak self] error in
            self?.logger.error("Error sending fake: \(error.localizedDescription)")
            return .just(false)
        }
    }
    
    private func callVenueRecordTasks() -> Observable<Bool> {
        .deferred { [weak self] in
            guard let self = self else { return .empty() }
            var errorFound: Bool = false
            return self.checkInInprogressUseCase.checkStauts().catchError { error in
                self.logger.error("Error checking venue status: \(error.localizedDescription)")
                errorFound = true
                return .just(Void())
            }.flatMap { () -> Observable<Void> in
                self.problematicEventsUseCase.sync().catchError { error in
                    self.logger.error("Error syncing problematic events: \(error.localizedDescription)")
                    errorFound = true
                    return .just(Void())
                }
            }.map { errorFound }
        }
    }
    
    
}
