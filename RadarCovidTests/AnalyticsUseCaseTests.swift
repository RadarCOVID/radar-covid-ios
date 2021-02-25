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

class AnalyticsUseCaseTests: XCTestCase {
    
    private var disposeBag: DisposeBag!
    
    private var sut: AnalyticsUseCase!
    
    private var deviceTokenHandler: DeviceTokenHandlerMock!
    private var analyticsRepository: AnalyticsRepositoryMock!
    private var kpiApi: AppleKpiControllerAPIMock!
    private var exposureKpiUseCase: ExposureKpiUseCaseMock!
    private var settingsRepository: MockSettingsRepository!

    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        
        kpiApi = AppleKpiControllerAPIMock()
        settingsRepository = MockSettingsRepository()
        analyticsRepository = AnalyticsRepositoryMock()
        deviceTokenHandler = DeviceTokenHandlerMock()
        exposureKpiUseCase = ExposureKpiUseCaseMock()
        
        sut = AnalyticsUseCase(deviceTokenHandler: deviceTokenHandler,
                               analyticsRepository: analyticsRepository,
                               kpiApi: kpiApi,
                               exposureKpiUseCase:exposureKpiUseCase,
                               settingsRepository: settingsRepository,
                               maxExpiredRetries: 3, maxSaveRetries: 3 ,
                               inProgressWaitTime: 1, ebo: ExponentialBackoff(base: 1.5, minDelay: 100, maxDelay: 5000))
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        resetMocks()
    }
    
    func testSendKpiIfNeverRun() throws {
        settingsRepository.settings = getSettins(timeBetweenKpi: 1)
        
        setUpMocksGenerateNotCachedTokenSaveKpiAndVerifyAuthorizedToken()
        
        let sent = try! sut.sendAnaltyics().toBlocking().first()
        
        validateSuccessInteractions()
        
        XCTAssertTrue(sent!)
    }

    func testSendKpiIfTimeBetweenKpisHasPassed() throws {
        
        setupMocksTimeHasPassed()
        
        setUpMocksGenerateNotCachedTokenSaveKpiAndVerifyAuthorizedToken()
        
        let sent = try! sut.sendAnaltyics().toBlocking().first()
        
        validateSuccessInteractions()
        
        XCTAssertTrue(sent!)
    }
    
    func testNOTSendKpiIfTimeBetweenKpisNOTHasPassed() throws {
        settingsRepository.settings = getSettins(timeBetweenKpi: 1)
        analyticsRepository.lastRun = Calendar.current.date(byAdding: .second, value: -59, to: Date())
        
        setUpMocksGenerateNotCachedTokenSaveKpiAndVerifyAuthorizedToken()
        
        let sent = try! sut.sendAnaltyics().toBlocking().first()
        
        validateFailInteractions()
        
        XCTAssertFalse(sent!)
    }
    
    func testNOTSendKpiIfTimeBetweenKpisLessThan0() throws {
        settingsRepository.settings = getSettins(timeBetweenKpi: -1)
        
        setUpMocksGenerateNotCachedTokenSaveKpiAndVerifyAuthorizedToken()
        
        let sent = try! sut.sendAnaltyics().toBlocking().first()
        
        validateFailInteractions()
        
        XCTAssertFalse(sent!)
    }
    
    func testDeviceTokenGenerationFails() throws {
        setupMocksTimeHasPassed()
        deviceTokenHandler.generateTokenValue = .error(DeviceTokenError.notSupported)
        var sent : Bool? = nil
        do {
            sent = try sut.sendAnaltyics().toBlocking().first()
        } catch DeviceTokenError.notSupported {
            debugPrint("Correct error received")
        } catch {
            XCTFail("Wrong error received \(error)")
        }
        XCTAssertNil(sent)
        XCTAssertEqual(deviceTokenHandler.generateTokenCalls, 1)
        XCTAssertEqual(kpiApi.saveKpiCalls, 0)
        XCTAssertEqual(analyticsRepository.saveCalls, 0)
        XCTAssertEqual(kpiApi.verifyTokenCalls, 0)

    }
    
    func testVerifyTokenFails() throws {
        setupMocksTimeHasPassed()
        deviceTokenHandler.generateTokenValue = .just(DeviceToken(token: Data(base64Encoded: "")!, isCached: false))
        kpiApi.verifyTokenValues = [ Observable<VerifyResponse>.error(ErrorResponse.error(-1,nil,AlamofireDecodableRequestBuilderError.emptyDataResponse))]
        var sent : Bool? = nil
        do {
            sent = try sut.sendAnaltyics().toBlocking().first()
        } catch is ErrorResponse {
            debugPrint("Correct error received")
        } catch {
            XCTFail("Wrong error received \(error)")
        }
        XCTAssertNil(sent)
        XCTAssertEqual(deviceTokenHandler.generateTokenCalls, 1)
        XCTAssertEqual(kpiApi.saveKpiCalls, 0)
        XCTAssertEqual(analyticsRepository.saveCalls, 0)
        XCTAssertEqual(kpiApi.verifyTokenCalls, 2)
    }

    func testVerifyTokenInprogress() throws {
        setupMocksTimeHasPassed()
        deviceTokenHandler.generateTokenValue = .just(DeviceToken(token: Data(base64Encoded: "")!, isCached: false))
        
        kpiApi.verifyTokenValues = [.just(.authorizationInProgress)]
        var sent : Bool? = nil
        do {
            sent = try sut.sendAnaltyics().toBlocking().first()
        } catch {

        }
        XCTAssertNil(sent)
        XCTAssertEqual(deviceTokenHandler.generateTokenCalls, 1)
        XCTAssertEqual(kpiApi.saveKpiCalls, 0)
        XCTAssertEqual(analyticsRepository.saveCalls, 0)
        XCTAssertEqual(kpiApi.verifyTokenCalls, 2)
    }
    
    func testVerifyTokenInprogressSecondTimeSuccess() throws {
        setupMocksTimeHasPassed()
        deviceTokenHandler.generateTokenValue = .just(DeviceToken(token: Data(base64Encoded: "")!, isCached: false))
        
        kpiApi.verifyTokenValues = [.just(.authorizationInProgress), .just(.authorized(token: ""))]
        kpiApi.saveKpiValues = [.just(Void())]
        
        let sent = try! sut.sendAnaltyics().toBlocking().first()
     
        XCTAssertTrue(sent!)
        XCTAssertEqual(deviceTokenHandler.generateTokenCalls, 1)
        XCTAssertEqual(kpiApi.saveKpiCalls, 1)
        XCTAssertEqual(analyticsRepository.saveCalls, 1)
        XCTAssertEqual(kpiApi.verifyTokenCalls, 2)
    }
    
    func testVerifyTokenIsExpired() throws {
        setupMocksTimeHasPassed()
        deviceTokenHandler.generateTokenValue = .just(DeviceToken(token: Data(base64Encoded: "")!, isCached: true))
        kpiApi.verifyTokenValues = [.error(ErrorResponse.error(401, Data(base64Encoded: ""), ""))]
        
        var sent : Bool? = nil
        do {
            sent = try sut.sendAnaltyics().toBlocking().first()
        } catch is ErrorResponse {
            debugPrint("Correct error received")
        }
        
        XCTAssertNil(sent)
        XCTAssertEqual(kpiApi.saveKpiCalls, 0)
        XCTAssertEqual(analyticsRepository.saveCalls, 0)
        XCTAssertEqual(deviceTokenHandler.clearCachedTokenCalls, 3) // 3 retries
        XCTAssertEqual(kpiApi.verifyTokenCalls, 4) // 3 retries and the first call
    }
    
    func testVerifyTokenIsExpiredAndThenAuthorized() throws {
        setupMocksTimeHasPassed()
        deviceTokenHandler.generateTokenValue = .just(DeviceToken(token: Data(base64Encoded: "")!, isCached: true))
        kpiApi.verifyTokenValues = [.error(ErrorResponse.error(401, Data(base64Encoded: ""), "")), .just(.authorizationInProgress), .just(.authorized(token: ""))]
        kpiApi.saveKpiValues = [.just(Void())]
        
        let sent = try sut.sendAnaltyics().toBlocking().first()

        XCTAssertTrue(sent!)
        XCTAssertEqual(kpiApi.saveKpiCalls, 1)
        XCTAssertEqual(analyticsRepository.saveCalls, 1)
        XCTAssertEqual(deviceTokenHandler.clearCachedTokenCalls, 1)
        XCTAssertEqual(kpiApi.verifyTokenCalls, 3)
    }
    
    func testTwoExpiredAndThenAuthorized() throws {
        setupMocksTimeHasPassed()
        deviceTokenHandler.generateTokenValue = .just(DeviceToken(token: Data(base64Encoded: "")!, isCached: true))
        kpiApi.verifyTokenValues = [
            .error(ErrorResponse.error(401, Data(base64Encoded: ""), "")),
            .error(ErrorResponse.error(401, Data(base64Encoded: ""), "")),
            .just(.authorizationInProgress), .just(.authorized(token: ""))]
        
        kpiApi.saveKpiValues = [.just(Void())]
        
        let sent = try sut.sendAnaltyics().toBlocking().first()

        XCTAssertTrue(sent!)
        XCTAssertEqual(kpiApi.saveKpiCalls, 1)
        XCTAssertEqual(analyticsRepository.saveCalls, 1)
        XCTAssertEqual(deviceTokenHandler.clearCachedTokenCalls, 2)
        XCTAssertEqual(kpiApi.verifyTokenCalls, 4)
    }
    
    func testErrorOnSave() throws {
        setupMocksTimeHasPassed()
        deviceTokenHandler.generateTokenValue = .just(DeviceToken(token: Data(base64Encoded: "")!, isCached: true))
        kpiApi.verifyTokenValues = [.just(.authorized(token: ""))]
        kpiApi.saveKpiValues = [.error(ErrorResponse.error(403, Data(base64Encoded: ""), ""))]
        
        var sent : Bool? = nil
        do {
            sent = try sut.sendAnaltyics().toBlocking().first()
        } catch is ErrorResponse {
            debugPrint("Correct error received")
        }
        XCTAssertNil(sent)
        XCTAssertEqual(kpiApi.saveKpiCalls, 4)
        XCTAssertEqual(analyticsRepository.saveCalls, 0)
        XCTAssertEqual(deviceTokenHandler.clearCachedTokenCalls, 0)
        XCTAssertEqual(kpiApi.verifyTokenCalls, 1)
    }
    
    func testErrorOnSaveAndThenOk() throws {
        setupMocksTimeHasPassed()
        deviceTokenHandler.generateTokenValue = .just(DeviceToken(token: Data(base64Encoded: "")!, isCached: true))
        kpiApi.verifyTokenValues = [.just(.authorized(token: ""))]
        kpiApi.saveKpiValues = [.error(ErrorResponse.error(500, Data(base64Encoded: ""), "")),
                                .just(Void())]
                                
        let sent = try sut.sendAnaltyics().toBlocking().first()

        XCTAssertTrue(sent!)
        XCTAssertEqual(kpiApi.saveKpiCalls, 2)
        XCTAssertEqual(analyticsRepository.saveCalls, 1)
        XCTAssertEqual(deviceTokenHandler.clearCachedTokenCalls, 0)
        XCTAssertEqual(kpiApi.verifyTokenCalls, 1)
    }
    
    func setupMocksTimeHasPassed() {
        settingsRepository.settings = getSettins(timeBetweenKpi: 1)
        analyticsRepository.lastRun = Calendar.current.date(byAdding: .minute, value: -1, to: Date())
    }
    
    private func setUpMocksGenerateNotCachedTokenSaveKpiAndVerifyAuthorizedToken() {
        deviceTokenHandler.generateTokenValue = .just(DeviceToken(token: Data(base64Encoded: "")!, isCached: false))
        kpiApi.saveKpiValues = [.just(Void())]
        kpiApi.verifyTokenValues = [.just(.authorized(token: ""))]
    }
    
    private func validateSuccessInteractions() {
        XCTAssertEqual(kpiApi.saveKpiCalls, 1)
        XCTAssertEqual(analyticsRepository.saveCalls, 1)
        XCTAssertEqual(kpiApi.verifyTokenCalls, 1)
        XCTAssertEqual(deviceTokenHandler.generateTokenCalls, 1)
    }
    private func validateFailInteractions() {
        XCTAssertEqual(deviceTokenHandler.generateTokenCalls, 0)
        XCTAssertEqual(kpiApi.saveKpiCalls, 0)
        XCTAssertEqual(analyticsRepository.saveCalls, 0)
        XCTAssertEqual(kpiApi.verifyTokenCalls, 0)
    }
    
    private func resetMocks() {
        kpiApi.resetMock()
        settingsRepository.resetMock()
        analyticsRepository.resetMock()
        exposureKpiUseCase.resetMock()
        deviceTokenHandler.resetMock()
    }
    
    private func getSettins(timeBetweenKpi: Int64) -> Settings {
        let settings = Settings()
        settings.parameters = SettingsDto(responseDate: nil, exposureConfiguration: nil, minRiskScore: nil, minDurationForExposure: nil, riskScoreClassification: nil, attenuationDurationThresholds: nil, attenuationFactor: nil, applicationVersion: nil, timeBetweenStates: nil, legalTermsVersion: nil, radarCovidDownloadUrl: nil, notificationReminder: nil, timeBetweenKpi: timeBetweenKpi)
        return settings
    }

}
