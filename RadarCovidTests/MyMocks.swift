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
import UIKit

@testable import Radar_COVID

class MockExpositionInfoRepository: ExpositionInfoRepository {
    
    var expositionInfo: ExpositionInfo?
    var changedToHealthy: Bool?
    
    func getExpositionInfo() -> ExpositionInfo? {
        expositionInfo
    }
    
    func save(expositionInfo: ExpositionInfo) {
        
    }
    
    func clearData() {
        
    }
    
    func resetMock() {
        expositionInfo = nil
        changedToHealthy = nil
    }
    
    func isChangedToHealthy() -> Bool? {
        return changedToHealthy
    }
    
    func setChangedToHealthy(changed: Bool) {
        changedToHealthy = changed
    }
    
}

class MockSettingsRepository: SettingsRepository {
    
    var settings:  Settings?
    
    func getSettings() -> Settings? {
        settings
    }
    
    func save(settings: Settings?) {
       
    }
    func resetMock() {
        settings = nil
    }
    
}

class MockExpositionCheckUseCase: ExpositionCheckUseCase {
    
    var justChanged = false
    var jusChangedCalls = 0
    
    var backToHealthy = Observable.just(false)
    var checkBackToHealthyCalls = 0
    
    func checkBackToHealthyJustChanged() -> Bool {
        jusChangedCalls += 1
        return justChanged
    }
    
    func checkBackToHealthy() -> Observable<Bool> {
        checkBackToHealthyCalls += 1
        return backToHealthy
    }
    
    func resetMock() {
        jusChangedCalls = 0
        checkBackToHealthyCalls = 0
    }
    
}

class MockResetDataUseCase : ResetDataUseCase {
    
    func resetInfectionStatus() -> Observable<Void> {
        .empty()
    }
    
    var exposureDaysCalls: Int = 0
    
    func reset() -> Observable<Void> {
        .empty()
    }
    
    func resetExposureDays() -> Observable<Void> {
        exposureDaysCalls += 1
        return .just(())
    }
    
    func resetMock() {
        exposureDaysCalls = 0
    }
    
}

class AlertControllerMock: AlertController {
    
    func showAlertOk(title: String, message: String, buttonTitle: String, _ callback: (() -> Void)?) {
        showAlertOkCalls += 1
        self.title = title
        self.message = message
    }
    
    func showAlertCancelContinue(title: NSAttributedString, message: NSAttributedString, buttonOkTitle: String, buttonCancelTitle: String, buttonOkVoiceover: String?, buttonCancelVoiceover: String?, okHandler: (() -> Void)?, cancelHandler: (() -> Void)?) {
    }
    
    func showAlertCancelContinue(title: NSAttributedString, message: NSAttributedString, buttonOkTitle: String, buttonCancelTitle: String, buttonOkVoiceover: String?, buttonCancelVoiceover: String?, okHandler: (() -> Void)?) {

    }
    
    
    var showAlertOkCalls: Int = 0
    
    var title: String?
    var message: String?
    
    
    func resetMock() {
        showAlertOkCalls = 0
        title = nil
        message = nil
    }
    
}

class ErrorRecorderMock: ErrorRecorder {
    var recordCalls: Int = 0
    var error: Error?
    
    func record(error: Error) {
        recordCalls += 1
        self.error = error
    }
    func resetMock() {
        recordCalls = 0
        error = nil
    }
    
}

class ExpositionInfoRepositoryMock: ExpositionInfoRepository {
    
    var expositionInfo: ExpositionInfo?
    var expositionInfoCalls: Int = 0
    
    func getExpositionInfo() -> ExpositionInfo? {
        expositionInfoCalls += 1
        return expositionInfo
    }
    
    func save(expositionInfo: ExpositionInfo) {
        
    }
    
    func isChangedToHealthy() -> Bool? {
        false
    }
    
    func setChangedToHealthy(changed: Bool) {
        
    }
    
    func clearData() {
        
    }
    
    func resetMock() {
        expositionInfo = nil
        expositionInfoCalls = 0
    }
}

class ExposureKpiRepositoryMock: ExposureKpiRepository {
    
    var date: Date?
    var saveCalls = 0
    
    func getLastExposition() -> Date? {
        date
    }
    
    func save(lastExposition: Date?) {
        date = lastExposition
        saveCalls += 1
    }
    
    func resetMock() {
        date = nil
        saveCalls = 0
    }
}

class DeviceTokenHandlerMock: DeviceTokenHandler {
    
    var clearCachedTokenCalls = 0
    var generateTokenCalls = 0
    var generateTokenValue: Observable<DeviceToken>?
    
    func generateToken() -> Observable<DeviceToken> {
        generateTokenCalls += 1
        return generateTokenValue ?? .empty()
    }
    
    func clearCachedToken() {
        clearCachedTokenCalls += 1
    }
    
    func resetMock() {
        generateTokenValue = nil
        clearCachedTokenCalls = 0
        generateTokenCalls = 0
    }
    
}

class AnalyticsRepositoryMock: AnalyticsRepository {
    
    var lastRun : Date?
    var lastRunCalls = 0
    var saveCalls = 0
    
    func getLastRun() -> Date? {
        lastRunCalls += 1
        return lastRun
    }
    
    func save(lastRun: Date) {
        saveCalls += 1
    }
    
    func resetMock() {
        lastRunCalls = 0
        saveCalls = 0
        lastRun = nil
    }
    
}

class AppleKpiControllerAPIMock: AppleKpiControllerAPI {
    
    var saveKpiCalls = 0
    var saveKpiValues: [Observable<Void>]?
    var verifyTokenCalls = 0
    var verifyTokenValues: [Observable<VerifyResponse>]?
    
    init() {
        super.init(clientApi: SwaggerClientAPI())
    }
    override func saveKpi(body: [KpiDto], token: String) -> Observable<Void> {
        Observable.just(Void()).flatMap { () -> Observable<Void> in
            self.saveKpiCalls += 1
            return self.saveKpiValues![self.getValueIndex(self.saveKpiValues!, self.saveKpiCalls)]
        }
    }
    
    override func verifyToken(body: AppleKpiTokenRequestDto) -> Observable<VerifyResponse> {
        Observable.just(Void()).flatMap { () -> Observable<VerifyResponse> in
            self.verifyTokenCalls += 1
            return self.verifyTokenValues![self.getValueIndex(self.verifyTokenValues!, self.verifyTokenCalls)]
        }
    }
    
    private func getValueIndex(_ values:[Any], _ calls: Int) -> Int {
        if calls > values.count {
            return values.count - 1
        }
        return calls - 1
    }
    
    func resetMock() {
        saveKpiCalls = 0
        verifyTokenCalls = 0
        saveKpiValues = nil
        verifyTokenValues = nil
    }
    
}

class ExposureKpiUseCaseMock: ExposureKpiUseCase {
    func getExposureKpi() -> KpiDto {
        KpiDto(kpi: nil, timestamp: nil, value: nil)
    }
    
    func resetMock() {
        
    }
}


