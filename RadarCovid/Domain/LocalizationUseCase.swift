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

class LocalizationUseCase: LocalizationSource {

    private let textsApi: TextsAPI
    private let localizationRepository: LocalizationRepository
    private var _localizationLoaded: Bool = false
    private var _localizationMap: [String: String]?
    public var localizationLoaded: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    var localizationMap: [String: String]? {
            if _localizationMap == nil {
                _localizationMap = localizationRepository.getTexts()
            }

            return _localizationMap
    }

    init( textsApi: TextsAPI, localizationRepository: LocalizationRepository) {
        self.textsApi = textsApi
        self.localizationRepository = localizationRepository
    }
    
//    func localizationLoaded() -> Observable<Bool> {
//        return Observable.create { (observer) -> Disposable in
//            if (self._localizationLoaded){
//                observer.on(.next(self._localizationLoaded)
//            }else{
//
//            }
//        }
//    }

    func loadlocalization() -> Observable<[String: String]?> {
        return .deferred { [weak self] in
            let cau = self?.localizationRepository.getCurrentCA()?.id
            let locale = self?.localizationRepository.getLocale()
            return self?.textsApi.getTexts(ccaa: cau, locale: locale).map { texts in
                let texts = texts.additionalProperties
                self?._localizationMap = texts
                self?.localizationRepository.setTexts(texts)
                print(texts)
                return texts
                self?.localizationLoaded.on(.next(true))
            }.catchError { [weak self] error -> Observable<[String: String]?> in
                guard let localization = self?.localizationMap else {
                    throw error
                }
                return .just(localization)
            } ?? .empty()
        }

    }

}
