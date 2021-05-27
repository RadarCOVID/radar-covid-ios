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

protocol ExpositionUseCase {
    var lastSync: Date? { get }
    func getExpositionInfo() -> Observable<ExpositionInfo>
    func updateExpositionInfo()
}

class ExpositionUseCaseImpl: ExpositionUseCase, DP3TTracingDelegate {
    
    private let logger = Logger(label: "ExpositionUseCase")

    private let disposeBag = DisposeBag()
    private let dateFormatter = DateFormatter()

    private let subject: BehaviorSubject<ContactExpositionInfo>
    private let expositionInfoRepository: ExpositionInfoRepository
    private let notificationHandler: NotificationHandler
    private let venueExpositionUseCase: VenueExpositionUseCase
    private let exposureRecordRepository: ExposureRecordRepository
    
    private static let lastSyncKey = "ExpositionUseCase.lastSync"
    
    public var lastSync: Date? {
        get {
            return UserDefaults.standard.value(forKey: ExpositionUseCaseImpl.lastSyncKey) as? Date
        }
        set(val) {
            guard let date = val else {
                return
            }
            UserDefaults.standard.setValue(date, forKey: ExpositionUseCaseImpl.lastSyncKey)
        }
    }

    init(notificationHandler: NotificationHandler,
         expositionInfoRepository: ExpositionInfoRepository,
         venueExpositionUseCase: VenueExpositionUseCase,
         exposureRecordRepository: ExposureRecordRepository) {
        

        self.notificationHandler = notificationHandler
        self.expositionInfoRepository = expositionInfoRepository
        self.venueExpositionUseCase = venueExpositionUseCase
        self.exposureRecordRepository = exposureRecordRepository
        
        self.subject = BehaviorSubject<ContactExpositionInfo>(
            value: expositionInfoRepository.getExpositionInfo() ?? ContactExpositionInfo(level: .healthy)
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
            exposureRecordRepository.addExposure(exposureInfo: expositionInfo)
            notificationHandler.scheduleNotification(expositionInfo: expositionInfo)
        } else {
            logger.debug("Discarding Notification")
        }
        
        if expositionInfo.isOk() || expositionInfo.level == .healthy {
            logger.debug("Saving ExpositionInfo: \(expositionInfo)")
            expositionInfoRepository.save(expositionInfo: expositionInfo)
        }
        self.lastSync = expositionInfo.lastCheck

        subject.onNext(expositionInfo)
        
    }

    func getExpositionInfo() -> Observable<ExpositionInfo> {
        .zip(subject.asObservable() , venueExpositionUseCase.expositionInfo, resultSelector: { cei, vei in
                ExpositionInfo(contact: cei, venue: vei)
        })
    }

    func updateExpositionInfo() {
        let expositionInfo = tracingStatusToExpositionInfo(tStatus: DP3TTracing.status)
        self.lastSync = expositionInfo.lastCheck
        subject.onNext(expositionInfo)
    }
    
    

    private func tracingStatusToExpositionInfo(tStatus: TracingState) -> ContactExpositionInfo {
        
        switch tStatus.trackingState {
            case .inactive(let error):
                var errorEI = ContactExpositionInfo(level: expositionInfoRepository.getExpositionInfo()?.level ?? .healthy)
                errorEI.error = dp3tTracingErrorToDomain(error)
                return errorEI
            default: break
        }
        
        switch tStatus.infectionStatus {
            case .healthy:
                var info = ContactExpositionInfo(level: Level.healthy)
                info.lastCheck = tStatus.lastSync
                return info
            case .infected:
                let savedStatus = expositionInfoRepository.getExpositionInfo()?.level ?? Level.healthy
                var expositionInfo = ContactExpositionInfo(level: Level.infected)
                if savedStatus == Level.infected {
                    expositionInfo = expositionInfoRepository.getExpositionInfo() ?? ContactExpositionInfo(level: Level.infected)
                }
                if expositionInfo.since == nil {
                    expositionInfo.since = Date()
                }
                expositionInfoRepository.save(expositionInfo: expositionInfo)
                return expositionInfo
                
            case .exposed(days: let days):
                var info = ContactExpositionInfo(level: Level.exposed)
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

    private func showNotification(_ localEI: ContactExpositionInfo?, _ expositionInfo: ContactExpositionInfo) -> Bool {
        logger.debug("ShowNotification? localEi: \(String(describing: localEI)) expositionInfo: \(expositionInfo) ")
        if let localEI = localEI {
            return expositionInfo.since != nil && !equals(localEI, expositionInfo) && expositionInfo.level == .exposed
        }
        return false
    }

    private func equals(_ ei1: ContactExpositionInfo, _ ei2: ContactExpositionInfo) -> Bool {
        ei1.level == ei2.level && ei1.since == ei2.since
    }

    private func isNewInfected(_ localEI: ContactExpositionInfo?, _ expositionInfo: ContactExpositionInfo) -> Bool {
        if let localEI = localEI {
            return expositionInfo.since != nil && !equals(localEI, expositionInfo) && expositionInfo.level == .infected
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
