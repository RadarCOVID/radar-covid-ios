//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import Foundation

import UIKit
import ExposureNotification
import DP3TSDK
import Logging

protocol ErrorHandler {
    func handle(error: Error?)
    var alertDelegate: AlertController? { get set }
}

protocol ErrorRecorder {
    func record(error: Error)
}

class ErrorHandlerImpl: ErrorHandler {

    weak var alertDelegate: AlertController?

    var errorRecorder: ErrorRecorder?

    private let verbose: Bool

    init(verbose: Bool) {
        self.verbose = verbose
    }

    func handle(error: Error?) {

        guard let error = error else {
            return
        }
        errorRecorder?.record(error: error)

        guard let dp3tError = error as? DP3TTracingError else {
            showIfVervose(error, error.localizedDescription)
            return
        }

        switch dp3tError {
        case let .networkingError(error: wrappedError):

             switch wrappedError {
             case let .networkSessionError(netErr as NSError)
                where netErr.code == -999 && netErr.domain == NSURLErrorDomain:
                 showIfVervose(dp3tError, "Network Error")
             case let .HTTPFailureResponse(status: status, data: _) where (502 ... 504).contains(status):
                 showIfVervose(dp3tError, "Network Error 500")
             case .networkSessionError:
                 showIfVervose(dp3tError, "Network Error Session")
             case .timeInconsistency:
                 showIfVervose(dp3tError, "Time Inconsistency")
             default:
                 showIfVervose(dp3tError, "Unexpected")
             }
        case let .exposureNotificationError(error: expError as ENError):
            handle(enError: expError)
        case .cancelled:
            showIfVervose(dp3tError, "Cancelled")
        default:
            showIfVervose(dp3tError, "Unexpected")
        }

    }

    private func handle(enError: ENError) {
        if enError.code == ENError.Code.insufficientMemory {
            showError(enError, "ALERT_INSUFFICIENT_MEMORY_ERROR")
        } else if enError.code == ENError.Code.insufficientStorage {
            showError(enError, "ALERT_INSUFFICIENT_STORAGE_ERROR")
        } else if enError.code == ENError.Code.bluetoothOff {
            showError(enError, "ALERT_BLUETOOTH_ERROR")
        } else {
            showIfVervose(enError, "ENError: \(enError.code.rawValue)")
        }
    }

    private func showError(_ error: Error, _ description: String) {
        debugPrint(description + " \(error)")
        alertDelegate?.showAlertOk(title: "ALERT_GENERIC_ERROR_TITLE".localized,
                                   message: description,
                                   buttonTitle: "ALERT_OK_BUTTON".localized, nil)
    }

    private func showIfVervose(_ error: Error, _ description: String) {
        if verbose {
            showError(error, "DEBUG_ERROR: \(description)")
        }
    }

}

class ErrorRecorderImpl: ErrorRecorder {
    
    private let logger = Logger(label: "ErrorRecorderImpl")
    
    func record(error: Error) {
        logger.error("Error \(error)")
    }
}
