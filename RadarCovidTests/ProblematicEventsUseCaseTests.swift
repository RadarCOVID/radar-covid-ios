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
import CrowdNotifierSDK


@testable import Radar_COVID

class ProblematicEventsUseCaseTests: XCTestCase {
    
    private var sut: ProblematicEventsUseCaseImpl!
    
    private var venueRecordRepository: VenueRecordRepositoryMock!
    private var venueNotifier: VenueNotifierMock!
    private var problematicEvensApi: ProblematicEventsApiMock!
    private var notificationHandler: NotificationHandlerMock!
    private var qrCheckRepository: QrCheckRepositoryMock!
    private var settingsRepository: MockSettingsRepository!
    private var venueExpositionUseCase: VenueExpositionUseCaseMock!
    
    override func setUpWithError() throws {
        
        venueRecordRepository = VenueRecordRepositoryMock()
        venueNotifier = VenueNotifierMock(baseUrl: "")
        problematicEvensApi = ProblematicEventsApiMock()
        notificationHandler = NotificationHandlerMock()
        qrCheckRepository = QrCheckRepositoryMock()
        settingsRepository = MockSettingsRepository()
        venueExpositionUseCase = VenueExpositionUseCaseMock()
        
        sut = ProblematicEventsUseCaseImpl(venueRecordRepository: venueRecordRepository, qrCheckRepository: qrCheckRepository, venueNotifier: venueNotifier, problematicEventsApi: problematicEvensApi, notificationHandler: notificationHandler, settingsRepository: settingsRepository, venueExpositionUseCase: venueExpositionUseCase)
    }

    override func tearDownWithError() throws {
        
    }

    func testSyncWithNoProblematicEvents() throws {
        
        problematicEvensApi.registerGetProblematicsEvents(.just(ProblematicEventData(problematicEvents: [])))
        venueNotifier.registerCheckForMatches(response: [])
        
        try! sut.sync().toBlocking().first()
        
        problematicEvensApi.verifyGetProblematicsEvents()

    }
    
    func testSyncWithProblematicsEventsNoMatch() throws {
        
        var problematicEvents: [ProblematicEvent] = []
        problematicEvents.append(ProblematicEvent())
        problematicEvensApi.registerGetProblematicsEvents(.just(ProblematicEventData(problematicEvents:problematicEvents)))
        
        venueNotifier.registerCheckForMatches(response: [])
        
        try! sut.sync().toBlocking().first()
        
        let params = venueNotifier.paramCaptured("checkForMatches")
        XCTAssertEqual(params!["problematicEvents"] as! [ProblematicEvent], problematicEvents)
        
        problematicEvensApi.verifyGetProblematicsEvents()
        venueNotifier.verifyCheckForMatches()
        
        verifyNoMoreInteractionsAll()
    }
    
