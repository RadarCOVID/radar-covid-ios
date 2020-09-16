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

class ExpositionCheckUseCase {

    private let expositionInfoRepository: ExpositionInfoRepository
    private let settingsRepository: SettingsRepository
    private let resetDataUseCase: ResetDataUseCase

    init(expositionInfoRepository: ExpositionInfoRepository,
         settingsRepository: SettingsRepository,
         resetDataUseCase: ResetDataUseCase) {
        self.expositionInfoRepository = expositionInfoRepository
        self.settingsRepository = settingsRepository
        self.resetDataUseCase = resetDataUseCase
    }

    func checkBackToHealthyJustChanged() -> Bool {
        let changed = expositionInfoRepository.isChangedToHealthy() ?? false
        expositionInfoRepository.setChangedToHealthy(changed: false)
        return changed
    }

    func checkBackToHealthy() -> Observable<Bool> {
        .deferred { [weak self] in
            let expositionInfo = self?.expositionInfoRepository.getExpositionInfo()

            if case .exposed = expositionInfo?.level {
                if self?.isExpositinOutdated(expositionInfo) ?? false {
                    self?.expositionInfoRepository.setChangedToHealthy(changed: true)
                    return self?.resetDataUseCase.resetExposureDays().map { true } ?? .empty()
                }
            }
            return .just(false)
        }
    }

    private func isExpositinOutdated(_ info: ExpositionInfo?) -> Bool {

        if let since = info?.since,
           let highRiskToLowRisk = settingsRepository.getSettings()?.parameters?.timeBetweenStates?.highRiskToLowRisk {

            let current = Date()
            let limit = since.addingTimeInterval(Double(highRiskToLowRisk * 60))

            return current > limit

        }
        return false
    }

}
