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
import Alamofire
import RxSwift

open class MasterDataAPI {

    private let clientApi: SwaggerClientAPI

    init(clientApi: SwaggerClientAPI) {
        self.clientApi = clientApi
    }

    /**
     Get availables autonomous communities

     - parameter locale: (query)  (optional, default to es-ES)
     - parameter additionalInfo: (query)  (optional, default to false)
     - parameter platform: (query)  (optional, default to iOS)
     - parameter version: (query)  (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open func getCcaa(locale: String? = nil, additionalInfo: Bool? = nil, platform: String? = nil, version: String? = nil, completion: @escaping ((_ data: [CcaaKeyValueDto]?,_ error: Error?) -> Void)) {
        getCcaaWithRequestBuilder(locale: locale, additionalInfo: additionalInfo, platform: platform, version: version).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }

    /**
     Get availables autonomous communities
     - parameter locale: (query)  (optional, default to es-ES)
     - parameter additionalInfo: (query)  (optional, default to false)
     - parameter platform: (query)  (optional, default to iOS)
     - parameter version: (query)  (optional)
     - returns: Observable<[CcaaKeyValueDto]>
     */
    open func getCcaa(locale: String? = nil, additionalInfo: Bool? = nil, platform: String? = nil, version: String? = nil) -> Observable<[CcaaKeyValueDto]> {
        return Observable.create { [weak self]  observer -> Disposable in
            self?.getCcaa(locale: locale, additionalInfo: additionalInfo, platform: platform, version: version) { data, error in
                if let error = error {
                    observer.on(.error(error))
                } else {
                    observer.on(.next(data!))
                }
                observer.on(.completed)
            }
            return Disposables.create()
        }
    }

    /**
     Get availables autonomous communities
     - GET /masterData/ccaa

     - examples: [{contentType=application/json, example=[ {
  "phone" : "phone",
  "web" : "web",
  "webName" : "webName",
  "additionalInfo" : "additionalInfo",
  "description" : "description",
  "id" : "id",
  "email" : "email"
}, {
  "phone" : "phone",
  "web" : "web",
  "webName" : "webName",
  "additionalInfo" : "additionalInfo",
  "description" : "description",
  "id" : "id",
  "email" : "email"
} ]}]
     - parameter locale: (query)  (optional, default to es-ES)
     - parameter additionalInfo: (query)  (optional, default to false)
     - parameter platform: (query)  (optional, default to iOS)
     - parameter version: (query)  (optional)

     - returns: RequestBuilder<[CcaaKeyValueDto]>
     */
    open func getCcaaWithRequestBuilder(locale: String? = nil, additionalInfo: Bool? = nil, platform: String? = nil, version: String? = nil) -> RequestBuilder<[CcaaKeyValueDto]> {
        let path = "/masterData/ccaa"
        let URLString = clientApi.basePath + path
        let parameters: [String: Any]? = nil
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
            "locale": locale,
            "additionalInfo": additionalInfo,
            "platform": platform,
            "version": version
        ])

        let requestBuilder: RequestBuilder<[CcaaKeyValueDto]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }

    /**
     Get availables locales

     - parameter locale: (query)  (optional, default to es-ES)
     - parameter platform: (query)  (optional, default to iOS)
     - parameter version: (query)  (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open func getLocales(locale: String? = nil, platform: String? = nil, version: String? = nil, completion: @escaping ((_ data: [KeyValueDto]?,_ error: Error?) -> Void)) {
        getLocalesWithRequestBuilder(locale: locale, platform: platform, version: version).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }

    /**
     Get availables locales
     - parameter locale: (query)  (optional, default to es-ES)
     - returns: Observable<[KeyValueDto]>
     */
    open func getLocales(locale: String? = nil, platform: String? = nil, version: String? = nil) -> Observable<[KeyValueDto]> {
        return Observable.create { [weak self] observer -> Disposable in
            self?.getLocales(locale: locale, platform: platform, version: version) { data, error in
                if let error = error {
                    observer.on(.error(error))
                } else {
                    observer.on(.next(data!))
                }
                observer.on(.completed)
            }
            return Disposables.create()
        }
    }

    /**
     Get availables locales
     - GET /masterData/locales

     - examples: [{contentType=application/json, example=[ {
  "description" : "description",
  "id" : "id"
}, {
  "description" : "description",
  "id" : "id"
} ]}]
     - parameter locale: (query)  (optional, default to es-ES)
     - parameter platform: (query)  (optional, default to iOS)
     - parameter version: (query)  (optional)

     - returns: RequestBuilder<[KeyValueDto]>
     */
    open func getLocalesWithRequestBuilder(locale: String? = nil, platform: String? = nil, version: String? = nil) -> RequestBuilder<[KeyValueDto]> {
        let path = "/masterData/locales"
        let URLString = clientApi.basePath + path
        let parameters: [String: Any]? = nil
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
                "locale": locale,
                "platform": platform,
                "version": version
        ])

        let requestBuilder: RequestBuilder<[KeyValueDto]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }

}
