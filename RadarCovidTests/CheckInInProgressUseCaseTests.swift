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

class CheckInInProgressUseCaseTests: XCTestCase {
    
    private var sut: CheckInInProgressUseCaseImpl!
    
    private var venueRecordRepository: VenueRecordRepositoryMock!
    private var notificationHandler: NotificationHandlerMock!
    private var appStateHandler: AppStateHandlerMock!
    private var qrCheckRepository: QrCheckRepositoryMock!

    override func setUpWithError() throws {
        venueRecordRepository = VenueRecordRepositoryMock()
        notificationHandler = NotificationHandlerMock()
        appStateHandler = AppStateHandlerMock()
        qrCheckRepository = QrCheckRepositoryMock()
        sut = CheckInInProgressUseCaseImpl(notificationHandler: notificationHandler,
                                           venueRecordRepository: venueRecordRepository,
                                           qrCheckRepository: qrCheckRepository,
                                           appStateHandler: appStateHandler)
    }

    override func tearDownWithError() throws {

    }

    func testNOCheckinInprogress() throws {
        
        venueRecordRepository.registerGetCurrentVenue(response: nil)
        
        try! sut.checkStauts().toBlocking().first()
        
        venueRecordRepository.verifyGetCurrentVenue()
        
        verifyNoMoreInteractionsAll()

    }
    
    func testCheckinInprogressNOTOutdated() throws {
        sut.maxCheckInHours = 1
        venueRecordRepository.registerGetCurrentVenue(response:
                    VenueRecord(qr: "", checkOutId: "", hidden: false, exposed: false, name: "",
                                checkInDate: Calendar.current.date(byAdding: .minute, value: -10, to: Date())!,
                                checkOutDate: nil))
        
        appStateHandler.registerGetState(response: .background)
        
        try! sut.checkStauts().toBlocking().first()
        
        venueRecordRepository.verifyGetCurrentVenue()
        qrCheckRepository.verifyGetLastReminder()
        
        verifyNoMoreInteractionsAll()
        
    }
    
    func testCheckinInprogressOutdatedThenAuthomaticCheckout() throws {
        sut.maxCheckInHours = 1
        
        let venueRecord = VenueRecord(qr: "", checkOutId: "", hidden: false, exposed: false, name: "",
                                      checkInDate: Calendar.current.date(byAdding: .minute, value: -61, to: Date())!,
                                      checkOutDate: nil)
        venueRecordRepository.registerGetCurrentVenue(response: venueRecord)
        venueRecordRepository.registerSaveVisit(response: venueRecord)
        appStateHandler.registerGetState(response: .background)
        
        try! sut.checkStauts().toBlocking().first()
        
        venueRecordRepository.verifyGetCurrentVenue()
        venueRecordRepository.verifyRemoveCurrent()
        venueRecordRepository.verifySaveVisit()
        qrCheckRepository.verifyGetLastReminder()
        
        let savedVisit = venueRecordRepository.paramCaptured("saveVisit")!["visit"] as! VenueRecord
        
        XCTAssertNotNil(savedVisit.checkOutDate)
        if #available(iOS 13.0, *) {
            XCTAssertTrue(savedVisit.checkOutDate!.distance(to: Date()) < 1.0)
        }
        
