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
import Logging

protocol ExposureKpiUseCase {
    func getExposureKpi() -> KpiDto
}

class ExposureKpiUseCaseImpl : ExposureKpiUseCase {
    
    private let logger = Logger(label: "ExposureKpiUseCase")
    
    private let expositionInfoRepository: ExpositionInfoRepository
    private let exposureKpiRepository: ExposureKpiRepository
    
    init(expositionInfoRepository: ExpositionInfoRepository,
         exposureKpiRepository: ExposureKpiRepository) {
        self.expositionInfoRepository = expositionInfoRepository
        self.exposureKpiRepository = exposureKpiRepository
    }
    
    func getExposureKpi() -> KpiDto {
    
        var exposed = 0
        var date : Date? = nil
        
        if let expositionInfo = expositionInfoRepository.getExpositionInfo() {
            switch expositionInfo.level {
            case .exposed:
                logger.debug("Exposed!")
                if exposureKpiRepository.getLastExposition() != expositionInfo.since {
                    logger.debug("With new date => 1")
                    exposed = 1
                    exposureKpiRepository.save(lastExposition: expositionInfo.since)
                }
                date = expositionInfo.since
                
            case .healthy:
                exposureKpiRepository.save(lastExposition: nil)
            case .infected:
                exposureKpiRepository.save(lastExposition: nil)
            }

        }
        return KpiDto(kpi: "MATCH_CONFIRMED", timestamp: date, value: exposed)
    }
    
}
