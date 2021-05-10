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
import Logging

protocol ExpositionCheckUseCase {
    
    func checkBackToHealthyJustChanged() -> Bool
    func checkBackToHealthy() -> Observable<Bool>
    
}

class ExpositionCheckUseCaseImpl: ExpositionCheckUseCase {
    
    private let logger = Logger(label: "ExpositionCheckUseCase")

    private let disposeBag = DisposeBag()
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
        logger.debug("checkBackToHealthyJustChanged(): \(changed)")
        return changed
    }

    func checkBackToHealthy() -> Observable<Bool> {
        .deferred { [weak self] in
            guard let self = self else {
                return .empty()
            }
            let expositionInfo = self.expositionInfoRepository.getExpositionInfo()
            
            self.logger.debug("checkBackToHealthy() Level: \(String(describing: expositionInfo?.level))")

            if case .exposed = expositionInfo?.level {
                if self.isExpositionOutdated(expositionInfo) {
                    self.logger.debug("Exposition outdated")
                    self.expositionInfoRepository.setChangedToHealthy(changed: true)
                    self.expositionInfoRepository.save(expositionInfo: ContactExpositionInfo(level: .healthy))
                    return self.resetDataUseCase.resetInfectionStatus().map { true }
                }
            }
            return .just(false)
        }
    }

    private func isExpositionOutdated(_ info: ContactExpositionInfo?) -> Bool {

        if let since = info?.since, let highRiskToLowRisk = settingsRepository.getSettings()?.parameters?.timeBetweenStates?.highRiskToLowRisk {

            let current = Date()
            let limit = since.addingTimeInterval(Double(highRiskToLowRisk * 60))

            return current > limit

        }
        return false
    }

}
