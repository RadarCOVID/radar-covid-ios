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

    override func setUpWithError() throws {
        venueRecordRepository = VenueRecordRepositoryMock()
        notificationHandler = NotificationHandlerMock()
        sut = CheckInInProgressUseCaseImpl(notificationHandler: notificationHandler,
                                           venueRecordRepository: venueRecordRepository)
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
                                checkInDate: Calendar.current.date(byAdding: .minute, value: -10, to: Date()),
                                checkOutDate: nil))
        
        try! sut.checkStauts().toBlocking().first()
        
        venueRecordRepository.verifyGetCurrentVenue()
        venueRecordRepository.verifyGetLastReminder()
        
        verifyNoMoreInteractionsAll()
        
    }
    
    func testCheckinInprogressOutdated() throws {
        sut.maxCheckInHours = 1
        
        let venueRecord = VenueRecord(qr: "", checkOutId: "", hidden: false, exposed: false, name: "",
                                      checkInDate: Calendar.current.date(byAdding: .minute, value: -61, to: Date()),
                                      checkOutDate: nil)
        venueRecordRepository.registerGetCurrentVenue(response: venueRecord)
        venueRecordRepository.registerSaveVisit(response: venueRecord)
        
        try! sut.checkStauts().toBlocking().first()
        
        venueRecordRepository.verifyGetCurrentVenue()
        venueRecordRepository.verifyRemoveCurrent()
        venueRecordRepository.verifySaveVisit()
        
        let savedVisit = venueRecordRepository.paramCaptured("saveVisit")!["visit"] as! VenueRecord
        
        XCTAssertNotNil(savedVisit.checkOutDate)
        if #available(iOS 13.0, *) {
            XCTAssertTrue(savedVisit.checkOutDate!.distance(to: Date()) < 1.0)
        }
        
    }
    
    func testSendReminderNoPreviousReminderAndCheckInExpired() throws {
        sut.reminderIntervalHours = 1
        venueRecordRepository.registerGetCurrentVenue(response:
                    VenueRecord(qr: "", checkOutId: "", hidden: false, exposed: false, name: "",
                                checkInDate: Calendar.current.date(byAdding: .minute, value: -60, to: Date()),
                                checkOutDate: nil))
        
        try! sut.checkStauts().toBlocking().first()
        
        venueRecordRepository.verifyGetCurrentVenue()
        venueRecordRepository.verifyGetLastReminder()
        notificationHandler.verifyScheduleCheckInReminderNotification()
        
        verifyNoMoreInteractionsAll()
        
    }
    
    func testSendReminderNoPreviousReminderAndCheckInNOTExpired() throws {
        sut.reminderIntervalHours = 1
        venueRecordRepository.registerGetCurrentVenue(response:
                    VenueRecord(qr: "", checkOutId: "", hidden: false, exposed: false, name: "",
                                checkInDate: Calendar.current.date(byAdding: .minute, value: -59, to: Date()),
                                checkOutDate: nil))
        
        try! sut.checkStauts().toBlocking().first()
        
        venueRecordRepository.verifyGetCurrentVenue()
        venueRecordRepository.verifyGetLastReminder()
        notificationHandler.verifyScheduleCheckInReminderNotification(called: .never)
        
        verifyNoMoreInteractionsAll()
    }
    
    func testSendReminderWithPreviousReminderExpired() throws {
        sut.reminderIntervalHours = 1
        venueRecordRepository.registerGetCurrentVenue(response:
                    VenueRecord(qr: "", checkOutId: "", hidden: false, exposed: false, name: "",
                                checkInDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date()),
                                checkOutDate: nil))
        
        venueRecordRepository.registerGetLastReminder(date: Calendar.current.date(byAdding: .minute, value: -60, to: Date())!)
        
        try! sut.checkStauts().toBlocking().first()
        
        venueRecordRepository.verifyGetCurrentVenue()
        venueRecordRepository.verifyGetLastReminder()
        notificationHandler.verifyScheduleCheckInReminderNotification()
        
        verifyNoMoreInteractionsAll()
    }
    
    func testSendReminderWithPreviousReminderNotExpired() throws {
        sut.reminderIntervalHours = 1
        venueRecordRepository.registerGetCurrentVenue(response:
                    VenueRecord(qr: "", checkOutId: "", hidden: false, exposed: false, name: "",
                                checkInDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date()),
                                checkOutDate: nil))
        
        venueRecordRepository.registerGetLastReminder(date: Calendar.current.date(byAdding: .minute, value: -59, to: Date())!)
        
        try! sut.checkStauts().toBlocking().first()
        
        venueRecordRepository.verifyGetCurrentVenue()
        venueRecordRepository.verifyGetLastReminder()
        notificationHandler.verifyScheduleCheckInReminderNotification(called: .never)
        
        verifyNoMoreInteractionsAll()
    }
        
    
    
    private func verifyNoMoreInteractionsAll() {
        venueRecordRepository.verifyNoMoreInteractions()
        notificationHandler.verifyNoMoreInteractions()
    }



}
