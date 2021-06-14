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
import ExposureNotification
import Logging

protocol RadarStatusUseCase {
    func isTracingActive() -> Bool
    func changeTracingStatus(active: Bool) -> Observable<RadarStatus>
    func restoreLastStateAndSync() -> Observable<RadarStatus>
    func isTracingInit() -> Bool
}

class RadarStatusUseCaseImpl: RadarStatusUseCase {
    
    private let logger = Logger(label: "RadarStatusUseCase")
    
    private let preferencesRepository: PreferencesRepository
    private let syncUseCase: SyncUseCase
    
    init(preferencesRepository: PreferencesRepository,
         syncUseCase: SyncUseCase) {
        self.preferencesRepository = preferencesRepository
        self.syncUseCase = syncUseCase
    }
    
    func isTracingActive() -> Bool {
        preferencesRepository.isTracingActive()
    }
    
    func changeTracingStatus(active: Bool) -> Observable<RadarStatus> {
        .create { [weak self] observer in
            if active {
                DP3TTracing.startTracing { result in
                    switch result {
                    case .success():
                        self?.preferencesRepository.setTracing(active: active)
                        observer.onNext(.active)
                        observer.onCompleted()
                    case .failure(let error):
                        self?.handle(error: error, observer: observer)
                        observer.onCompleted()
                    }
                }
                
            } else {
                DP3TTracing.stopTracing { result in
                    switch result {
                    case .success():
                        self?.preferencesRepository.setTracing(active: active)
                        observer.onNext(.inactive)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError("Error stopping tracing. : \(error)")
                        observer.onCompleted()
                    }
                }
                
            }
            return Disposables.create()
        }
    }
    
    private func handle(error: Error, observer: AnyObserver<RadarStatus>) {
        if case .userAlreadyMarkedAsInfected = (error as? DP3TTracingError) {
            observer.onNext(.disabled)
            observer.onCompleted()
        } else {
            observer.onError(error)
            observer.onCompleted()
        }
    }
    
    func restoreLastStateAndSync() -> Observable<RadarStatus> {
        let isTracingActive = preferencesRepository.isTracingActive()
        logger.debug("restoreLastStateAndSync(): isTracingActive \(isTracingActive)")
        return changeTracingStatus(active: isTracingActive)
            .flatMap {[weak self] status -> Observable<RadarStatus> in
                self?.preferencesRepository.setTracing(initialized: true)
                if case .active = status {
                    return self?.syncUseCase.syncIfNeeded().map { status } ?? .empty()
                }
                return .just(status)
            }
    }
    
    func isTracingInit() -> Bool {
        preferencesRepository.isTracingInit()
    }
    
}
