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

open class TextsAPI {

    private let clientApi: SwaggerClientAPI

    init(clientApi: SwaggerClientAPI) {
        self.clientApi = clientApi
    }

    /**
     Get texts by locale and CCAA

     - parameter ccaa: (query)  (optional, default to ES)
     - parameter locale: (query)  (optional, default to es-ES)
     - parameter platform: (query)  (optional, default to iOS)
     - parameter version: (query)  (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open func getTexts(ccaa: String? = nil, locale: String? = nil, platform: String? = nil, version: String? = nil, completion: @escaping ((_ data: TextCustomMap?,_ error: Error?) -> Void)) {
        getTextsWithRequestBuilder(ccaa: ccaa, locale: locale, platform: platform, version: version).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }

    /**
     Get texts by locale and CCAA
     - parameter ccaa: (query)  (optional, default to ES)
     - parameter locale: (query)  (optional, default to es-ES)
     - parameter platform: (query)  (optional, default to iOS)
     - parameter version: (query)  (optional)
     - returns: Observable<TextCustomMap>
     */
    open func getTexts(ccaa: String? = nil, locale: String? = nil, platform: String? = nil, version: String? = nil) -> Observable<TextCustomMap> {
        return Observable.create { [weak self]  observer -> Disposable in
            self?.getTexts(ccaa: ccaa, locale: locale, platform: platform, version: version) { data, error in
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
     Get texts by locale and CCAA
     - GET /texts

     - examples: [{contentType=application/json, example={
  "key" : ""
}}]
     - parameter ccaa: (query)  (optional, default to ES)
     - parameter locale: (query)  (optional, default to es-ES)
     - parameter platform: (query)  (optional, default to iOS)
     - parameter version: (query)  (optional)

     - returns: RequestBuilder<TextCustomMap>
     */
    open func getTextsWithRequestBuilder(ccaa: String? = nil, locale: String? = nil, platform: String? = nil, version: String? = nil) -> RequestBuilder<TextCustomMap> {
        let path = "/texts"
        let URLString = clientApi.basePath + path
        let parameters: [String:Any]? = nil
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
                        "ccaa": ccaa,
                        "locale": locale,
                        "platform": platform,
                        "version": version
        ])

        let requestBuilder: RequestBuilder<TextCustomMap>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }

}
