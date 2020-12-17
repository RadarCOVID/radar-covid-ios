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

class FakeRequestUseCase: DiagnosisCodeUseCase {
    
    public static let FALSE_POSITIVE_CODE = "112358132134"
    private let disposeBag = DisposeBag()
    private var fakeRequestRepository: FakeRequestRepository
    private let keyIdentifierFakeRequestFetch: String = "es.gob.radarcovid.fakerequestfetch"
    
    init(settingsRepository: SettingsRepository,
         verificationApi: VerificationControllerAPI,
         fakeRequestRepository: FakeRequestRepository) {
        
        self.fakeRequestRepository = fakeRequestRepository
        super.init(settingsRepository: settingsRepository, verificationApi: verificationApi)
        self.sendFalsePositive().subscribe().disposed(by: disposeBag)
    }
    
    func initBackgroundTask() {
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: keyIdentifierFakeRequestFetch,
            using: nil
        ) { [weak self] (task) in
            self?.sendFalsePositive(task: task)
                .subscribe(onNext: { success in
                    self?.scheduleBackgroundTask()
                    task.setTaskCompleted(success: success)
                }).disposed(by: self?.disposeBag ?? DisposeBag())

        }
        
        self.scheduleBackgroundTask()
    }
    
    public func scheduleBackgroundTask() {
        
        let fakeRequestTask = BGAppRefreshTaskRequest(identifier: keyIdentifierFakeRequestFetch)
        fakeRequestTask.earliestBeginDate = self.fakeRequestRepository.getNextScheduledFakeRequestDate()
        
        do {
            try BGTaskScheduler.shared.submit(fakeRequestTask)
        } catch {
            print("Unable to submit task: \(error.localizedDescription)")
        }
    }
    
    private func sendFalsePositive(task: BGTask? = nil) -> Observable<Bool> {
        return Observable.create { [weak self] (observer) -> Disposable in
            task?.expirationHandler = {
                observer.onCompleted()
            }
            
            if self?.needToSendFalsePositive() ?? false {
                let randomBoolean = Bool.random()
                self?.sendDiagnosisCode(code:  FakeRequestUseCase.FALSE_POSITIVE_CODE, date: Date(), share: randomBoolean).subscribe(
                    onNext: { _ in
                        print("fake request sended with date", Date())
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
