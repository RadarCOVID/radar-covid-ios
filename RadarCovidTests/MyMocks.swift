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
import XCTest

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

class VenueRecordRepositoryMock : Mocker, VenueRecordRepository {
    
    init() {
        super.init("VenueRecordRepositoryMock")
    }
    
    func getCurrentVenue() -> VenueRecord? {
        call("getCurrentVenue") as? VenueRecord
    }
    
    func save(current: VenueRecord) {
        
    }
    
    func removeCurrent() {
        call("removeCurrent")
    }
    
    func registerGetCurrentVenue(response: VenueRecord?) {
        registerMock("getCurrentVenue", responses: [response])
    }
    
    func verifyRemoveCurrent(called: VerifyCount = .atLeastOnce) {
        verify("removeCurrent", called : called)
    }
    
    func verifyGetCurrentVenue() {
        verify("getCurrentVenue")
    }
    
}



class VenueNotifierMock : Mocker, VenueNotifier {
    
    required init(baseUrl: String) {
        super.init("VenueNotifierMock")
    }
    
    func getInfo(qrCode: String) -> Observable<VenueInfo> {
        Observable.just(Void()).flatMap { () -> Observable<VenueInfo> in
            self.call("getInfo", params: ["qrCode": qrCode]) as! Observable<VenueInfo>
        }
    }
    
    func checkOut(venue: VenueInfo, arrival: Date, departure: Date) -> Observable<VenueInfo> {
        Observable.just(Void()).flatMap { () -> Observable<VenueInfo> in
            self.call("checkOut", params: ["venue":venue, "arrival": arrival, "departure": departure]) as! Observable<VenueInfo>
        }
    }
    
    func registerCheckOut(response: Observable<VenueInfo>) {
        registerMock("checkOut", responses: [response])
    }
    
    func registerGetInfo(response: Observable<VenueInfo>) {
        registerMock("getInfo", responses: [response])
    }
    
    func verifyCheckout(called: VerifyCount = .atLeastOnce) {
        verify("checkOut", called: called)
    }
    
    func verifyGetInfo(called: VerifyCount = .atLeastOnce) {
        verify("getInfo", called: called)
    }
    
}

class Mocker {
    
    private var mockedFuncs: [String: MockedFuncCall] = [:]
    
    private var name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    func registerMock(_ fn: String, responses: [Any?]? = nil) {
        mockedFuncs[fn] = MockedFuncCall(name: fn, responses: responses)
    }
    
    func verify(_ fn: String, called: VerifyCount = .atLeastOnce) {
        if let mockedFunc = mockedFuncs[fn] {
            mockedFunc.verify(called: called)
        } else if case .never = called {
            
        } else {
            XCTFail("Method \(fn) not called")
        }
    }
    
    func paramCaptured(_ fn: String, position: Int = 0) -> [String:Any?]? {
        if let mock = mockedFuncs[fn] {
            return mock.getCapturedParams(position: position)
        }
        return nil
    }

    func call(_ fn: String, params: [String:Any?]? = nil) -> Any? {
        if let mockedFunc = mockedFuncs[fn] {
            
            return mockedFunc.call(params: params)
        }
        registerMock(fn)
        return call(fn)
    }
    
    func verifyNoMoreInteractions() {
        mockedFuncs.values.forEach { $0.verifyNoMoreInteractions(className: name) }
    }
}

enum VerifyCount {
    case atLeastOnce
    case moreThan(Int)
    case lessThan(Int)
    case exact(Int)
    case never
}

class MockedFuncCall {
    
    private var name: String
    private var count: Int = 0
    private var responses: [Any?]?
    private var paramList: [[String:Any?]?] = []
    private var verifiedCount = 0
    
    init(name: String, responses: [Any?]?) {
        self.name = name
        self.responses = responses
    }
    
    private func getCurrentResponse() -> Any? {
        if let responses = responses, count > responses.count {
            return responses[responses.count - 1]
        }
        return responses?[count] ?? nil
    }
    
    func call(params: [String:Any?]?) -> Any? {
        let response = getCurrentResponse()
        paramList.append(params)
        count += 1
        return response
    }
    
    func getCapturedParams(position: Int) -> [String:Any?]? {
        if position > paramList.count {
            return nil
        }
        return paramList[position]
    }
    
    func verify(called: VerifyCount = .atLeastOnce) {
        switch called {
        case .atLeastOnce:
            verifiedCount += 1
            if count < 1 {
                XCTFail("Func \(name) not called at least once: \( count)")
            }
        case .moreThan(let times):
            verifiedCount += times
            if count <= times {
                XCTFail("Func \(name) not called more than \(times) times: \( count) ")
            }
        case .lessThan(let times):
            verifiedCount += times
            if count >= times {
                XCTFail("Func \(name) not called less than \(times) times: \( count)")
            }
        case .exact(let times):
            verifiedCount += times
            if count != times {
                XCTFail("Func \(name) not called \(times) times: \( count)")
            }
        case .never:
            if count > 0 {
                XCTFail("Func \(name) is called and it souldn't: \( count)")
            }
        }
    }
    
    func verifyNoMoreInteractions(className: String?) {
        let className = className ?? ""
        if count > verifiedCount {
            XCTFail("Func \(className).\(name) received more interactions: \(count) than verified \(verifiedCount)")
        }
    }
    
}
