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

class WelcomeViewModel {
    
    let localesUseCase: LocalesUseCase!
    
    private var disposeBag = DisposeBag()
    
    init(localesUseCase: LocalesUseCase) {
        self.localesUseCase = localesUseCase
    }
    
    func getLenguages() -> Observable<[ItemLocale]> {
        return localesUseCase.getLocales()
    }
    
    func getCurrenLenguage() -> String {
        return self.localesUseCase.getCurrent() ?? ""
    }
    
    func setCurrentLocale(key: String) {
        localesUseCase.setCurrent(locale: key)
    }
    
    func getCurrenLenguageLocalizable() -> Observable<String> {
        .create { [weak self] observer in
            
            self?.localesUseCase.getLocales()
                .observeOn(MainScheduler.instance)
                .subscribe(
                    onNext: { arrayCurrentLanguages in
                        
                        let strLanguage = arrayCurrentLanguages
                            .filter({ (itemLocale) -> Bool in
                                itemLocale.id.contains(self?.localesUseCase.getCurrent() ?? "")
                            }).first?.description
                        
                        observer.onNext(strLanguage ?? "")
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: {
                    }).disposed(by: self?.disposeBag ?? DisposeBag())
            observer.onCompleted()
            
            return Disposables.create {}
        }
    }
}
