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

class ExpositionCheckUseCaseTest: XCTestCase {
    
    private let disposeBag = DisposeBag()
    
    private var sut: ExpositionCheckUseCase?
    
    private var expositionInfoRepository : MockExpositionInfoRepository?
    private var settingsRepository: MockSettingsRepository?
    private var resetdataUseCase: MockResetDataUseCase?

    override func setUpWithError() throws {
        expositionInfoRepository = MockExpositionInfoRepository()
        settingsRepository = MockSettingsRepository()
        resetdataUseCase = MockResetDataUseCase()
        sut = ExpositionCheckUseCase(expositionInfoRepository: expositionInfoRepository!, settingsRepository: settingsRepository!, resetDataUseCase: resetdataUseCase!)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testcheckExposedToHealthyWithHealtyState() throws {
        resetMocks()
        expositionInfoRepository!.expositionInfo = ExpositionInfo(level: .healthy)
        
        sut?.checkExposedToHealthy().subscribe(onNext: { result in
            XCTAssertFalse(result)
            XCTAssertEqual(self.resetdataUseCase?.exposureDaysCalls, 0)
        }, onError: { error in
            XCTFail("Error \(error)")
        }).disposed(by: disposeBag)
        
    }
    
    func testcheckExposedToHealthyWithHealtyStateWithExposedAndNotOutdated() {
        resetMocks()
        var exposition = ExpositionInfo(level: .exposed)
        exposition.since = Date()
        expositionInfoRepository!.expositionInfo = exposition
        
        let settings = Settings()
        let timeBetweenStates = TimeBetweenStatesDto(highRiskToLowRisk: 10, infectedToHealthy: nil)
        settings.parameters = SettingsDto(responseDate: nil, exposureConfiguration: nil, minRiskScore: nil, minDurationForExposure: nil, riskScoreClassification: nil, attenuationDurationThresholds: nil, attenuationFactor: nil, applicationVersion: nil, timeBetweenStates: timeBetweenStates)
        
        settingsRepository?.settings = settings
        
        sut?.checkExposedToHealthy().subscribe(onNext: { result in
            XCTAssertFalse(result)
            XCTAssertEqual(self.resetdataUseCase?.exposureDaysCalls, 0)
        }, onError: { error in
            XCTFail("Error \(error)")
        }).disposed(by: disposeBag)
        
    }
    
    func testcheckExposedToHealthyWithHealtyStateWithExposedAndOutdated() {
        resetMocks()
        var exposition = ExpositionInfo(level: .exposed)
        exposition.since = Date().addingTimeInterval(-11 * 60)
        expositionInfoRepository!.expositionInfo = exposition
        
        let settings = Settings()
        let timeBetweenStates = TimeBetweenStatesDto(highRiskToLowRisk: 10, infectedToHealthy: nil)
        settings.parameters = SettingsDto(responseDate: nil, exposureConfiguration: nil, minRiskScore: nil, minDurationForExposure: nil, riskScoreClassification: nil, attenuationDurationThresholds: nil, attenuationFactor: nil, applicationVersion: nil, timeBetweenStates: timeBetweenStates)
        
        settingsRepository?.settings = settings
        
        sut?.checkExposedToHealthy().subscribe(onNext: { result in
            XCTAssertTrue(result)
            XCTAssertEqual(self.resetdataUseCase?.exposureDaysCalls, 1)
        }, onError: { error in
            XCTFail("Error \(error)")
        }).disposed(by: disposeBag)
        
    }
    
        
    
    func resetMocks() {
        expositionInfoRepository?.resetMock()
        settingsRepository?.resetMock()
        resetdataUseCase?.resetMock()
    }


}