    func testSyncWithMixOfEvents() throws {
        
        sut.maxMinutesToKeep = 2 * 24 * 60
        
        var problematicEvents: [ProblematicEvent] = []
        problematicEvents.append(ProblematicEvent())
        problematicEvents.append(ProblematicEvent())
        problematicEvensApi.registerGetProblematicsEvents(.just(ProblematicEventData(problematicEvents:problematicEvents)))
        
        var exposedEvents: [ExposureEvent] = []
        exposedEvents.append(getExposureEvent(checkinId: "IdFreshExposed"))
        exposedEvents.append(getExposureEvent(checkinId: "IdFreshExposedNotified"))
        exposedEvents.append(getExposureEvent(checkinId: "IdOutdatedExposed"))
        venueNotifier.registerCheckForMatches(response: exposedEvents)
        
        
        var venueRecords: [VenueRecord] = []
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdOutdated", hidden: false, exposed: false, name: "name",
                                checkInDate: Calendar.current.date(byAdding: .hour, value: -24 * 4 - 6, to: Date())!,
                                checkOutDate: Calendar.current.date(byAdding: .hour, value: -24 * 4, to: Date())))
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdOutdatedExposed", hidden: false, exposed: false, name: "name",
                                        checkInDate: Calendar.current.date(byAdding: .hour, value: -24 * 3 - 6, to: Date())!,
                                        checkOutDate: Calendar.current.date(byAdding: .hour, value: -24 * 3, to: Date())))
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdFresh", hidden: false, exposed: false, name: "name",
                                        checkInDate: Calendar.current.date(byAdding: .hour, value: -24 * 2 - 6, to: Date())!,
                                        checkOutDate: Calendar.current.date(byAdding: .hour, value: -24 * 2 + 1, to: Date())))
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdFreshExposed", hidden: false, exposed: false, name: "name",
                                        checkInDate: Calendar.current.date(byAdding: .hour, value: -18, to: Date())!,
                                        checkOutDate: Calendar.current.date(byAdding: .hour, value: -24, to: Date())))
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdFreshExposedNotified", hidden: false, exposed: false, notified: false, name: "name",
                                        checkInDate: Calendar.current.date(byAdding: .hour, value: -18, to: Date())!,
                                        checkOutDate: Calendar.current.date(byAdding: .hour, value: -24, to: Date())))
                            
        venueRecordRepository.registerGetVisited(response: venueRecords)
        
        try! sut.sync().toBlocking().first()
        
        problematicEvensApi.verifyGetProblematicsEvents()
        venueNotifier.verifyCheckForMatches()
        
        venueRecordRepository.verifyGetVisited()
        venueRecordRepository.verifyUpdateVisited()
        venueExpositionUseCase.verifyUpdateExpositionInfo()
        
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
        
        let notNotified = venuesParams.filter { $0.notified == false }
        XCTAssertTrue(notNotified.count == 0)
        
        verifyNoMoreInteractionsAll()
        
    }
    
    func testSyncWithAllEventsPreviouslyNotifiedDontSendNotification() throws {
        
        var problematicEvents: [ProblematicEvent] = []
        problematicEvents.append(ProblematicEvent())
        problematicEvents.append(ProblematicEvent())
        problematicEvensApi.registerGetProblematicsEvents(.just(ProblematicEventData(problematicEvents:problematicEvents)))
        
        var exposedEvents: [ExposureEvent] = []
        exposedEvents.append(getExposureEvent(checkinId: "IdFreshExposedNotified1"))
        exposedEvents.append(getExposureEvent(checkinId: "IdFreshExposedNotified2"))
        venueNotifier.registerCheckForMatches(response: exposedEvents)
        
        var venueRecords: [VenueRecord] = []
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdFreshExposedNotified1", hidden: false, exposed: false, notified: true, name: "name",
                                checkInDate: Calendar.current.date(byAdding: .hour, value: -6, to: Date())!,
                                checkOutDate: Calendar.current.date(byAdding: .hour, value: -5, to: Date())))
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdFreshExposedNotified2", hidden: false, exposed: false, notified: true, name: "name",
                                        checkInDate: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!,
                                        checkOutDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date())))
        
        venueRecordRepository.registerGetVisited(response: venueRecords)
        
        try! sut.sync().toBlocking().first()
        
        problematicEvensApi.verifyGetProblematicsEvents()
        venueNotifier.verifyCheckForMatches()
        
        venueRecordRepository.verifyGetVisited()
        venueRecordRepository.verifyUpdateVisited()
        venueExpositionUseCase.verifyUpdateExpositionInfo()
        
        notificationHandler.verifyScheduleExposedEventNotification(called: .never)
        
        verifyNoMoreInteractionsAll()
        
    }
    
    func testSyncWithAtLeastOneEventPreviouslyNotNotifiedNotifiedSendNotification() throws {
        
        var problematicEvents: [ProblematicEvent] = []
        problematicEvents.append(ProblematicEvent())
        problematicEvents.append(ProblematicEvent())
        problematicEvensApi.registerGetProblematicsEvents(.just(ProblematicEventData(problematicEvents:problematicEvents)))
        
        var exposedEvents: [ExposureEvent] = []
        exposedEvents.append(getExposureEvent(checkinId: "IdFreshExposedNotified1"))
        exposedEvents.append(getExposureEvent(checkinId: "IdFreshExposed"))
        venueNotifier.registerCheckForMatches(response: exposedEvents)
        
        var venueRecords: [VenueRecord] = []
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdFreshExposedNotified1", hidden: false, exposed: false, notified: true, name: "name",
                                checkInDate: Calendar.current.date(byAdding: .hour, value: -6, to: Date())!,
                                checkOutDate: Calendar.current.date(byAdding: .hour, value: -5, to: Date())))
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdFreshExposed", hidden: false, exposed: false, notified: false, name: "name",
                                        checkInDate: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!,
                                        checkOutDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date())))
        
        venueRecordRepository.registerGetVisited(response: venueRecords)
        
        try! sut.sync().toBlocking().first()
        
        problematicEvensApi.verifyGetProblematicsEvents()
        venueNotifier.verifyCheckForMatches()
        
        venueRecordRepository.verifyGetVisited()
        venueRecordRepository.verifyUpdateVisited()
        venueExpositionUseCase.verifyUpdateExpositionInfo()
        
        notificationHandler.verifyScheduleExposedEventNotification(called: .exact(1))
        
        verifyNoMoreInteractionsAll()
        
    }
    
    func testSyncOutdatedExposedElementIsRemovedAndNoNotificationSent() throws {
        sut.maxMinutesToKeep = 2 * 24 * 60
        
        problematicEvensApi.registerGetProblematicsEvents(.just(ProblematicEventData(problematicEvents:[ProblematicEvent()])))
        
        venueNotifier.registerCheckForMatches(response: [getExposureEvent(checkinId: "IdExposedOudated")])
        
        venueRecordRepository.registerGetVisited(response: [
            VenueRecord(qr: "", checkOutId: "IdExposedOudated", hidden: false, exposed: false, name: "name",
                                checkInDate: Calendar.current.date(byAdding: .hour, value: -24 * 4 - 6, to: Date())!,
                                checkOutDate: Calendar.current.date(byAdding: .hour, value: -24 * 4, to: Date()))
        ])
        
        try! sut.sync().toBlocking().first()
        
        problematicEvensApi.verifyGetProblematicsEvents()
        venueNotifier.verifyCheckForMatches()
        
        venueRecordRepository.verifyGetVisited()
        venueRecordRepository.verifyUpdateVisited()
        venueExpositionUseCase.verifyUpdateExpositionInfo()
        
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
    
    func testGivenNoPreviousTagStoredCallGetProblematicEventsWithNilTagAndStoreNewTag() throws {
        
        problematicEvensApi.registerGetProblematicsEvents(.just(ProblematicEventData(problematicEvents:[], tag: "TAG")))
        
        venueNotifier.registerCheckForMatches(response: [])
        
        venueRecordRepository.registerGetVisited(response: [])
        
        venueRecordRepository.registerUpdateVisited(response: [])
        
        try! sut.sync().toBlocking().first()
        
        problematicEvensApi.verifyGetProblematicsEvents()
        qrCheckRepository.verifySaveSyncTag()
        
        let tag = problematicEvensApi.paramCaptured("getProblematicEvents")!["tag"]!
        XCTAssertNil(tag)
        
        
        let savedTag = qrCheckRepository.paramCaptured("saveSyncTag")!["syncTag"] as! String
        XCTAssertEqual(savedTag, "TAG")
        
    }
    
    func testGivenPreviousTagStoredCallGetProblematicEventsWithThatTagAndStoreNewTag() throws {
        
        qrCheckRepository.registerGetSyncTag(syncTag: "TAG")
        
        problematicEvensApi.registerGetProblematicsEvents(.just(ProblematicEventData(problematicEvents:[], tag: "NEWTAG")))
        
        venueNotifier.registerCheckForMatches(response: [])
        
        venueRecordRepository.registerGetVisited(response: [])
        
        venueRecordRepository.registerUpdateVisited(response: [])
        
        try! sut.sync().toBlocking().first()
        
        problematicEvensApi.verifyGetProblematicsEvents()
        qrCheckRepository.verifySaveSyncTag()
        
        let tag = problematicEvensApi.paramCaptured("getProblematicEvents")!["tag"] as! String
        XCTAssertEqual("TAG", tag)
        
        
        let savedTag = qrCheckRepository.paramCaptured("saveSyncTag")!["syncTag"] as! String
        XCTAssertEqual(savedTag, "NEWTAG")
        
    }
    
    private func verifyNoMoreInteractionsAll() {
        venueRecordRepository.verifyNoMoreInteractions()
        venueNotifier.verifyNoMoreInteractions()
        problematicEvensApi.verifyNoMoreInteractions()
        notificationHandler.verifyNoMoreInteractions()
        venueExpositionUseCase.verifyNoMoreInteractions()
    }
    
    func getExposureEvent(checkinId: String) -> ExposureEvent {
        let decoder = JSONDecoder()
        let json = """
        {
            "checkinId": "\(checkinId)",
            "arrivalTime" : 1,
            "departureTime" : 1,
            "message": ""
        }
        """
        return try! decoder.decode(ExposureEvent.self, from:  json.data(using: .utf8)!)

       
    }

}

