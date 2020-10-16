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
    private let minFakeRequestTimeSpan = Double(3 * 60 * 60)
    private let disposeBag = DisposeBag()
    private var fakeRequestRepository: FakeRequestRepository
    
    init(settingsRepository: SettingsRepository, verificationApi: VerificationControllerAPI, fakeRequestRepository: FakeRequestRepository) {
        self.fakeRequestRepository = fakeRequestRepository
        super.init(settingsRepository: settingsRepository, verificationApi: verificationApi)
    }
    
    func sendFalsePositive() -> Observable<Bool> {
        return Observable.create { [weak self] (observer) -> Disposable in
            if self?.needToSendFalsePositive() ?? false {
                self?.sendDiagnosisCode(code:  FakeRequestUseCase.FALSE_POSITIVE_CODE).subscribe(
                    onNext: { _ in
                        print("fake request sended with date", Date())
                        self?.fakeRequestRepository.updateScheduledFakeRequestDate()
                        return observer.onNext(true)
                        
                    }
                    ,onError: { (err) in
                        return observer.onError(err)
                    }).disposed(by: self?.disposeBag ?? DisposeBag())
            }else {
                observer.onNext(false)
            }
            return Disposables.create()
        }
        
       
    }
    
    private func needToSendFalsePositive() -> Bool{
        return Date().timeIntervalSince(self.fakeRequestRepository.getNextScheduledFakeRequestDate()) <= 2 * 24 * 60 * 60
    }
    
}
