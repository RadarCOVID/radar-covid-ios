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

class ProblematicEventsUseCaseTest: XCTestCase {
    
    private var sut: ProblematicEventsUseCaseImpl!
    
    private var venueRecordRepository: VenueRecordRepositoryMock!
    private var venueNotifier: VenueNotifierMock!
    private var problematicEvensApi: ProblematicEventsApiMock!
    private var notificationHandler: NotificationHandlerMock!
    
    override func setUpWithError() throws {
        
        venueRecordRepository = VenueRecordRepositoryMock()
        venueNotifier = VenueNotifierMock(baseUrl: "")
        problematicEvensApi = ProblematicEventsApiMock()
        notificationHandler = NotificationHandlerMock()
        
        sut = ProblematicEventsUseCaseImpl(venueRecordRepository: venueRecordRepository, venueNotifier: venueNotifier, problematicEventsApi: problematicEvensApi, notificationHandler: notificationHandler)
    }

    override func tearDownWithError() throws {
        
    }

    func testSyncWithNoProblematicEvents() throws {
        
        problematicEvensApi.registerGetProblematicsEvents(.just([]))
        venueNotifier.registerCheckForMatches(response: [])
        
        try! sut.sync().toBlocking().first()
        
        problematicEvensApi.verifyGetProblematicsEvents()

    }
    
    func testSyncWithProblematicsEventsNoMatch() throws {
        
        var problematicEvents: [ProblematicEvent] = []
        problematicEvents.append(ProblematicEvent(identity: "data".data(using: .utf8)!))
        problematicEvensApi.registerGetProblematicsEvents(.just(problematicEvents))
        
        venueNotifier.registerCheckForMatches(response: [])
        
        try! sut.sync().toBlocking().first()
        
        let params = venueNotifier.paramCaptured("checkForMatches")
        XCTAssertEqual(params!["problematicEvents"] as! [ProblematicEvent], problematicEvents)
        
        problematicEvensApi.verifyGetProblematicsEvents()
        venueNotifier.verifyCheckForMatches()
        
        verifyNoMoreInteractionsAll()
    }
    
