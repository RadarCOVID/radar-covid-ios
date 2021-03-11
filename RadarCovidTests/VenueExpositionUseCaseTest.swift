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

class VenueExpositionUseCaseTest: XCTestCase {
    
    private var disposeBag: DisposeBag!
    
    private var sut: VenueExpositionUseCaseImpl!
    
    private var scheduler: TestScheduler!
    
    private var venueRecordRepository: VenueRecordRepositoryMock!

    override func setUpWithError() throws {
        self.disposeBag = DisposeBag()
        venueRecordRepository = VenueRecordRepositoryMock()
        sut = VenueExpositionUseCaseImpl(venueRecordRepository: venueRecordRepository)
        self.scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetExpositionInfoWithNoVenuesThenHealthy() throws {
        
        let observer = scheduler.createObserver(VenueExpositionInfo.self)
        
        venueRecordRepository.registerGetVisited(response: nil, scheduler: scheduler)
        
        sut.expositionInfo
            .subscribeOn(scheduler)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
    
        XCTAssertEqual(observer.events, [.next(1, VenueExpositionInfo(level: .healthy))])
        
    }
    
    func testGetExpositionInfoWithNoExposedVenuesThenHealthy() throws {
        
        var venueRecords: [VenueRecord] = []
        
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdFresh", hidden: false, exposed: false, name: "name",
                                        checkInDate: Calendar.current.date(byAdding: .hour, value: -24 * 2 - 6, to: Date()),
                                        checkOutDate: Calendar.current.date(byAdding: .hour, value: -24 * 2 + 1, to: Date())))
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdFresh1", hidden: false, exposed: false, name: "name",
                                        checkInDate: Calendar.current.date(byAdding: .hour, value: -36, to: Date()),
                                        checkOutDate: Calendar.current.date(byAdding: .hour, value: -12, to: Date())))

        
        venueRecordRepository.registerGetVisited(response: venueRecords, scheduler: scheduler)
        
        let observer = scheduler.createObserver(VenueExpositionInfo.self)
        
        sut.expositionInfo
            .subscribeOn(scheduler)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, [.next(1, VenueExpositionInfo(level: .healthy))])

    
    }
    
    func testGetExpositionInfoWithVenueMix() throws {
        
        let firstCheckout = Calendar.current.date(byAdding: .hour, value: -24, to: Date())
        let lastCheckout = Calendar.current.date(byAdding: .hour, value: -16, to: Date())
        
        var venueRecords: [VenueRecord] = []
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdFresh", hidden: false, exposed: false, name: "name",
                                        checkInDate: Calendar.current.date(byAdding: .hour, value: -24 * 2 - 6, to: Date()),
                                        checkOutDate: Calendar.current.date(byAdding: .hour, value: -24 * 2 + 1, to: Date())))
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdExposed1", hidden: false, exposed: true, name: "name",
                                        checkInDate: Calendar.current.date(byAdding: .hour, value: -36, to: Date()),
                                        checkOutDate: lastCheckout))
        venueRecords.append(VenueRecord(qr: "", checkOutId: "IdExposed2", hidden: false, exposed: true, name: "name",
                                        checkInDate: Calendar.current.date(byAdding: .hour, value: -36, to: Date()),
                                        checkOutDate: firstCheckout))
        
        venueRecordRepository.registerGetVisited(response: venueRecords, scheduler: scheduler)
        
        let observer = scheduler.createObserver(VenueExpositionInfo.self)
        
        sut.expositionInfo
            .subscribeOn(scheduler)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, [.next(1, VenueExpositionInfo(level: .exposed, since: lastCheckout))])
        

    }



}
