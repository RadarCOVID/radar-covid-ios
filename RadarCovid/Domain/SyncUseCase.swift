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
import ExposureNotification
import DP3TSDK

class SyncUseCase {

    // Force sync if last sync was older than 12 hours
    private let syncInterval: TimeInterval = 12 * 60 * 60

    private let preferencesRepository: PreferencesRepository

    init(preferencesRepository: PreferencesRepository) {
        self.preferencesRepository = preferencesRepository
    }

    func syncIfNeeded() -> Observable<Void> {
        .deferred { [weak self] in
            if let lastSync = self?.preferencesRepository.getLastSync(), let syncInterval = self?.syncInterval {
                if (-lastSync.timeIntervalSinceNow) > syncInterval {
                    return self?.forceSync() ?? .empty()
                } else {
                    return .empty()
                }
            }
            return self?.forceSync() ?? .empty()
        }
    }

    private func forceSync() -> Observable<Void> {
        .create { observer in

            DP3TTracing.sync(runningInBackground: false) { result in
                switch result {
                case let .failure(error):
                    observer.onError(error)
                default:
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

}
