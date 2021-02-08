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
import ExposureNotification
import DP3TSDK
import RxSwift
import Logging

class SetupUseCase: LoggingDelegate, ActivityDelegate, DP3TBackgroundHandler {
    
    private let dateFormatter = DateFormatter()
    
    private let disposeBag = DisposeBag()
    
    private let logger = Logger(label: "SetupUseCase")
    
    private let preferencesRepository: PreferencesRepository
    private let notificationHandler: NotificationHandler
    private let expositionCheckUseCase: ExpositionCheckUseCase
    private let fakeRequestUseCase: FakeRequestUseCase
    private let analyticsUseCase: AnalyticsUseCase
    
    init(preferencesRepository: PreferencesRepository,
         notificationHandler: NotificationHandler,
         expositionCheckUseCase: ExpositionCheckUseCase,
         fakeRequestUseCase: FakeRequestUseCase,
         analyticsUseCase: AnalyticsUseCase ) {
        
        self.preferencesRepository = preferencesRepository
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        self.notificationHandler = notificationHandler
        self.expositionCheckUseCase = expositionCheckUseCase
        self.fakeRequestUseCase = fakeRequestUseCase
        self.analyticsUseCase = analyticsUseCase
    }
    
    func initializeSDK() throws {
        
        let url = URL(string: Config.endpoints.dpppt)!
        
        DP3TTracing.loggingEnabled = true
        
        DP3TTracing.loggingDelegate = self
        DP3TTracing.activityDelegate = self
        
        DP3TTracing.initialize(with: .init(appId: "es.gob.radarcovid",
                                           bucketBaseUrl: url,
                                           reportBaseUrl: url,
                                           jwtPublicKey: Config.dp3tValidationKey,
                                           mode: Config.dp3tMode), backgroundHandler: self)
    }
    
    func log(_ string: String, type: OSLogType) {
        logger.debug("\(string)")
    }
    
    func syncCompleted(totalRequest: Int, errors: [DP3TTracingError]) {
        logger.debug("DP3T Sync totalRequest \(totalRequest)")
        for error in errors {
            logger.error("DP3T Sync error \(error)")
        }
        preferencesRepository.setLastSync(date: Date())
        
        expositionCheckUseCase.checkBackToHealthy().subscribe(onError: { [weak self] error in
            self?.logger.error("Error up checking exposed to healthy state \(error)")
        }, onCompleted: { [weak self] in
            self?.logger.debug("Expostion Check completed")
        }).disposed(by: disposeBag)
    }
    
    func fakeRequestCompleted(result: Result<Int, DP3TNetworkingError>) {
        logger.debug("DP3T Fake request completed...")
    }
    
    func outstandingKeyUploadCompleted(result: Result<Int, DP3TNetworkingError>) {
        logger.debug("DP3T OutstandingKeyUpload...")
    }
    
    func exposureSummaryLoaded(summary: ENExposureDetectionSummary) {
        traceSummary(summary)
    }
    
    private func traceSummary(_ summary: ENExposureDetectionSummary ) {
        logger.debug("ENExposureDetectionSummary received")
        logger.debug("- daysSinceLastExposure: \(summary.daysSinceLastExposure)")
        logger.debug("- matchedKeyCount: \(summary.matchedKeyCount)")
        logger.debug("- maximumRiskScore: \(summary.maximumRiskScore)")
        logger.debug("- riskScoreSumFullRange: \(String(describing: summary.metadata?["riskScoreSumFullRange"]))")
    }
    
    func performBackgroundTasks(completionHandler: @escaping (Bool) -> Void) {
        
        logger.debug("performBackgroundTasks")
        
        DP3TTracing.delegate = AppDelegate.shared?.injection.resolve(ExpositionUseCase.self)
        logger.debug("DP3TTracing.delegate \(String(describing: DP3TTracing.delegate))")
        
        if Config.debug {
            let sync = preferencesRepository.getLastSync()?.description ?? "no Sync"
            self.notificationHandler.scheduleNotification(
                title: "BackgroundTask",
                body: "Last sync: \(sync)",
                sound: .default)
        }
        
        fakeRequestUseCase.sendFalsePositiveFromBackgroundDP3T()
        
        analyticsUseCase.sendAnaltyics()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [weak self] sent in
                self?.logger.debug("Analytics sent:\(sent)")
            }, onError: { [weak self] error in
                self?.logger.debug("Error sending analytics: \(error)")
                self?.logger.debug("Error: \(error.localizedDescription)")
            }).disposed(by: disposeBag)

        completionHandler(true)
    }
    
    func didScheduleBackgrounTask() {
        debugPrint("didScheduleBackgrounTask")
    }
    
    private func mapInitializeError(_ error: Error) -> DomainError {
        if let dpt3Error = error as? DP3TTracingError {
            debugPrint("Error \(dpt3Error)")
        }
        
        return DomainError.unexpected
    }
    
}

