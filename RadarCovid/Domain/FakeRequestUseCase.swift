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
import BackgroundTasks

protocol FakeRequestUseCase {
    func sendFalsePositiveFromBackgroundDP3T() -> Observable<Bool>
}

@available(iOS 13.0, *)
protocol FakeRequestBackgroundTask {
    func initBackgroundTask()
    func scheduleBackgroundTask()
}

class FakeRequestUseCaseImpl: DiagnosisCodeUseCase, FakeRequestUseCase {
    
    public static let FALSE_POSITIVE_CODE = "112358132134"
    private let disposeBag = DisposeBag()
    private var fakeRequestRepository: FakeRequestRepository
    private let keyIdentifierFakeRequestFetch: String = "es.gob.radarcovid.fakerequestfetch"
    
    init(settingsRepository: SettingsRepository,
         verificationApi: VerificationControllerAPI,xx
         fakeRequestRepository: FakeRequestRepository) {
        
        self.fakeRequestRepository = fakeRequestRepository
        super.init(settingsRepository: settingsRepository, verificationApi: verificationApi)
        if #available(iOS 13.0, *) {
            self.sendFalsePositive().subscribe().disposed(by: disposeBag)
        } else {
            self.sendOldFalsePositive().subscribe().disposed(by: disposeBag)
        }
    }
    

    func sendFalsePositiveFromBackgroundDP3T() -> Observable<Bool> {
        if #available(iOS 13.0, *) {
            return .empty()
        }
        
        return self.sendOldFalsePositive()
        
    }
        
    /**
     Old version S.O.
     */
    private func sendOldFalsePositive() -> Observable<Bool> {
        .create { [weak self] (observer) -> Disposable in
            if self?.needToSendFalsePositive() ?? false {
                let randomBoolean = Bool.random()
                self?.sendDiagnosisCode(code:  FakeRequestUseCaseImpl.FALSE_POSITIVE_CODE, date: Date(), share: randomBoolean).subscribe(
                    onNext: { _ in
                        debugPrint("fake request sent with date", Date())
                        self?.fakeRequestRepository.updateScheduledFakeRequestDate()
                        return observer.onNext(true)
                        
                    }
                    ,onError: { (err) in
                        return observer.onError(err)
                    }).disposed(by: self?.disposeBag ?? DisposeBag())
            } else {
                observer.onNext(false)
            }
            return Disposables.create()
        }
    }
    
    private func needToSendFalsePositive() -> Bool{
        let interval = self.fakeRequestRepository.getNextScheduledFakeRequestDate().timeIntervalSince(Date())
        return interval <= 2 * 24 * 60 * 60
    }
    
}

@available(iOS 13.0, *)
extension FakeRequestUseCaseImpl: FakeRequestBackgroundTask {
    
    func initBackgroundTask() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
    
    public func scheduleBackgroundTask() {
        
    }
    
    private func sendFalsePositive(task: BGTask? = nil) -> Observable<Bool> {
        .create { [weak self] (observer) -> Disposable in
            task?.expirationHandler = {
                observer.onCompleted()
            }
        
            if self?.needToSendFalsePositive() ?? false {
                let randomBoolean = Bool.random()
                self?.sendDiagnosisCode(code: FakeRequestUseCaseImpl.FALSE_POSITIVE_CODE, date: Date(), share: randomBoolean).subscribe(
                    onNext: { _ in
                        debugPrint("fake request sent with date", Date())
                        self?.fakeRequestRepository.updateScheduledFakeRequestDate()
                        return observer.onNext(true)
                        
                    }
                    ,onError: { (err) in
                        return observer.onError(err)
                    }).disposed(by: self?.disposeBag ?? DisposeBag())
            } else {
                observer.onNext(false)
            }
            return Disposables.create()
        }
    }
    
}
