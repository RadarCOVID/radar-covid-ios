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

class CountriesUseCase {

    private let countriesRepository: CountriesRepository
    private let masterDataApi: MasterDataAPI
    private let localizationRepository: LocalizationRepository
    private var countries: [ItemCountry]?

    init(
        countriesRepository: CountriesRepository
        , masterDataApi: MasterDataAPI
        , localizationRepository: LocalizationRepository
    ) {
        self.countriesRepository = countriesRepository
        self.masterDataApi = masterDataApi
        self.localizationRepository = localizationRepository
        
    }

    func loadCountries() -> Observable<[ItemCountry]> {
        return masterDataApi.getCountries(locale: localizationRepository.getLocale(), platform: Config.platform, version: Config.version).map { [weak self] masterCountries in
            var countries: [ItemCountry] = []
            masterCountries.forEach { (country) in
                countries.append(ItemCountry.mappertToKeyValueDto(keyValueDto: country))
            }
            self?.countries = countries
            self?.countriesRepository.setCountries(countries)
            return countries
        }
        

    }

    public func getCountries() -> Observable<[ItemCountry]> {
        .deferred { [weak self] in
            if let countries = self?.countries {
                return .just(countries)
            }
            if let countries = self?.countriesRepository.getCountries() {
                return .just(countries)
            }
            return self?.loadCountries() ?? .empty()
        }
    }

  
}
