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

@testable import Radar_COVID

class ExpositionKpiUseCaseTests: XCTestCase {
    
    var sut : ExposureKpiUseCase?
    
    var expositionInfoRepository : ExpositionInfoRepositoryMock?
    var exposureKpiRepository: ExposureKpiRepositoryMock?
    
    let dateFormatter = DateFormatter()
    
    override func setUpWithError() throws {
        
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        expositionInfoRepository = ExpositionInfoRepositoryMock()
        
        exposureKpiRepository = ExposureKpiRepositoryMock()
        
        sut = ExposureKpiUseCaseImpl(expositionInfoRepository: expositionInfoRepository!,
                                 exposureKpiRepository: exposureKpiRepository!)
    }

    override func tearDownWithError() throws {
        exposureKpiRepository!.resetMock()
        expositionInfoRepository!.resetMock()
    }

    func testGivenHelthyReturnDummyKpiAndResetRecord() throws {
        
        expositionInfoRepository?.expositionInfo = ExpositionInfo(level: .healthy)
        
        let kpi = sut!.getExposureKpi()
        
        XCTAssertEqual(expositionInfoRepository!.expositionInfoCalls, 1)
        XCTAssertEqual(kpi.value, 0)
        XCTAssertNil(kpi.timestamp)
        
        XCTAssertEqual(exposureKpiRepository!.saveCalls, 1)
        XCTAssertNil(exposureKpiRepository!.date)
        
    }

    func testGivenNotPreviousStateReturnDummyKpiAndResetRecord() throws {
        
        let kpi = sut!.getExposureKpi()
        
        XCTAssertEqual(expositionInfoRepository!.expositionInfoCalls, 1)
        XCTAssertEqual(kpi.value, 0)
        XCTAssertNil(kpi.timestamp)

        
    }
    
    func testGivenExposedAndNotPreviousDateReturnExposedKpiAndRegisterCurrentDate() throws {
        
        let date = Date()
        expositionInfoRepository?.expositionInfo = ExpositionInfo(level: .exposed)
        expositionInfoRepository?.expositionInfo?.since = date
        
        let kpi = sut!.getExposureKpi()
        
        XCTAssertEqual(expositionInfoRepository!.expositionInfoCalls, 1)
        XCTAssertEqual(kpi.value, 1)
        XCTAssertEqual(kpi.timestamp, dateFormatter.string(from:date))
        
        XCTAssertEqual(exposureKpiRepository?.saveCalls, 1)
        XCTAssertEqual(exposureKpiRepository?.date, date)

    }
    
    func testGivenExposedAndPreviousDateEqualReturnDummy() throws {
        let date = Date()
        expositionInfoRepository?.expositionInfo = ExpositionInfo(level: .exposed)
        expositionInfoRepository?.expositionInfo?.since = date
        
        exposureKpiRepository?.date = date
        
        let kpi = sut!.getExposureKpi()
        
        XCTAssertEqual(expositionInfoRepository!.expositionInfoCalls, 1)
        XCTAssertEqual(kpi.value, 0)
        XCTAssertEqual(kpi.timestamp, dateFormatter.string(from:date))
    }
    
    func testGivenExposedAndPreviousDateDifferentReturnExposedKpiAndRegisterCurrentDate() throws {
        let date = Date()
        expositionInfoRepository?.expositionInfo = ExpositionInfo(level: .exposed)
        expositionInfoRepository?.expositionInfo?.since = date
        
        exposureKpiRepository?.date = date.addingTimeInterval(-1000)
        
        let kpi = sut!.getExposureKpi()
        
        XCTAssertEqual(expositionInfoRepository!.expositionInfoCalls, 1)
        XCTAssertEqual(kpi.value, 1)
        XCTAssertEqual(kpi.timestamp, dateFormatter.string(from:date))
        
        XCTAssertEqual(exposureKpiRepository?.saveCalls, 1)
        XCTAssertEqual(exposureKpiRepository?.date, date)
    }


}
