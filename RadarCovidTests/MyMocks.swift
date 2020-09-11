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

class MockResetDataUseCase : ResetDataUseCase {
    
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
    
    var showAlertOkCalls: Int = 0
    
    var title: String?
    var message: String?
    
    func showAlertCancelContinue(title: String, message: String, buttonOkTitle: String, buttonCancelTitle: String, okHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) {

    }
    
    func showAlertCancelContinue(title: String, message: String, buttonOkTitle: String, buttonCancelTitle: String, okHandler: ((UIAlertAction) -> Void)?) {
        
    }
    
    
    func showAlertOk(title: String, message: String, buttonTitle: String, _ callback: ((Any) -> Void)?) {
        showAlertOkCalls += 1
        self.title = title
        self.message = message
    }
    
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
