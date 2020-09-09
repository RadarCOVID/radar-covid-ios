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

class RadarStatusUseCase {

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
                do {
                    try DP3TTracing.startTracing { error in
                        if let error =  error {
                            self?.handle(error: error, observer: observer)
                        } else {
                            self?.preferencesRepository.setTracing(active: active)
                            observer.onNext(.active)
                            observer.onCompleted()
                        }
                    }

                } catch {
                    self?.handle(error: error, observer: observer)
                }

            } else {
                DP3TTracing.stopTracing { error in
                    if let error =  error {
                        observer.onError("Error stopping tracing. : \(error)")
                    } else {
                        self?.preferencesRepository.setTracing(active: active)
                        observer.onNext(.inactive)
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
        }
    }

    func restoreLastStateAndSync() -> Observable<RadarStatus> {
        changeTracingStatus(active: preferencesRepository.isTracingActive()).flatMap { [weak self] status -> Observable<RadarStatus> in
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