    func testSyncWithMixOfEvents() throws {
        
        sut.maxDaysToKeep = 2
        
        var problematicEvents: [ProblematicEvent] = []
        problematicEvents.append(ProblematicEvent(identity: "data".data(using: .utf8)!))
        problematicEvents.append(ProblematicEvent(identity: "data2".data(using: .utf8)!))
        problematicEvensApi.registerGetProblematicsEvents(.just(problematicEvents))
        
        var exposedEvents: [ExposedEvent] = []
        exposedEvents.append(ExposedEvent(checkOutId: "IdFreshExposed"))
        exposedEvents.append(ExposedEvent(checkOutId: "IdOutdatedExposed"))
        venueNotifier.registerCheckForMatches(response: exposedEvents)
        
        
        var venueRecords: [VenueRecord] = []
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdOutdated", hidden: false, exposed: false, name: "name",
                                checkInDate: Calendar.current.date(byAdding: .hour, value: -24 * 4 - 6, to: Date()),
                                checkOutDate: Calendar.current.date(byAdding: .hour, value: -24 * 4, to: Date()))
        )
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdOutdatedExposed", hidden: false, exposed: false, name: "name",
                                        checkInDate: Calendar.current.date(byAdding: .hour, value: -24 * 3 - 6, to: Date()),
                                        checkOutDate: Calendar.current.date(byAdding: .hour, value: -24 * 3, to: Date()))
        )
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdFresh", hidden: false, exposed: false, name: "name",
                                        checkInDate: Calendar.current.date(byAdding: .hour, value: -24 * 2 - 6, to: Date()),
                                        checkOutDate: Calendar.current.date(byAdding: .hour, value: -24 * 2 + 1, to: Date()))
        )
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdFreshExposed", hidden: false, exposed: false, name: "name",
                                        checkInDate: Calendar.current.date(byAdding: .hour, value: -18, to: Date()),
                                        checkOutDate: Calendar.current.date(byAdding: .hour, value: -24, to: Date()))
        )
        venueRecordRepository.registerGetVisited(response: venueRecords)
        
        try! sut.sync().toBlocking().first()
        
        problematicEvensApi.verifyGetProblematicsEvents()
        venueNotifier.verifyCheckForMatches()
        
        venueRecordRepository.verifyGetVisited()
        venueRecordRepository.verifyUpdateVisited()
        
        notificationHandler.verifyScheduleExposedEventNotification(called: .exact(1))
        
        let eventsParams = venueNotifier.paramCaptured("checkForMatches")!["problematicEvents"] as! [ProblematicEvent]
        XCTAssertEqual(eventsParams , problematicEvents)
        
        let venuesParams = venueRecordRepository.paramCaptured("updateVisited")!["visited"] as! [VenueRecord]
        
        // Outdated have been deleted
        XCTAssertNil(venuesParams.first { vr in
            vr.checkOutId == "IdOutdated" || vr.checkOutId == "IdOutdatedExposed"
        })
        
        let exposed = venuesParams.first { vr in
            vr.checkOutId == "IdFreshExposed"
        }
        XCTAssertTrue(exposed!.exposed)
        
        let notExposed = venuesParams.first { vr in
            vr.checkOutId == "IdFresh"
        }
        XCTAssertFalse(notExposed!.exposed)
        
        verifyNoMoreInteractionsAll()
        
    }
    
    func testSyncOutdatedExposedElementIsRemovedAndNoNotificationSent() throws {
        sut.maxDaysToKeep = 2
        
        problematicEvensApi.registerGetProblematicsEvents(.just([ProblematicEvent(identity: "data".data(using: .utf8)!)]))
        
        venueNotifier.registerCheckForMatches(response: [ExposedEvent(checkOutId: "IdExposedOudated")])
        
        venueRecordRepository.registerGetVisited(response: [
            VenueRecord(qr: "", checkOutId: "IdExposedOudated", hidden: false, exposed: false, name: "name",
                                checkInDate: Calendar.current.date(byAdding: .hour, value: -24 * 4 - 6, to: Date()),
                                checkOutDate: Calendar.current.date(byAdding: .hour, value: -24 * 4, to: Date()))
        ])
        
        try! sut.sync().toBlocking().first()
        
        problematicEvensApi.verifyGetProblematicsEvents()
        venueNotifier.verifyCheckForMatches()
        
        venueRecordRepository.verifyGetVisited()
        venueRecordRepository.verifyUpdateVisited()
        
        notificationHandler.verifyScheduleExposedEventNotification(called: .never)
        
        let venuesParams = venueRecordRepository.paramCaptured("updateVisited")!["visited"] as! [VenueRecord]
        
        XCTAssertTrue(venuesParams.isEmpty)
        
        verifyNoMoreInteractionsAll()
        
    }
    
    func testGetProblematicEventsError() throws {
        
        let apiError = ErrorResponse.error(500, nil, "")
        problematicEvensApi.registerGetProblematicsEvents(.error(apiError))
        
        do {
            try sut.sync().toBlocking().first()
            XCTFail("No error received")
        } catch is ErrorResponse {
            
        } catch {
            XCTFail("Incorrect error \(error)")
        }
        
        problematicEvensApi.verifyGetProblematicsEvents()
        
        verifyNoMoreInteractionsAll()
    }
    
    private func verifyNoMoreInteractionsAll() {
        venueRecordRepository.verifyNoMoreInteractions()
        venueNotifier.verifyNoMoreInteractions()
        problematicEvensApi.verifyNoMoreInteractions()
        notificationHandler.verifyNoMoreInteractions()
    }

}

class ProblematicEventsApiMock : ProblematicEventsApi {
    
    private let mocker: Mocker
    
    override init() {
        mocker = Mocker("ProblematicEventsApiMock")
        super.init()
    }
    
    override func getProblematicEvents() -> Observable<[ProblematicEvent]> {
        Observable.just(Void()).flatMap { () -> Observable<[ProblematicEvent]> in
            self.mocker.call("getProblematicEvents") as! Observable<[ProblematicEvent]>
        }
    }
    
    func registerGetProblematicsEvents(_ events: Observable<[ProblematicEvent]>) {
        mocker.registerMock("getProblematicEvents", responses: [events] )
    }
    
    func verifyGetProblematicsEvents() {
        mocker.verify("getProblematicEvents")
    }
    
    func verifyNoMoreInteractions() {
        mocker.verifyNoMoreInteractions()
    }
}

class NotificationHandlerMock: Mocker, NotificationHandler {
    
    init() {
        super.init("NotificationHandlerMock")
    }
    
    func setupNotifications() -> Observable<Bool> {
        .empty()
    }
    
    func scheduleNotification(title: String, body: String, sound: UNNotificationSound) {
        call("scheduleNotification", params: ["title": title, "body": body, "sound": sound])
    }
    
    func scheduleNotification(expositionInfo: ExpositionInfo) {
        call("scheduleNotificationExpositionInfo", params: ["expositionInfo": expositionInfo])
    }
    
    func scheduleExposedEventNotification() {
        call("scheduleExposedEventNotification")
    }
    
    func verifyScheduleExposedEventNotification(called: VerifyCount = .atLeastOnce) {
        verify("scheduleExposedEventNotification", called: called)
    }
    
}