        verifyNoMoreInteractionsAll()
        
    }
    
    func testCheckInInprogressOutdatedAndAppInForegroundThenSkipCheckout() throws {
        sut.maxCheckInHours = 1
        
        let venueRecord = VenueRecord(qr: "", checkOutId: "", hidden: false, exposed: false, name: "",
                                      checkInDate: Calendar.current.date(byAdding: .minute, value: -61, to: Date())!,
                                      checkOutDate: nil)
        venueRecordRepository.registerGetCurrentVenue(response: venueRecord)
        venueRecordRepository.registerSaveVisit(response: venueRecord)
        
        appStateHandler.registerGetState(response: .active)
        
        try! sut.checkStauts().toBlocking().first()
        
        venueRecordRepository.verifyGetCurrentVenue()
        qrCheckRepository.verifyGetLastReminder()
        
        verifyNoMoreInteractionsAll()
        
    }
    
    func testSendReminderNoPreviousReminderAndCheckInExpired() throws {
        sut.reminderIntervalHours = 1
        venueRecordRepository.registerGetCurrentVenue(response:
                    VenueRecord(qr: "", checkOutId: "", hidden: false, exposed: false, name: "",
                                checkInDate: Calendar.current.date(byAdding: .minute, value: -60, to: Date())!,
                                checkOutDate: nil))
        
        appStateHandler.registerGetState(response: .background)
        
        try! sut.checkStauts().toBlocking().first()
        
        venueRecordRepository.verifyGetCurrentVenue()
        qrCheckRepository.verifyGetLastReminder()
        notificationHandler.verifyScheduleCheckInReminderNotification()
        
        verifyNoMoreInteractionsAll()
        
    }
    
    func testSendReminderNoPreviousReminderAndCheckInNOTExpired() throws {
        sut.reminderIntervalHours = 1
        venueRecordRepository.registerGetCurrentVenue(response:
                    VenueRecord(qr: "", checkOutId: "", hidden: false, exposed: false, name: "",
                                checkInDate: Calendar.current.date(byAdding: .minute, value: -59, to: Date())!,
                                checkOutDate: nil))
        
        appStateHandler.registerGetState(response: .background)
        
        try! sut.checkStauts().toBlocking().first()
        
        venueRecordRepository.verifyGetCurrentVenue()
        qrCheckRepository.verifyGetLastReminder()
        notificationHandler.verifyScheduleCheckInReminderNotification(called: .never)
        
        verifyNoMoreInteractionsAll()
    }
    
    func testSendReminderWithPreviousReminderExpired() throws {
        sut.reminderIntervalHours = 1
        venueRecordRepository.registerGetCurrentVenue(response:
                    VenueRecord(qr: "", checkOutId: "", hidden: false, exposed: false, name: "",
                                checkInDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date())!,
                                checkOutDate: nil))
        
        appStateHandler.registerGetState(response: .background)
        
        qrCheckRepository.registerGetLastReminder(date: Calendar.current.date(byAdding: .minute, value: -60, to: Date())!)
        
        try! sut.checkStauts().toBlocking().first()
        
        venueRecordRepository.verifyGetCurrentVenue()
        qrCheckRepository.verifyGetLastReminder()
        notificationHandler.verifyScheduleCheckInReminderNotification()
        
        verifyNoMoreInteractionsAll()
    }
    
    func testSendReminderWithPreviousReminderNotExpired() throws {
        sut.reminderIntervalHours = 1
        venueRecordRepository.registerGetCurrentVenue(response:
                    VenueRecord(qr: "", checkOutId: "", hidden: false, exposed: false, name: "",
                                checkInDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date())!,
                                checkOutDate: nil))
        
        appStateHandler.registerGetState(response: .background)
        
        qrCheckRepository.registerGetLastReminder(date: Calendar.current.date(byAdding: .minute, value: -59, to: Date())!)
        
        try! sut.checkStauts().toBlocking().first()
        
        venueRecordRepository.verifyGetCurrentVenue()
        qrCheckRepository.verifyGetLastReminder()
        notificationHandler.verifyScheduleCheckInReminderNotification(called: .never)
        
        verifyNoMoreInteractionsAll()
    }
        
    
    
    private func verifyNoMoreInteractionsAll() {
        venueRecordRepository.verifyNoMoreInteractions()
        notificationHandler.verifyNoMoreInteractions()
    }

}

class AppStateHandlerMock : Mocker, AppStateHandler {
    
    init() {
        super.init("AppStateHandlerMock")
    }
    
    var state: UIApplication.State {
        get {
            call("getState") as! UIApplication.State
        }
    }
    
    func registerGetState(response: UIApplication.State) {
        registerMock("getState", responses: [response])
    }
    
    func verifyGetState() {
        verify("getState")
    }
    
}

class QrCheckRepositoryMock: Mocker, QrCheckRepository {

    init() {
        super.init("QrCheckRepositoryMock")
    }
    
    
    func getLastReminder() -> Date? {
        self.call("getLastReminder") as! Date?
    }
    
    func save(lastReminder: Date) {
        self.call("saveLastReminder", params: ["lastReminder": lastReminder])
    }
    
    func getSyncTag() -> String? {
        self.call("getSyncTag") as! String?
    }
    
    func save(syncTag: String?) {
        self.call("saveSyncTag", params: ["syncTag": syncTag])
    }
    
    func registerGetSyncTag(syncTag: String?) {
        registerMock("getSyncTag", responses: [syncTag])
    }
    
    func registerGetLastReminder(date: Date) {
        registerMock("getLastReminder", responses: [date])
    }
    
    func verifyGetLastReminder() {
        verify("getLastReminder")
    }
    
    func verifySaveSyncTag() {
        verify("saveSyncTag")
    }
    
}
