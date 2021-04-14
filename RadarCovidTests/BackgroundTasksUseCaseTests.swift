//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import XCTest
import RxSwift

@testable import Radar_COVID

class BackgroundTasksUseCaseTests: XCTestCase {
    
    private var analyticsUseCase: AnalyticsUseCaseMock!
    private var fakeRequestUseCase: FakeRequestUseCaseMock!
    private var expositionCheckUseCase: ExpositionCheckUseCaseMock!
    private var configurationUseCase: ConfigurationUseCaseMock!
    private var checkInInprogressUseCase: CheckInInProgressUseCaseMock!
    private var problematicEventsUseCase: ProblematicEventsUseCaseMock!
    
    private var sut: BackgroundTasksUseCaseImpl!

    override func setUpWithError() throws {
        
        analyticsUseCase = AnalyticsUseCaseMock()
        fakeRequestUseCase = FakeRequestUseCaseMock()
        expositionCheckUseCase = ExpositionCheckUseCaseMock()
        configurationUseCase = ConfigurationUseCaseMock()
        checkInInprogressUseCase = CheckInInProgressUseCaseMock()
        problematicEventsUseCase = ProblematicEventsUseCaseMock()
        
        sut = BackgroundTasksUseCaseImpl(analyticsUseCase: analyticsUseCase, fakeRequestUseCase: fakeRequestUseCase, expositionCheckUseCase: expositionCheckUseCase, checkInInprogressUseCase: checkInInprogressUseCase, configurationUseCase: configurationUseCase, problematicEventsUseCase: problematicEventsUseCase)
    }

    override func tearDownWithError() throws {
        
    }

    func testCallConfigThenCheckInThenProblematic() throws {
        
        configurationUseCase.registerLoadConfig(response: .just(Settings()))
        analyticsUseCase.registerSendAnalytics(response: true)
        fakeRequestUseCase.regiterSendFalsePositiveFromBackgroundDP3T(response: true)
        checkInInprogressUseCase.registerCheckStauts(response: .just(Void()))
        
        try! sut.runTasks().toBlocking().first()
        
        let loadConfigCall = configurationUseCase.verfyLoadConfig()
        let checkStatusCall = checkInInprogressUseCase.verifyCheckStatus()
        let syncCall = problematicEventsUseCase.verifySync()
        
        loadConfigCall!.verify(called: .before, checkStatusCall)
        checkStatusCall!.verify(called: .before, syncCall)
        
    }
    
    func testConfigErrorDontStopOthers() {
        configurationUseCase.registerLoadConfig(response: .error("Error"))
        analyticsUseCase.registerSendAnalytics(response: true)
        fakeRequestUseCase.regiterSendFalsePositiveFromBackgroundDP3T(response: true)
        checkInInprogressUseCase.registerCheckStauts(response: .just(Void()))
        
        try! sut.runTasks().toBlocking().first()
        
        let loadConfigCall = configurationUseCase.verfyLoadConfig()
        let checkStatusCall = checkInInprogressUseCase.verifyCheckStatus()
        let syncCall = problematicEventsUseCase.verifySync()
        
        loadConfigCall!.verify(called: .before, checkStatusCall)
        checkStatusCall!.verify(called: .before, syncCall)
        
    }
    
    func testCheckStatusErrorDontStopOthers() {
        configurationUseCase.registerLoadConfig(response: .just(Settings()))
        analyticsUseCase.registerSendAnalytics(response: true)
        fakeRequestUseCase.regiterSendFalsePositiveFromBackgroundDP3T(response: true)
        
        checkInInprogressUseCase.registerCheckStauts(response: .error("Error"))
        
        try! sut.runTasks().toBlocking().first()
        
        let loadConfigCall = configurationUseCase.verfyLoadConfig()
        let checkStatusCall = checkInInprogressUseCase.verifyCheckStatus()
        let syncCall = problematicEventsUseCase.verifySync()
        
        loadConfigCall!.verify(called: .before, checkStatusCall)
        checkStatusCall!.verify(called: .before, syncCall)
        
    }

}

class AnalyticsUseCaseMock: Mocker, AnalyticsUseCase {
    init() {
        super.init("AnalyticsUseCaseMock")
    }
    func registerSendAnalytics(response: Bool) {
        registerMock("sendAnaltyics", responses: [Observable.just(response)])
    }
    func sendAnaltyics() -> Observable<Bool> {
        Observable.just(Void()).flatMap { () -> Observable<Bool> in
            self.call("sendAnaltyics") as! Observable<Bool>
        }
    }
}

class FakeRequestUseCaseMock: Mocker, FakeRequestUseCase {
    init() {
        super.init("FakeRequestUseCaseMock")
    }
    
    func regiterSendFalsePositiveFromBackgroundDP3T(response: Bool) {
        registerMock("sendFalsePositiveFromBackgroundDP3T", responses: [Observable.just(response)])
    }
    func sendFalsePositiveFromBackgroundDP3T() -> Observable<Bool> {
        Observable.just(Void()).flatMap { () -> Observable<Bool> in
            self.call("sendFalsePositiveFromBackgroundDP3T") as! Observable<Bool>
        }
    }
}

class ConfigurationUseCaseMock: Mocker, ConfigurationUseCase {
    init() {
        super.init("ConfigurationUseCaseMock")
    }
    
    func registerLoadConfig(response: Observable<Settings>) {
        registerMock("loadConfig", responses: [response])
    }
        
    func loadConfig() -> Observable<Settings> {
        Observable.just(Void()).flatMap { () -> Observable<Settings> in
            self.call("loadConfig") as! Observable<Settings>
        }
    }
    func verfyLoadConfig() -> MockedFuncCall? {
        verify("loadConfig")
    }
}

class CheckInInProgressUseCaseMock: Mocker, CheckInInProgressUseCase {
    
    var maxCheckInMinutes: Int64 = 120
    
    init() {
        super.init("CheckInInProgressUseCaseMock")
    }
    
    func checkStauts() -> Observable<Void> {
        Observable.just(Void()).flatMap { () -> Observable<Void> in
           
            return self.call("checkStauts") as! Observable<Void>
        }
    }
    
    func verifyCheckStatus() -> MockedFuncCall? {
        verify("checkStauts")
    }
    
    func registerCheckStauts(response: Observable<Void>) {
        self.registerMock("checkStauts", responses: [response])
    }
}


class ProblematicEventsUseCaseMock: Mocker, ProblematicEventsUseCase {
    
    var maxMinutesToKeep: Int = 120
    
    init() {
        super.init("ProblematicEventsUseCaseMock")
    }
    
    func sync() -> Observable<Void> {
        Observable.just(Void()).flatMap { () -> Observable<Void> in
            self.registerMock("sync", responses: [Observable.just(Void())])
            return self.call("sync") as! Observable<Void>
        }
    }
    
    func verifySync() -> MockedFuncCall? {
        verify("sync")
    }
}
