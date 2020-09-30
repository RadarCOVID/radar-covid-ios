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
        self.sendDiagnosisCode(code:  FakeRequestUseCase.FALSE_POSITIVE_CODE).subscribe(
            onNext: { _ in
                
//                UserDefaults.set(Date(), forKey: FakeRequestUseCase.lastFake)
            }).disposed(by: disposeBag)
    }
}
