//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

//import Foundation
//
//public struct JSONDataEncoding: ParameterEncoding {
//    // MARK: Properties
//
//    private static let jsonDataKey = "jsonData"
//
//    // MARK: Encoding
//
//    /// Creates a URL request by encoding parameters and applying them onto an existing request.
//    ///
//    /// - parameter urlRequest: The request to have parameters applied.
//    /// - parameter parameters: The parameters to apply. This should have a single key/value
//    ///                         pair with "jsonData" as the key and a Data object as the value.
//    ///
//    /// - throws: An `Error` if the encoding process encounters an error.
//    ///
//    /// - returns: The encoded request.
//    public func encode(_ urlRequest: URLRequestConvertible, with parameters: [String: Any]?) throws -> URLRequest {
//        var urlRequest = try urlRequest.asURLRequest()
//
//        guard let jsonData = parameters?[JSONDataEncoding.jsonDataKey] as? Data, !jsonData.isEmpty else {
//            return urlRequest
//        }
//
//        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
//            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        }
//
//        urlRequest.httpBody = jsonData
//
//        return urlRequest
//    }
//
//    public static func encodingParameters(jsonData: Data?) -> [String: Any]? {
//        var returnedParams: [String: Any]?
//        if let jsonData = jsonData, !jsonData.isEmpty {
//            var params = [String: Any]()
//            params[jsonDataKey] = jsonData
//            returnedParams = params
//        }
//        return returnedParams
//    }
//
//}
