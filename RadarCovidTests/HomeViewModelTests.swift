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

class HomeViewModelTests: XCTestCase {
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    
    private var expositionCheckUseCase: ExpositionCheckUseCaseMock!
    private var expositionUseCase: ExpositionUseCaseMock!
    private var radarStatusUseCase: RadarStatusUseCaseMock!
    private var problematicEventUseCase: ProblematicEventsUseCaseMock!
    private var reminderNotificationUseCase: ReminderNotificationUseCaseMock!
    
    private var sut: HomeViewModel!

    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        sut = HomeViewModel()
        expositionCheckUseCase = ExpositionCheckUseCaseMock()
        radarStatusUseCase = RadarStatusUseCaseMock()
        expositionUseCase = ExpositionUseCaseMock(scheduler: scheduler)
        problematicEventUseCase = ProblematicEventsUseCaseMock()
        reminderNotificationUseCase = ReminderNotificationUseCaseMock()
        
        sut.expositionUseCase = expositionUseCase
        sut.expositionCheckUseCase = expositionCheckUseCase
        sut.radarStatusUseCase = radarStatusUseCase
        sut.problematicEventsUseCase = problematicEventUseCase
        sut.reminderNotificationUseCase = reminderNotificationUseCase
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
    
    func testShowOnlyOneExpositionWhenBothHealty() throws {
        
        let observerContact = scheduler.createObserver(Bool.self)
        let observerVenue = scheduler.createObserver(Bool.self)
        
        let expositionInfo = ExpositionInfo(contact: ContactExpositionInfo(level: .healthy), venue: VenueExpositionInfo(level: .healthy))
        expositionUseCase.registerGetExpositionInfo(response: expositionInfo)
        
        sut.checkInitial()
        
        sut.hideContactExpositionInfo
            .subscribeOn(scheduler).subscribe(observerContact)
            .disposed(by: disposeBag)
        
        sut.hideVenueExpositionInfo
            .subscribeOn(scheduler).subscribe(observerVenue)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observerContact.events, [.next(1, false)])
        XCTAssertEqual(observerVenue.events, [.next(1, true)])
        
    }
    
    func testContacExposedAndVenueHealthyThenShowOnlyContact() throws {
        
        let observerContact = scheduler.createObserver(Bool.self)
        let observerVenue = scheduler.createObserver(Bool.self)
        
        let expositionInfo = ExpositionInfo(contact: ContactExpositionInfo(level: .exposed), venue: VenueExpositionInfo(level: .healthy))
        expositionUseCase.registerGetExpositionInfo(response: expositionInfo)
        
        sut.checkInitial()
        
        sut.hideContactExpositionInfo
            .subscribeOn(scheduler).subscribe(observerContact)
            .disposed(by: disposeBag)
        
        sut.hideVenueExpositionInfo
            .subscribeOn(scheduler).subscribe(observerVenue)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observerContact.events, [.next(1, false)])
        XCTAssertEqual(observerVenue.events, [.next(1, true)])
    
    }
    
    func testVenueExposedAndContactHealthyThenShowOnlyVenue() throws {
        
        let observerContact = scheduler.createObserver(Bool.self)
        let observerVenue = scheduler.createObserver(Bool.self)
        
        let expositionInfo = ExpositionInfo(contact: ContactExpositionInfo(level: .healthy), venue: VenueExpositionInfo(level: .exposed))
        expositionUseCase.registerGetExpositionInfo(response: expositionInfo)
        
        sut.checkInitial()
        
        sut.hideContactExpositionInfo
            .subscribeOn(scheduler).subscribe(observerContact)
            .disposed(by: disposeBag)
        
        sut.hideVenueExpositionInfo
            .subscribeOn(scheduler).subscribe(observerVenue)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observerContact.events, [.next(1, true)])
        XCTAssertEqual(observerVenue.events, [.next(1, false)])
        
    }
    
    func testContacInfectedAndVenueExposedThenShowOnlyContact() throws {
        
        let observerContact = scheduler.createObserver(Bool.self)
        let observerVenue = scheduler.createObserver(Bool.self)
        
        let expositionInfo = ExpositionInfo(contact: ContactExpositionInfo(level: .infected), venue: VenueExpositionInfo(level: .exposed))
        expositionUseCase.registerGetExpositionInfo(response: expositionInfo)
        
        sut.checkInitial()
        
        sut.hideContactExpositionInfo
            .subscribeOn(scheduler).subscribe(observerContact)
            .disposed(by: disposeBag)
        
        sut.hideVenueExpositionInfo
            .subscribeOn(scheduler).subscribe(observerVenue)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observerContact.events, [.next(1, false)])
        XCTAssertEqual(observerVenue.events, [.next(1, true)])
        
    }

}

class ExpositionUseCaseMock: Mocker, ExpositionUseCase {
    
    private let scheduler: TestScheduler
    
    init(scheduler: TestScheduler) {
        self.scheduler = scheduler
        super.init("ExpositionUseCase")
    }
    
    var lastSync: Date? {
        get {
            self.call("lastSync") as? Date
        }
    }
    
    func getExpositionInfo() -> Observable<ExpositionInfo> {
        self.call("getExpositionInfo") as! Observable<ExpositionInfo>
    }
    
    func updateExpositionInfo() {
        self.call("updateExpositionInfo")
    }
    
    func registerGetExpositionInfo(response: ExpositionInfo) {
        registerMock("getExpositionInfo", responses: [scheduler.createColdObservable([.next(1,response)]).asObservable()])
    }
    
    
}

class RadarStatusUseCaseMock : Mocker, RadarStatusUseCase {
    init() {
        super.init("RadarStatusUseCaseMock")
    }
    func isTracingActive() -> Bool {
        (self.call("isTracingActive") ?? false) as! Bool
    }
    
    func changeTracingStatus(active: Bool) -> Observable<RadarStatus> {
        (self.call("changeTracingStatus") ?? Observable<RadarStatus>.empty()) as! Observable<RadarStatus>
    }
    
    func restoreLastStateAndSync() -> Observable<RadarStatus> {
        (self.call("restoreLastStateAndSync")  ?? Observable<RadarStatus>.empty()) as! Observable<RadarStatus>
    }
    
    func isTracingInit() -> Bool {
        (self.call("isTracingInit") ?? false) as! Bool
    }
    
    
}

class ReminderNotificationUseCaseMock: ReminderNotificationUseCase {
    
    func cancel() {
        
    }
    
    func start(_ timerInterval: Int64?) {
        
    }
    
    
}
