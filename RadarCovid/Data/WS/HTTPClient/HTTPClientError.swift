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

enum HTTPClientError: LocalizedError, Equatable {
    case notConfigured
    case invalidResponse
    case noData
    case invalidData
    case unknown

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "HTTPClient is not configured."
        case .invalidResponse: return "HTTPClient reports invalid response."
        case .noData: return "HTTPClient reports there's no data to parse."
        case .invalidData: return "HTTPClient reports cannot parse data."
        case .unknown: return "HTTPClient reports unknown."
        }
    }
}

func == (lhs: HTTPClientError, rhs: HTTPClientError) -> Bool {
    return lhs.errorDescription == rhs.errorDescription
}

func == (lhs: LocalizedError, rhs: HTTPClientError) -> Bool {
    return lhs.errorDescription == rhs.errorDescription
}

func == (lhs: Error, rhs: HTTPClientError) -> Bool {
    return lhs.localizedDescription == rhs.errorDescription
}
