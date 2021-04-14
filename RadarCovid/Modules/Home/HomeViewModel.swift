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
    
    private let  minutesADay = 60 * 24
    
    private let disposeBag = DisposeBag()
    
    var expositionUseCase: ExpositionUseCase!
    var expositionCheckUseCase: ExpositionCheckUseCase!
    var radarStatusUseCase: RadarStatusUseCase!
    var resetDataUseCase: ResetDataUseCase!
    var onBoardingCompletedUseCase: OnboardingCompletedUseCase!
    var reminderNotificationUseCase: ReminderNotificationUseCase!
    var settingsRepository: SettingsRepository!
    var problematicEventsUseCase: ProblematicEventsUseCase!
    
    var radarStatus = BehaviorSubject<RadarStatus>(value: .active)
    var isErrorTracingDP3T = BehaviorSubject<Bool>(value: false)
    var checkState = BehaviorSubject<Bool>(value: false)
    var timeExposedDismissed = BehaviorSubject<Bool>(value: false)
    var showBackToHealthyDialog = PublishSubject<Bool>()
    var errorState = BehaviorSubject<DomainError?>(value: nil)
    
    var expositionInfo = BehaviorSubject<ContactExpositionInfo>(value: ContactExpositionInfo(level: .healthy))
    var venueExpositionInfo = BehaviorSubject<VenueExpositionInfo>(value: VenueExpositionInfo(level: .healthy))
    
    var hideContactExpositionInfo = BehaviorSubject<Bool>(value: false)
    var hideVenueExpositionInfo = BehaviorSubject<Bool>(value: true)
    
    var error = PublishSubject<Error>()
    var alertMessage = PublishSubject<String>()
    
    func changeRadarStatus(_ active: Bool) {
        radarStatusUseCase.changeTracingStatus(active: active).subscribe(
            onNext: { [weak self] status in
                self?.radarStatus.onNext(status)
                self?.isErrorTracingDP3T.onNext(false)
            }, onError: {  [weak self] error in
                self?.error.onNext(error)
                self?.radarStatus.onNext(.inactive)
                self?.isErrorTracingDP3T.onNext(true)
            }).disposed(by: disposeBag)
    }
    
    func checkProblematicEvents() {
        problematicEventsUseCase.sync().subscribe(
            onNext: { _ in
                debugPrint("Problematics events sync successful")
            }, onError: { error in
                debugPrint("Problematics events sync error: \(error)")
            }).disposed(by: disposeBag)
    }
    
    
    
    func checkInitial() {
        checkRadarStatus()
        checkInitialExposition()
        reminderNotificationUseCase.cancel()
        (UIApplication.shared.delegate as? AppDelegate)?.bluethoothUseCase?.initListener()
    }
    
    func checkRadarStatus() {
        changeRadarStatus(radarStatusUseCase.isTracingActive())
    }
    
    private func checkInitialExposition() {
        
        expositionUseCase.updateExpositionInfo()
        
        expositionUseCase.getExpositionInfo()
            .observeOn(MainScheduler.instance)
            .subscribe(
            onNext: { [weak self] exposition in
                self?.checkExpositionLevel(exposition.contact)
                self?.venueExpositionInfo.onNext(exposition.venue)
                self?.showAndHideVenueAndContacExpositionLevel(exposition)
            }, onError: { [weak self] error in
                self?.error.onNext(error)
            }).disposed(by: disposeBag)
    }
    
    private func showAndHideVenueAndContacExpositionLevel(_ expositionInfo: ExpositionInfo) {
         if expositionInfo.contact.level == .infected  ||
            expositionInfo.contact.level == .healthy && expositionInfo.venue.level == .healthy ||
            expositionInfo.contact.level == .exposed && expositionInfo.venue.level == .healthy {
            hideContactExpositionInfo.onNext(false)
            hideVenueExpositionInfo.onNext(true)
        } else if expositionInfo.contact.level == .healthy && expositionInfo.venue.level == .exposed {
            hideContactExpositionInfo.onNext(true)
            hideVenueExpositionInfo.onNext(false)
        } else if expositionInfo.contact.level == .exposed && expositionInfo.venue.level == .exposed {
            hideContactExpositionInfo.onNext(false)
            hideVenueExpositionInfo.onNext(false)
        }
    }
    
    private func checkExpositionLevel(_ exposition: ContactExpositionInfo?) {
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
    
    func getRemainingExpositionDays(since: Date) -> Int {
        getDaysRemaining(since: since, timeToHealthy: Int(settingsRepository.getSettings()?.parameters?.timeBetweenStates?.highRiskToLowRisk ?? 0))

    }
    
    func getRemainingVenueExpositionDays(since: Date?) -> Int {
        getDaysRemaining(since: since ?? Date(), timeToHealthy: Int(settingsRepository.getSettings()?.parameters?.venueConfiguration?.quarentineAfterExposed ?? 0))
    }
    
    private func getDaysRemaining(since: Date, timeToHealthy: Int) -> Int {
        let sinceDay = since.getStartOfDay()
        
        let daysSinceLastExposition = Date().days(sinceDate: sinceDay) ?? 1
        
        let result = (timeToHealthy / minutesADay) - daysSinceLastExposition
        
        return result > 0 ? result : 0
    }
    
    func restoreLastStateAndSync(cb: (() -> Void)? = nil) {
        radarStatusUseCase.restoreLastStateAndSync().subscribe(
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
        if onBoardingCompletedUseCase.isOnBoardingCompleted() {
            checkState.onNext(false)
        } else {
            checkState.onNext(true)
            onBoardingCompletedUseCase.setOnboarding(completed: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.checkState.onNext(false)
            }
        }
    }
    
    func checkShowBackToHealthyDialog() {
        showBackToHealthyDialog.onNext(expositionCheckUseCase.checkBackToHealthyJustChanged())
    }
    
    func heplerQAChangeHealthy() {
        let expositionInf = ContactExpositionInfo(level: .exposed)
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
