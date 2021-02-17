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


class BackgroundTasksUseCase {
    
    private let logger = Logger(label: "BackgroundTasksUseCase")
    private let disposeBag = DisposeBag()
    
    private let analyticsUseCase: AnalyticsUseCase
    private let fakeRequestUseCase: FakeRequestUseCase
    private let expositionCheckUseCase: ExpositionCheckUseCase
    
    init(analyticsUseCase: AnalyticsUseCase, fakeRequestUseCase: FakeRequestUseCase, expositionCheckUseCase: ExpositionCheckUseCase) {
        self.analyticsUseCase = analyticsUseCase
        self.fakeRequestUseCase = fakeRequestUseCase
        self.expositionCheckUseCase = expositionCheckUseCase
    }
    
    
    func runTasks() -> Observable<Void> {
        
        .zip(callBackToHealthy(),
             callSendAnalytics(),
             callFakeRequest())
        { [weak self] analyticsSent, backToHealthy, fakeSent in
            self?.logger.debug("Analytics sent:\(analyticsSent)")
            self?.logger.debug("Expostion Check, back to healthy \(backToHealthy)")
            self?.logger.debug("Fake Sent: \(fakeSent)")
            return Void()
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
    
}
