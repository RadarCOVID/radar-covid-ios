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

import RxBlocking
import RxTest
import RxSwift

@testable import Radar_COVID

class HomeViewModelTest: XCTestCase {
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag = DisposeBag()
    
    private var sut: HomeViewModel?
    
    private var expositionInfoRepository: MockExpositionInfoRepository?
    private var settingsReporitory: SettingsRepository?
    
    private var resetDataUseCase: MockResetDataUseCase?

    override func setUpWithError() throws {
        scheduler = TestScheduler(initialClock: 0)
        sut = HomeViewModel()
        expositionInfoRepository = MockExpositionInfoRepository()
        settingsReporitory = UserDefaultsSettingsRepository()
        resetDataUseCase = MockResetDataUseCase()
        sut?.expositionCheckUseCase = ExpositionCheckUseCase(
            expositionInfoRepository: expositionInfoRepository!,
            settingsRepository: settingsReporitory!,
            resetDataUseCase: resetDataUseCase!)
    }

    override func tearDownWithError() throws {
        resetDataUseCase?.resetMock()
        expositionInfoRepository?.resetMock()
    }

    func testCheckShowBackToHealthyDialogWhenNotChanged() throws {
        
        let observer = scheduler.createObserver(Bool.self)

        expositionInfoRepository?.setChangedToHealthy(changed: false)
        
        sut?.showBackToHealthyDialog
            .subscribeOn(scheduler)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        sut?.checkShowBackToHealthyDialog()
        
        XCTAssertEqual( observer.events.count, 0)

    }
    
    func testCheckShowBackToHealthyDialogWhenChanged() throws {
        
        let observer = scheduler.createObserver(Bool.self)

        expositionInfoRepository?.setChangedToHealthy(changed: true)
        
        sut?.showBackToHealthyDialog
            .subscribeOn(scheduler)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        sut?.checkShowBackToHealthyDialog()
        
        XCTAssertEqual( observer.events.count, 1)
        XCTAssertEqual( observer.events[0].value.element, true)
        XCTAssertEqual(expositionInfoRepository?.changedToHealthy, false)

    }

}
