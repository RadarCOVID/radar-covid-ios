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
import DP3TSDK

class HomeViewModel {

    private let disposeBag = DisposeBag()

    var expositionUseCase: ExpositionUseCase?
    var expositionCheckUseCase: ExpositionCheckUseCase?
    var radarStatusUseCase: RadarStatusUseCase?
    var syncUseCase: SyncUseCase?
    var resetDataUseCase: ResetDataUseCase?
    var onBoardingCompletedUseCase: OnboardingCompletedUseCase?
    var fakeRequestUseCase: FakeRequestUseCase?

    var radarStatus = BehaviorSubject<RadarStatus>(value: .active)
    var checkState = BehaviorSubject<Bool>(value: false)
    var timeExposedDismissed = BehaviorSubject<Bool>(value: false)
    var showBackToHealthyDialog = PublishSubject<Bool>()
    var errorState = BehaviorSubject<DomainError?>(value: nil)
    var expositionInfo = BehaviorSubject<ExpositionInfo>(value: ExpositionInfo(level: .healthy))
    var error = PublishSubject<Error>()
    var alertMessage = PublishSubject<String>()

    func changeRadarStatus(_ active: Bool) {
        radarStatusUseCase?.changeTracingStatus(active: active).subscribe(
            onNext: { [weak self] status in
                self?.radarStatus.onNext(status)
                self?.checkInitialExposition()

            }, onError: {  [weak self] error in
                self?.error.onNext(error)
                self?.radarStatus.onNext(.inactive)
        }).disposed(by: disposeBag)
    }

    func checkInitialExposition() {
      
        expositionUseCase?.updateExpositionInfo()
        
        expositionUseCase?.getExpositionInfo().subscribe(
            onNext: { [weak self] exposition in
                self?.checkExpositionLevel(exposition)
            }, onError: { [weak self] error in
                self?.error.onNext(error)
        }).disposed(by: disposeBag)
    }

    private func checkExpositionLevel(_ exposition: ExpositionInfo?) {
        guard let exposition = exposition else {
            return
        }
        if let error = exposition.error {
            errorState.onNext(error)
        } else {
            expositionInfo.onNext(exposition)
            errorState.onNext(nil)
        }
    }

    func restoreLastStateAndSync(cb: (() -> Void)? = nil) {
        fakeRequestUseCase?.sendFalsePositive().subscribe().disposed(by: disposeBag)
        radarStatusUseCase?.restoreLastStateAndSync().subscribe(
            onNext: { [weak self] status in
                self?.radarStatus.onNext(status)
                cb?()
            }, onError: { [weak self] error in
                self?.error.onNext(error)
                self?.radarStatus.onNext(.inactive)
                cb?()
        }).disposed(by: disposeBag)
    }

    func reset() {
        resetDataUseCase?.reset().subscribe(
            onNext: { [weak self] _ in
                self?.alertMessage.onNext("ALERT_HOME_RESET_SUCCESS_CONTENT".localized)
            }, onError: { [weak self] error in
                debugPrint(error)
                self?.alertMessage.onNext("ALERT_HOME_RESET_ERROR_CONTENT".localized)
        }).disposed(by: disposeBag)
    }

    func checkOnboarding() {
        if onBoardingCompletedUseCase?.isOnBoardingCompleted() ?? false {
            checkState.onNext(false)
        } else {
           checkState.onNext(true)
           self.onBoardingCompletedUseCase?.setOnboarding(completed: true)
           DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
               self?.checkState.onNext(false)
           }
        }
    }

    func checkShowBackToHealthyDialog() {
        if expositionCheckUseCase?.checkBackToHealthyJustChanged() ?? false {
            showBackToHealthyDialog.onNext(true)
        }
    }
    
    func heplerQAChangeHealthy() {
        let expositionInf = ExpositionInfo(level: .exposed)
        checkExpositionLevel(expositionInf)
    }

}
