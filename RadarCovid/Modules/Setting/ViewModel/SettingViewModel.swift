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

class SettingViewModel {
    
    let localesUseCase: LocalesUseCase!
    
    private var disposeBag = DisposeBag()
    
    
    init(localesUseCase: LocalesUseCase) {
        self.localesUseCase = localesUseCase
    }
    
    func getLenguages() -> Observable<[String: String?]> {
        return localesUseCase.getLocales()
    }
    
    func getCurrenLenguageLocalizable() -> Observable<String> {
        return Observable.create { [weak self] observer in
            
            self?.localesUseCase.getLocales()
                .observeOn(MainScheduler.instance)
                .subscribe(
                    onNext: { arrayCurrentLanguages in
                        let strLanguage = arrayCurrentLanguages[self?.localesUseCase.getCurrent() ?? "", default: ""]
                        observer.onNext(strLanguage ?? "")
                }, onError: { error in
                    observer.onError(error)
                }, onCompleted: {
                }).disposed(by: self?.disposeBag ?? DisposeBag())
            observer.onCompleted()

            return Disposables.create {
            }
        }
    }
    
    func getCurrenLenguage() -> String {
        return self.localesUseCase.getCurrent() ?? ""
    }
    
    func setCurrentLocale(key: String) {
        localesUseCase.setCurrent(locale: key)
    }
}
