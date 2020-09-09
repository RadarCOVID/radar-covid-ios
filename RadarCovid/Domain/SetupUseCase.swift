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

class SetupUseCase: LoggingDelegate, ActivityDelegate, DP3TBackgroundHandler {

    private let dateFormatter = DateFormatter()

    private let disposeBag = DisposeBag()

    private let preferencesRepository: PreferencesRepository
    private let notificationHandler: NotificationHandler
    private let expositionCheckUseCase: ExpositionCheckUseCase
    
    init(preferencesRepository: PreferencesRepository,
         notificationHandler: NotificationHandler,
         expositionCheckUseCase: ExpositionCheckUseCase) {
        
        self.preferencesRepository = preferencesRepository
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"

        self.notificationHandler = notificationHandler
        self.expositionCheckUseCase = expositionCheckUseCase
    }

    func initializeSDK() throws {

        let url = URL(string: Config.endpoints.dpppt)!
//        DP3TTracing.loggingEnabled = true
        DP3TTracing.loggingDelegate = self
        DP3TTracing.activityDelegate = self

        try! DP3TTracing.initialize(with: .init(appId: "es.gob.radarcovid",
                                                bucketBaseUrl: url,
                                                reportBaseUrl: url,
                                                jwtPublicKey: Config.dp3tValidationKey,
                                                mode: Config.dp3tMode), backgroundHandler: self)

    }

    func log(_ string: String, type: OSLogType) {
//        debugPrint(string)
    }

    func syncCompleted(totalRequest: Int, errors: [DP3TTracingError]) {
        debugPrint("DP3T Sync totalRequest \(totalRequest)")
        for error in errors {
            debugPrint("DP3T Sync error \(error)")
        }
        preferencesRepository.setLastSync(date: Date())
        
        expositionCheckUseCase.checkExposedToHealthy().subscribe(onError: { error in
            debugPrint("Error up checking exposed to healthy state \(error)")
        }, onCompleted: {
            debugPrint("Expostion Check completed")
        }).disposed(by: disposeBag)
    }

    func fakeRequestCompleted(result: Result<Int, DP3TNetworkingError>) {
        debugPrint("DP3T Fake request completed...")
    }

    func outstandingKeyUploadCompleted(result: Result<Int, DP3TNetworkingError>) {
        debugPrint("DP3T OutstandingKeyUpload...")
    }

    func exposureSummaryLoaded(summary: ENExposureDetectionSummary) {
        traceSummary(summary)
    }

    private func traceSummary(_ summary: ENExposureDetectionSummary ) {
        debugPrint("ENExposureDetectionSummary received")
        debugPrint("- daysSinceLastExposure: \(summary.daysSinceLastExposure)")
        debugPrint("- matchedKeyCount: \(summary.matchedKeyCount)")
        debugPrint("- maximumRiskScore: \(summary.maximumRiskScore)")
        debugPrint("- riskScoreSumFullRange: \(String(describing: summary.metadata?["riskScoreSumFullRange"]))")
    }

    func performBackgroundTasks(completionHandler: @escaping (Bool) -> Void) {
        debugPrint("performBackgroundTasks")
        if Config.debug {
            let sync = preferencesRepository.getLastSync()?.description ?? "no Sync"
            notificationHandler.scheduleNotification(title: "BackgroundTask", body: "Last sync: \(sync)", sound: .default)
        }
        completionHandler(true)
    }

    func didScheduleBackgrounTask() {
        debugPrint("didScheduleBackgrounTask")
    }

    private func mapInitializeError(_ error: Error) -> DomainError {
        if let e = error as? DP3TTracingError {
            debugPrint("Error \(e)")
        }

        return DomainError.Unexpected
    }

}
