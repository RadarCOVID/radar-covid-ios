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
import ExposureNotification
import DP3TSDK

@testable import Radar_COVID

class ErrorHandlerTest: XCTestCase {
    
    private var sut: ErrorHandlerImpl?
    
    private var alertController: AlertControllerMock?
    private var errorRecorder: ErrorRecorderMock?

    override func setUpWithError() throws {
        setupUp(verbose: false)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        resetMocks()
    }
    
    private func setupUp(verbose: Bool) {
        errorRecorder = ErrorRecorderMock()
        alertController = AlertControllerMock()
        sut = ErrorHandlerImpl(verbose: verbose)
        sut?.alertDelegate = alertController
        sut?.errorRecorder = errorRecorder
    }

    func testNilNoInteraction() throws {
        sut?.handle(error: nil)
        XCTAssertEqual(self.alertController?.showAlertOkCalls, 0)
        XCTAssertEqual(self.errorRecorder?.recordCalls, 0)
        
    }

    func testNoShowAlertAndRegisterWithGennericError() throws {
        let error = GenericError()
        sut?.handle(error: error)
        XCTAssertEqual(self.alertController?.showAlertOkCalls, 0)
        XCTAssertEqual(self.errorRecorder?.recordCalls, 1)
        XCTAssertTrue(self.errorRecorder?.error as AnyObject? === error)
    }
    
    func testShowAlertInsufficientMemory() throws {
        genericTest(enError: ENError.init(ENError.insufficientMemory), showMessage: 1)
        XCTAssertEqual(self.alertController?.message, "ALERT_INSUFFICIENT_MEMORY_ERROR".localized)
        XCTAssertEqual(self.alertController?.title, "ALERT_GENERIC_ERROR_TITLE".localized)
    }
    
    func testShowAlertBluetoothOff() throws {
        genericTest(enError: ENError.init(ENError.bluetoothOff), showMessage: 1)
        XCTAssertEqual(self.alertController?.message, "ALERT_BLUETOOTH_ERROR".localized)
        XCTAssertEqual(self.alertController?.title, "ALERT_GENERIC_ERROR_TITLE".localized)
    }
    
    func testShowAlertInduficientStorage() throws {
        genericTest(enError: ENError.init(ENError.insufficientStorage), showMessage: 1)
        XCTAssertEqual(self.alertController?.message, "ALERT_INSUFFICIENT_STORAGE_ERROR".localized)
        XCTAssertEqual(self.alertController?.title, "ALERT_GENERIC_ERROR_TITLE".localized)
    }
    
    func testNoShowAlertENError() throws {
        genericTest(enError: ENError.init(ENError.rateLimited), showMessage: 0)
    }
    
    func testShowAlertAndRegisterWithGennericErrorVerbose() throws {
        setupUp(verbose: true)
        let error = GenericError()
        sut?.handle(error: error)
        XCTAssertEqual(self.alertController?.showAlertOkCalls, 1)
    }
    
    func testShowAlertENErrorVerbose() throws {
        setupUp(verbose: true)
        genericTest(enError: ENError.init(ENError.rateLimited), showMessage: 1)
    }

    private func genericTest(enError: ENError, showMessage: Int) {
        let error = DP3TTracingError.exposureNotificationError(error: enError)
        sut?.handle(error: error)
        XCTAssertEqual(self.alertController?.showAlertOkCalls, showMessage)
        XCTAssertEqual(self.errorRecorder?.recordCalls, 1)
        let recorded: DP3TTracingError = self.errorRecorder!.error as! DP3TTracingError
        if case DP3TTracingError.exposureNotificationError(error: let err) = recorded {
            XCTAssertEqual(enError.code, (err as! ENError).code)
        } else {
            XCTFail("No EnError \(recorded)")
        }
        
    }
    
    class GenericError: Error {
        
    }
    
    private func resetMocks() {
        alertController?.resetMock()
        errorRecorder?.resetMock()
    }

}
