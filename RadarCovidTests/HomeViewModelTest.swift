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

class HomeViewModelTest: XCTestCase {
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    
    private var expositionCheckUseCase: MockExpositionCheckUseCase!
    
    private var sut: HomeViewModel!

    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        sut = HomeViewModel()
        expositionCheckUseCase = MockExpositionCheckUseCase()
        sut.expositionCheckUseCase = expositionCheckUseCase
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        expositionCheckUseCase.resetMock()
    }

    func testCheckShowBackToHealthyDialogWhenNotChanged() throws {
        
        let observer = scheduler.createObserver(Bool.self)
        
        expositionCheckUseCase.justChanged = false
        
        sut?.showBackToHealthyDialog
            .subscribeOn(scheduler)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        sut?.checkShowBackToHealthyDialog()
        
        XCTAssertEqual( observer.events.count, 1)
        XCTAssertEqual( observer.events[0].value.element, false)

    }
    
    func testCheckShowBackToHealthyDialogWhenChanged() throws {
        
        let observer = scheduler.createObserver(Bool.self)

        expositionCheckUseCase.justChanged = true
        
        sut?.showBackToHealthyDialog
            .subscribeOn(scheduler)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        sut?.checkShowBackToHealthyDialog()
        
        XCTAssertEqual( observer.events.count, 1)
        XCTAssertEqual( observer.events[0].value.element, true)

    }

}
