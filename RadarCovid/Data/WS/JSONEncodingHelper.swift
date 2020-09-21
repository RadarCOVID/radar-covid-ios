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
//open class JSONEncodingHelper {
//
//    open class func encodingParameters<T: Encodable>(forEncodableObject encodableObj: T?) -> [String: Any]? {
//        var params: [String: Any]?
//
//        // Encode the Encodable object
//        if let encodableObj = encodableObj {
//            let encodeResult = CodableHelper.encode(encodableObj, prettyPrint: true)
//            if encodeResult.error == nil {
//                params = JSONDataEncoding.encodingParameters(jsonData: encodeResult.data)
//            }
//        }
//
//        return params
//    }
//
//    open class func encodingParameters(forEncodableObject encodableObj: Any?) -> [String: Any]? {
//        var params: [String: Any]?
//
//        if let encodableObj = encodableObj {
//            do {
//                let data = try JSONSerialization.data(withJSONObject: encodableObj, options: .prettyPrinted)
//                params = JSONDataEncoding.encodingParameters(jsonData: data)
//            } catch {
//                print(error)
//                return nil
//            }
//        }
//
//        return params
//    }
//
//}
