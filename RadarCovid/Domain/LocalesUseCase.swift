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

class LocalesUseCase {

    private let localizationRepository: LocalizationRepository
    private let masterDataApi: MasterDataAPI

    private var locales: [ItemLocale]?

    init(localizationRepository: LocalizationRepository,
         masterDataApi: MasterDataAPI) {
        self.localizationRepository = localizationRepository
        self.masterDataApi = masterDataApi
    }

    public func loadLocales() -> Observable<[ItemLocale]> {
        var currentLocale = localizationRepository.getLocale()
        if currentLocale == nil {
            currentLocale = getLocaleFromDevice(currentLocale: NSLocale.current.languageCode)
        }
        return masterDataApi.getLocales(locale: currentLocale, platform: Config.platform, version: Config.version).map { [weak self] masterLocales in
            var locales: [ItemLocale] = []
            
            masterLocales.forEach { loc in
                locales.append(ItemLocale.mappertToKeyValueDto(keyValueDto: loc))
            }
            print(locales)
            self?.locales = locales
            self?.localizationRepository.setLocales(locales)
            return locales
        }
    }
    
    public func getLocaleFromDevice(currentLocale: String?) -> String? {
        switch currentLocale {
        case "es": return "es-ES"
        case "ca": return "ca-ES"
        case "eu": return "eu-ES"
        case "gl": return "gl-ES"
        case "ro": return "ro-RO"
        case "va": return "va-ES"
        case "fr": return "fr-FR"
        case "en": return "en-US"
        default: return nil
        }
    }

    public func getLocales() -> Observable<[ItemLocale]> {
        .deferred { [weak self] in
            if let locales = self?.locales {
                return .just(locales)
            }
            if let locales = self?.localizationRepository.getLocales() {
                return .just(locales)
            }
            return self?.loadLocales() ?? .empty()
        }
    }

    public func getCurrent() -> String? {
        localizationRepository.getLocale()
    }

    public func setCurrent(locale: String) {
        localizationRepository.setLocale(locale)
    }
}
