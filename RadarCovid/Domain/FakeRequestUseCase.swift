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

class FakeRequestUseCase: DiagnosisCodeUseCase {
    public static let FALSE_POSITIVE_CODE = "112358132134"
    private static let lastFake = "UserDefaultsFakeRequestUseCase.lastFake"
    private let disposeBag = DisposeBag()
    
    func sendFalsePositive(){
        let defaults = UserDefaults.standard
        if checkTimeInterval(defaults: defaults) {
            self.sendDiagnosisCode(code:  FakeRequestUseCase.FALSE_POSITIVE_CODE).subscribe(
                onNext: { _ in
                    defaults.set(Date(), forKey: "LastDate")
            }).disposed(by: disposeBag)
        }
    }
    
    func checkTimeInterval(defaults: UserDefaults) -> Bool{
        let storedDate = defaults.object(forKey: "LastDate")
        let storedDateString = String(describing: storedDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:ii"
        if let compareDate = dateFormatter.date(from: storedDateString){
            let actualDate = Date()
            let diffComponents = Calendar.current.dateComponents([.hour], from: compareDate, to: actualDate)
            let hours = diffComponents.hour ?? 0
            return hours >= 3
        }
        return false
    }
}
