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

class DetailInteroperabilityViewModel {
    
    var countriesUseCase: CountriesUseCase!
    var countries: BehaviorSubject<[ItemCountry]> = BehaviorSubject(value: [])
    let disposeBag = DisposeBag()
    func getCountries() -> Observable<[ItemCountry]> {
        return countries
    }
    
    func loadCountries(){
       
        countriesUseCase.getCountries().subscribe { (countries) in
            self.countries.onNext(countries)
        }.disposed(by: disposeBag)
        
    


    }
}
