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

class AnalyticsTokenTest: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func testGenerateNew() throws {
        let token = AnalyticsToken.generateNew()
        
        XCTAssertEqual(token.value.count , AnalyticsToken.tokenLength)
        
        XCTAssertGreaterThan(token.expirationDate, Date().addingTimeInterval(30*24*60*60))
    }
    
    func testExpired() throws {
        let token = AnalyticsToken(value: "", expirationDate: Date().addingTimeInterval(-1000), validated: false)
        XCTAssertTrue(token.isExpired())
    }
    
    func testNewNotExpired() throws {
        let token = AnalyticsToken.generateNew()
        XCTAssertFalse(token.isExpired())
    }

}
