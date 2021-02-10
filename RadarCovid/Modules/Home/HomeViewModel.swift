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
import UIKit
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
    var reminderNotificationUseCase: ReminderNotificationUseCase?
    var settingsRepository: SettingsRepository?
    
    var radarStatus = BehaviorSubject<RadarStatus>(value: .active)
    var isErrorTracingDP3T = BehaviorSubject<Bool>(value: false)
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
                self?.isErrorTracingDP3T.onNext(false)
            }, onError: {  [weak self] error in
                self?.error.onNext(error)
                self?.radarStatus.onNext(.inactive)
                self?.checkInitialExposition()
                self?.isErrorTracingDP3T.onNext(true)
            }).disposed(by: disposeBag)
    }
    
    func checkInitial() {
        checkRadarStatus()
        reminderNotificationUseCase?.cancel()
        (UIApplication.shared.delegate as? AppDelegate)?.bluethoothUseCase?.initListener()
    }
    
    func checkRadarStatus() {
        changeRadarStatus(radarStatusUseCase?.isTracingActive() ?? false)
    }
    
    private func checkInitialExposition() {
        
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
            
            guard let isErrorTracing = try? isErrorTracingDP3T.value() else {
                return
            }
            
            if (exposition.level != .infected &&  !isErrorTracing && (radarStatusUseCase?.isTracingActive() ?? false)) {
                self.radarStatus.onNext(.active)
            } else if exposition.level == .infected {
                self.radarStatus.onNext(.disabled)
            }

        }
    }
    
    func checkRemindingExpositionDays(since: Date) -> Int{
        var sinceDay = since
        sinceDay = sinceDay.getStartOfDay()
        
        let minutesInAHour = 60
        let hoursInADay = 24
        let formatter = DateFormatter()
        formatter.dateFormat = Date.appDateFormat
        
        let daysSinceLastInfection = Date().days(sinceDate: sinceDay) ?? 1
        let daysForHealty = Int(settingsRepository?.getSettings()?.parameters?.timeBetweenStates?.highRiskToLowRisk ?? 0) / minutesInAHour / hoursInADay
        return daysForHealty - daysSinceLastInfection
    }
    
    func restoreLastStateAndSync(cb: (() -> Void)? = nil) {
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
    
    func heplerQAReset() {
        resetDataUseCase?.reset().subscribe(
            onNext: { [weak self] _ in
                self?.alertMessage.onNext("ALERT_HOME_RESET_SUCCESS_CONTENT".localized)
            }, onError: { [weak self] error in
                debugPrint(error)
                self?.alertMessage.onNext("ALERT_HOME_RESET_ERROR_CONTENT".localized)
            }).disposed(by: disposeBag)
    }
}
