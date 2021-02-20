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
import RxTest
import RxSwift

@testable import Radar_COVID

class AnalyticsUseCaseTests: XCTestCase {
    
    private let disposeBag = DisposeBag()
    
    private var sut: AnalyticsUseCase?
    
    private var deviceTokenHandler: DeviceTokenHandler?
    private var analyticsRepository: AnalyticsRepository?
    private var kpiApi: AppleKpiControllerAPI?
    private var exposureKpiUseCase: ExposureKpiUseCase?
    private var settingsRepository: SettingsRepository?

    override func setUpWithError() throws {
        sut = AnalyticsUseCase(deviceTokenHandler: deviceTokenHandler!, analyticsRepository: analyticsRepository!, kpiApi: kpiApi!, exposureKpiUseCase: exposureKpiUseCase!, settingsRepository: settingsRepository!)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