class ProblematicEventsApiMock : Mocker, ProblematicEventsApi {
    
    init() {
        super.init("ProblematicEventsApiMock")
    }
    
    func getProblematicEvents(tag: String?) -> Observable<ProblematicEventData> {
        Observable.just(Void()).flatMap { () -> Observable<ProblematicEventData> in
            self.call("getProblematicEvents", params: ["tag": tag]) as! Observable<ProblematicEventData>
        }
    }
    
    func registerGetProblematicsEvents(_ events: Observable<ProblematicEventData>) {
        registerMock("getProblematicEvents", responses: [events] )
    }
    
    func verifyGetProblematicsEvents() {
        verify("getProblematicEvents")
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
    
    func scheduleNotification(expositionInfo: ContactExpositionInfo) {
        call("scheduleNotificationExpositionInfo", params: ["expositionInfo": expositionInfo])
    }
    
    func scheduleExposedEventNotification() {
        call("scheduleExposedEventNotification")
    }
    
    func scheduleCheckInReminderNotification() {
        call("scheduleCheckInReminderNotification")
    }
    
    func verifyScheduleExposedEventNotification(called: VerifyCount = .atLeastOnce) {
        verify("scheduleExposedEventNotification", called: called)
    }
    
    func verifyScheduleCheckInReminderNotification(called: VerifyCount = .atLeastOnce) {
        verify("scheduleCheckInReminderNotification", called: called)
    }
    
}

class VenueExpositionUseCaseMock: Mocker, VenueExpositionUseCase {
    
    init() {
        super.init("VenueExpositionUseCaseMock")
    }
    
    var expositionInfo: Observable<VenueExpositionInfo> {
        get {
            call("expositionInfoGet") as! Observable<VenueExpositionInfo>
        }
        set {
        
        }
    }
    
    func updateExpositionInfo() {
        call("updateExpositionInfo")
    }
    
    func verifyUpdateExpositionInfo() {
        verify("updateExpositionInfo")
    }
    
    
}
