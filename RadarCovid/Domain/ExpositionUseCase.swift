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
import RxSwift

class ExpositionUseCase: DP3TTracingDelegate {

    private let disposeBag = DisposeBag()
    private let dateFormatter = DateFormatter()

    private let subject: BehaviorSubject<ExpositionInfo>
    private let expositionInfoRepository: ExpositionInfoRepository
    private let notificationHandler: NotificationHandler

    init(notificationHandler: NotificationHandler,
         expositionInfoRepository: ExpositionInfoRepository) {

        self.notificationHandler = notificationHandler
        self.expositionInfoRepository = expositionInfoRepository
        self.subject = BehaviorSubject<ExpositionInfo>(
            value: expositionInfoRepository.getExpositionInfo() ?? ExpositionInfo(level: .healthy)
        )

        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss.SSS z"

        DP3TTracing.delegate = self

    }

    func DP3TTracingStateChanged(_ state: TracingState) {

        if var expositionInfo = tracingStatusToExpositionInfo(tStatus: state) {

            let localEI  = expositionInfoRepository.getExpositionInfo()

            if isNewInfected(localEI, expositionInfo) {
                expositionInfo.since = Date()
            }
            if showNotification(localEI, expositionInfo) {
                notificationHandler.scheduleNotification(expositionInfo: expositionInfo)
            }
            if expositionInfo.error == nil {
                expositionInfoRepository.save(expositionInfo: expositionInfo)
            }

            subject.onNext(expositionInfo)
        }
    }

    func getExpositionInfo() -> Observable<ExpositionInfo> {
        subject.asObservable()
    }

    func getExpositionInfoFromRepository() -> ExpositionInfo! {
        return expositionInfoRepository.getExpositionInfo() ?? ExpositionInfo(level: .healthy)
    }

    func updateExpositionInfo() {

        DP3TTracing.status { result in
            switch result {
            case let .success(state):
                if let eis = tracingStatusToExpositionInfo(tStatus: state) {
                    subject.onNext(eis)
                }
            case .failure:
                subject.onError("Error retrieving exposition status")
            }
        }

    }

    // Metodo para mapear un TracingState a un ExpositionInfo
    private func tracingStatusToExpositionInfo(tStatus: TracingState) -> ExpositionInfo? {

        switch tStatus.trackingState {
        case .inactive(let error):
            var errorEI = ExpositionInfo(level: expositionInfoRepository.getExpositionInfo()?.level ?? .healthy)
            errorEI.error = dp3tTracingErrorToDomain(error)
            return errorEI
        default: break
        }

        switch tStatus.infectionStatus {
        case .healthy:
            var info = ExpositionInfo(level: ExpositionInfo.Level.healthy)
            info.lastCheck = tStatus.lastSync
            return info
        case .infected:
            return ExpositionInfo(level: ExpositionInfo.Level.infected)
        case .exposed(days: let days):
            var info = ExpositionInfo(level: ExpositionInfo.Level.exposed)
            info.since = days.first?.exposedDate
            info.lastCheck = tStatus.lastSync
            return info
        }
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
            return .BluetoothTurnedOff
        case .permissonError:
            return .NotAuthorized
        default:
            debugPrint("Error State \(error)")
            return nil
        }
    }

}
