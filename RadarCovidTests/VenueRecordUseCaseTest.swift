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

class VenueRecordUseCaseTest: XCTestCase {
    
    private var sut : VenueRecordUseCase!
    
    private var venueRecorRepository: VenueRecordRepositoryMock!
    private var venueNotifier: VenueNotifierMock!

    override func setUpWithError() throws {
        venueRecorRepository = VenueRecordRepositoryMock()
        venueNotifier = VenueNotifierMock(baseUrl: "")
        sut = VenueRecordUseCaseImpl(venueRecordRepository: venueRecorRepository,
                                     venueNotifier: venueNotifier)
    }

    override func tearDownWithError() throws {
        
    }

    func testCheckOutWithCurrentVenueAndWellFormedQR() throws {
        
        let current = Date()
        let intial = Date().addingTimeInterval(-1000)
        let venueRecord = VenueRecord(qr: "", checkIn: intial, checkOut: nil)
        let venueInfo = VenueInfo(name: "Name")
        
        venueNotifier.registerGetInfo(response: .just(venueInfo))
        venueNotifier.registerCheckOut(response: .just(venueInfo))
        venueRecorRepository.registerGetCurrentVenue(response: venueRecord)
        
        try! sut.checkOut(date: current).toBlocking().first()
        
        venueNotifier.verifyCheckout()
        venueNotifier.verifyGetInfo()
        
        var params = venueNotifier.paramCaptured("checkOut")!
        XCTAssertEqual(params["arrival"] as! Date, intial)
        XCTAssertEqual(params["departure"] as! Date, current)
        
        params = venueNotifier.paramCaptured("getInfo")!
        XCTAssertEqual(params["qrCode"] as! String, "")
        
        venueRecorRepository.verifyGetCurrentVenue()
        venueRecorRepository.verifyRemoveCurrent()
        
        venueRecorRepository.verifyNoMoreInteractions()
        venueNotifier.verifyNoMoreInteractions()
        
    }
    
    func testCheckoutWithNoCheckIn() {
        let current = Date()
        
        venueRecorRepository.registerGetCurrentVenue(response: nil)
        
        do {
            try sut.checkOut(date: current).toBlocking().first()
            XCTFail("No error received")
        } catch {
            
        }
        venueNotifier.verifyGetInfo(called: .never)
        venueNotifier.verifyCheckout(called: .never)
        venueRecorRepository.verifyRemoveCurrent(called: .never)
        venueRecorRepository.verifyGetCurrentVenue()
        
        venueRecorRepository.verifyNoMoreInteractions()
        venueNotifier.verifyNoMoreInteractions()
    }
    
    func testGetInfoError() {
        
        let current = Date()
        let intial = Date().addingTimeInterval(-1000)
        let venueRecord = VenueRecord(qr: "", checkIn: intial, checkOut: nil)

        venueRecorRepository.registerGetCurrentVenue(response: venueRecord)
        venueNotifier.registerGetInfo(response: .error(VenueNotifierError.invalidQR))
        
        do {
            try sut.checkOut(date: current).toBlocking().first()
            XCTFail("No error received")
        } catch {
            
        }
        
        venueNotifier.verifyCheckout(called: .never)
        venueRecorRepository.verifyRemoveCurrent(called: .never)
        venueRecorRepository.verifyGetCurrentVenue()
        venueNotifier.verifyGetInfo()
        
        venueRecorRepository.verifyNoMoreInteractions()
        venueNotifier.verifyNoMoreInteractions()
    }
    
    func testErrorCheckOut() {
        
        let current = Date()
        let intial = Date().addingTimeInterval(-1000)
        let venueRecord = VenueRecord(qr: "", checkIn: intial, checkOut: nil)
        let venueInfo = VenueInfo(name: "Name")
        
        venueRecorRepository.registerGetCurrentVenue(response: venueRecord)
        venueNotifier.registerGetInfo(response: .just(venueInfo))
        venueNotifier.registerCheckOut(response: .error(VenueNotifierError.invalidQR))
        
        do {
            try sut.checkOut(date: current).toBlocking().first()
            XCTFail("No error received")
        } catch {
            
        }
        
        venueNotifier.verifyCheckout()
        venueRecorRepository.verifyGetCurrentVenue()
        venueRecorRepository.verifyRemoveCurrent(called: .never)
        venueNotifier.verifyGetInfo()
        
        venueRecorRepository.verifyNoMoreInteractions()
        venueNotifier.verifyNoMoreInteractions()
    }

}
