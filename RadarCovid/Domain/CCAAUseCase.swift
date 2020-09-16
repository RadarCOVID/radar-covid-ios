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

class CCAAUseCase {

    private var ccaa: [CaData]?
    private let masterDataApi: MasterDataAPI
    private let localizationRepository: LocalizationRepository

    init(masterDataApi: MasterDataAPI, localizationRepository: LocalizationRepository) {
        self.masterDataApi = masterDataApi
        self.localizationRepository = localizationRepository
    }

    public func loadCCAA() -> Observable<[CaData]> {
        .deferred { [weak self] in
            let locale = self?.localizationRepository.getLocale()
            return self?.masterDataApi.getCcaa(locale: locale, additionalInfo: true).map { values in
                var ccaa: [CaData] = []
                values.forEach { value in
                    if let ca = self?.mapCa(value) {
                        ccaa.append(ca)
                    }
                }
                self?.ccaa = ccaa
                return ccaa
            } ?? .empty()
        }
    }

    public func getCCAA() -> Observable<[CaData]> {
        .deferred { [weak self] in
            if let ccaa = self?.ccaa {
                return .just(ccaa)
            }
            return self?.loadCCAA() ?? .empty()
        }
    }

    public func getCurrent() -> CaData? {
        localizationRepository.getCurrentCA()
    }

    public func setCurrent(cca: CaData) {
        localizationRepository.setCurrent(ca: cca)
    }

    private func mapCa(_ caDto: CcaaKeyValueDto) -> CaData {
        CaData(
            id: caDto.id,
           description: caDto.description,
           phone: caDto.phone,
           email: caDto.email,
           web: caDto.web,
           webName: caDto.webName,
           additionalInfo: caDto.additionalInfo
        )
    }

}
