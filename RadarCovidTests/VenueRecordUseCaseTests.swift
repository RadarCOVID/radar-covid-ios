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
import CrowdNotifierSDK

@testable import Radar_COVID

class VenueRecordUseCaseTests: XCTestCase {
    
    private var sut : VenueRecordUseCase!
    
    private var venueRecordRepository: VenueRecordRepositoryMock!
    private var venueNotifier: VenueNotifierMock!

    override func setUpWithError() throws {
        venueRecordRepository = VenueRecordRepositoryMock()
        venueNotifier = VenueNotifierMock(baseUrl: "")
        sut = VenueRecordUseCaseImpl(venueRecordRepository: venueRecordRepository,
                                     venueNotifier: venueNotifier)
    }

    override func tearDownWithError() throws {
        
    }

    func testCheckOutWithCurrentVenueAndWellFormedQR() throws {
        
        let currentDate = Date()
        let intialDate = Date().addingTimeInterval(-1000)
        let venueRecord = VenueRecord(qr: "qr", checkInDate: intialDate, checkOutDate: nil)
        let venueInfo = getVenueInfo(name: "Name")
        
        venueNotifier.registerGetInfo(response: .just(venueInfo))
        venueNotifier.registerCheckOut(response: .just("checkOutId"))
        venueRecordRepository.registerGetCurrentVenue(response: venueRecord)
        venueRecordRepository.registerSaveVisit(response: venueRecord)
        
        try! sut.checkOut(date: currentDate, isPlusSelected: false).toBlocking().first()
        
        venueNotifier.verifyCheckout()
        venueNotifier.verifyGetInfo()
        venueRecordRepository.verifySaveVisit()
        
        var params = venueNotifier.paramCaptured("checkOut")!
        XCTAssertEqual(params["arrival"] as! Date, intialDate)
        XCTAssertEqual(params["departure"] as! Date, currentDate)
        
        params = venueNotifier.paramCaptured("getInfo")!
        XCTAssertEqual(params["qrCode"] as! String, "qr")
        
        let savedVisit = venueRecordRepository.paramCaptured("saveVisit")!["visit"] as! VenueRecord
        XCTAssertEqual(savedVisit.name, "Name")
        XCTAssertEqual(savedVisit.checkOutId, "checkOutId")
        XCTAssertEqual(savedVisit.checkInDate, intialDate)
        XCTAssertEqual(savedVisit.checkOutDate, currentDate)
        
        venueRecordRepository.verifyGetCurrentVenue()
        venueRecordRepository.verifyRemoveCurrent()
        
        venueRecordRepository.verifyNoMoreInteractions()
        venueNotifier.verifyNoMoreInteractions()
        
    }
    
    func testCheckoutWithNoCheckIn() {
        let current = Date()
        
        venueRecordRepository.registerGetCurrentVenue(response: nil)
        
        do {
            try sut.checkOut(date: current, isPlusSelected: false).toBlocking().first()
            XCTFail("No error received")
        } catch {
            
        }
        venueNotifier.verifyGetInfo(called: .never)
        venueNotifier.verifyCheckout(called: .never)
        venueRecordRepository.verifyRemoveCurrent(called: .never)
        venueRecordRepository.verifyGetCurrentVenue()
        
        venueRecordRepository.verifyNoMoreInteractions()
        venueNotifier.verifyNoMoreInteractions()
    }
    
    func testGetInfoError() {
        
        let current = Date()
        let intial = Date().addingTimeInterval(-1000)
        let venueRecord = VenueRecord(qr: "", checkInDate: intial, checkOutDate: nil)

        venueRecordRepository.registerGetCurrentVenue(response: venueRecord)
        venueNotifier.registerGetInfo(response: .error(CrowdNotifierError.invalidQRCode))
        
        do {
            try sut.checkOut(date: current, isPlusSelected: false).toBlocking().first()
            XCTFail("No error received")
        } catch {
            
        }
        
        venueNotifier.verifyCheckout(called: .never)
        venueRecordRepository.verifyRemoveCurrent(called: .never)
        venueRecordRepository.verifyGetCurrentVenue()
        venueNotifier.verifyGetInfo()
        
        venueRecordRepository.verifyNoMoreInteractions()
        venueNotifier.verifyNoMoreInteractions()
    }
    
    func testErrorCheckOut() {
        
        let current = Date()
        let intial = Date().addingTimeInterval(-1000)
        let venueRecord = VenueRecord(qr: "", checkInDate: intial, checkOutDate: nil)
        let venueInfo = getVenueInfo(name: "name")
        
        venueRecordRepository.registerGetCurrentVenue(response: venueRecord)
        venueNotifier.registerGetInfo(response: .just(venueInfo))
        venueNotifier.registerCheckOut(response: .error(CrowdNotifierError.invalidQRCode))
        
        do {
            try sut.checkOut(date: current, isPlusSelected: false).toBlocking().first()
            XCTFail("No error received")
        } catch {
            
        }
        
        venueNotifier.verifyCheckout()
        venueRecordRepository.verifyGetCurrentVenue()
        venueRecordRepository.verifyRemoveCurrent(called: .never)
        venueNotifier.verifyGetInfo()
        
        venueRecordRepository.verifyNoMoreInteractions()
        venueNotifier.verifyNoMoreInteractions()
    }
    
    func testCheckOutWithNoCheckIn() {
        let current = Date()
        
        do {
            try sut.checkOut(date: current, isPlusSelected: false).toBlocking().first()
        } catch is VenueRecordError {
        
        } catch {
            XCTFail("Incorrect error \(error)")
        }
       
        venueNotifier.verifyCheckout(called: .never)
        venueNotifier.verifyGetInfo(called: .never)
        
    }
    

    func getVenueInfo(name: String) -> VenueInfo {
        let decoder = JSONDecoder()
        return try! decoder.decode(VenueInfo.self, from: "{\"masterPublicKey\": \"\", \"nonce1\": \"\", \"nonce2\": \"\",\"notificationKey\": \"\", \"name\": \"\(name)\", \"location\": \"\", \"room\": \"\", \"venueType\": \"OTHER\", \"validFrom\": 1, \"validTo\": 1}".data(using: .utf8)!)
    }
    


}
