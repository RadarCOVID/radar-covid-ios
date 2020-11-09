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
import DP3TSDK

protocol ResetDataUseCase {
    func reset() -> Observable<Void>
    func resetExposureDays() -> Observable<Void>
    func resetInfectionStatus() -> Observable<Void>
}

class ResetDataUseCaseImpl: ResetDataUseCase {

    private let expositionInfoRepository: ExpositionInfoRepository
    var setupUseCase: SetupUseCase?

    init(expositionInfoRepository: ExpositionInfoRepository) {
        self.expositionInfoRepository = expositionInfoRepository
    }
    
    func reset() -> Observable<Void> {
        .deferred { [weak self] in
            do {
                DP3TTracing.reset()
                try self?.setupUseCase!.initializeSDK()
                self?.expositionInfoRepository.clearData()
            } catch {
                return .error(error)
            }

            return .just(())
        }
    }

    func resetExposureDays() -> Observable<Void> {
        .deferred { [weak self] in
            DP3TTracing.resetExposureDays()
            self?.expositionInfoRepository.clearData()

            return .just(())
        }
    }
    
    func resetInfectionStatus() -> Observable<Void> {
        .deferred { [weak self] in
            DP3TTracing.resetInfectionStatus()
            self?.expositionInfoRepository.clearData()

            return .just(())
        }
    }
}
