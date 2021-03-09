//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import DP3TSDK
import Foundation
import ExposureNotification
import RxSwift
import Logging

class ExpositionUseCase: DP3TTracingDelegate {
    
    private let logger = Logger(label: "ExpositionUseCase")

    private let disposeBag = DisposeBag()
    private let dateFormatter = DateFormatter()

    private let subject: BehaviorSubject<ExpositionInfo>
    private let expositionInfoRepository: ExpositionInfoRepository
    private let notificationHandler: NotificationHandler
    private static let lastSyncKey = "ExpositionUseCase.lastSync"
    
    public var lastSync: Date? {
        get {
            return UserDefaults.standard.value(forKey: ExpositionUseCase.lastSyncKey) as? Date
        }
        set(val) {
            guard let date = val else {
                return
            }
            UserDefaults.standard.setValue(date, forKey: ExpositionUseCase.lastSyncKey)
        }
    }

    init(notificationHandler: NotificationHandler,
         expositionInfoRepository: ExpositionInfoRepository) {

        self.notificationHandler = notificationHandler
        self.expositionInfoRepository = expositionInfoRepository
        
        self.subject = BehaviorSubject<ExpositionInfo>(
            value: expositionInfoRepository.getExpositionInfo() ?? ExpositionInfo(level: .healthy)
        )

        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss.SSS z"
    }
    
    func DP3TTracingStateChanged(_ state: TracingState) {
        
        log(tracingState: state)
        
        var expositionInfo = tracingStatusToExpositionInfo(tStatus: state)

        let localEI = expositionInfoRepository.getExpositionInfo()

        if isNewInfected(localEI, expositionInfo) {
            expositionInfo.since = Date()
        }
        if showNotification(localEI, expositionInfo) {
            notificationHandler.scheduleNotification(expositionInfo: expositionInfo)
        }
        if expositionInfo.isOk() {
            expositionInfoRepository.save(expositionInfo: expositionInfo)
        }
        self.lastSync = expositionInfo.lastCheck

        subject.onNext(expositionInfo)
        
    }

    func getExpositionInfo() -> Observable<ExpositionInfo> {
        subject.asObservable()
    }

    func updateExpositionInfo() {
        let expositionInfo = tracingStatusToExpositionInfo(tStatus: DP3TTracing.status)
        self.lastSync = expositionInfo.lastCheck
        subject.onNext(expositionInfo)
    }

    // Metodo para mapear un TracingState a un ExpositionInfo
    private func tracingStatusToExpositionInfo(tStatus: TracingState) -> ExpositionInfo {
        
        switch tStatus.trackingState {
            case .inactive(let error):
                var errorEI = ExpositionInfo(level: expositionInfoRepository.getExpositionInfo()?.level ?? .healthy)
                errorEI.error = dp3tTracingErrorToDomain(error)
                return errorEI
            default: break
        }
        
        switch tStatus.infectionStatus {
            case .healthy:
                var info = ExpositionInfo(level: Level.healthy)
                info.lastCheck = tStatus.lastSync
                return info
            case .infected:
                let savedStatus = expositionInfoRepository.getExpositionInfo()?.level ?? Level.healthy
                var expositionInfo = ExpositionInfo(level: Level.infected)
                if savedStatus == Level.infected {
                    expositionInfo = expositionInfoRepository.getExpositionInfo() ?? ExpositionInfo(level: Level.infected)
                }
                if expositionInfo.since == nil {
                    expositionInfo.since = Date()
                }
                expositionInfoRepository.save(expositionInfo: expositionInfo)
                return expositionInfo
                
            case .exposed(days: let days):
                var info = ExpositionInfo(level: Level.exposed)
                info.since = getMoreRecentDateFromExpositionArray(days: days)
                info.lastCheck = tStatus.lastSync
                return info
        }
    }
    
    private func getMoreRecentDateFromExpositionArray(days: [ExposureDay]) -> Date? {
        return days.sorted { (d1, d2) -> Bool in
            return d1.exposedDate > d2.exposedDate
        }.first?.exposedDate
    }

    private func showNotification(_ localEI: ExpositionInfo?, _ expositionInfo: ExpositionInfo) -> Bool {
        if let localEI = localEI {
            return !equals(localEI, expositionInfo) && expositionInfo.level == .exposed
        }
        return false
    }

    private func equals(_ ei1: ExpositionInfo, _ ei2: ExpositionInfo) -> Bool {
        ei1.level == ei2.level && ei1.since == ei2.since
    }

    private func isNewInfected(_ localEI: ExpositionInfo?, _ expositionInfo: ExpositionInfo) -> Bool {
        if let localEI = localEI {
            return !equals(localEI, expositionInfo) && expositionInfo.level == .infected
        }
        return expositionInfo.level == .infected

    }

    private func dp3tTracingErrorToDomain(_ error: DP3TTracingError) -> DomainError? {
        switch error {
        case .bluetoothTurnedOff:
            return .bluetoothTurnedOff
        case .permissonError:
            return .notAuthorized
        case let .exposureNotificationError(error: enError as ENError):
            if enError.code == ENError.notAuthorized {
                return .notAuthorized
            }
            return nil
        default:
            return nil
        }

    }
    
    private func log(tracingState: TracingState) {
        logger.debug("New Tracing State --->")
        logger.debug("Status: \(tracingState.infectionStatus)")
        logger.debug("lastSync: \(String(describing: tracingState.lastSync))")
        logger.debug("tracingState \(tracingState.trackingState)")
        if case let .inactive(error) = tracingState.trackingState {
            logger.debug("Error: \(error)")
        }
        logger.debug("<---")
    }

}
