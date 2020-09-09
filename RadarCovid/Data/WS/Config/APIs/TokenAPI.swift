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

open class TokenAPI {

    private let clientApi: SwaggerClientAPI

    init(clientApi: SwaggerClientAPI) {
        self.clientApi = clientApi
    }

    /**
     Get application UUID token

     - parameter completion: completion handler to receive the data and the error objects
     */
    open func getUuid(completion: @escaping ((_ data: UuidDto?, _ error: Error?) -> Void)) {
        getUuidWithRequestBuilder().execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }

    /**
     Get application UUID token
     - returns: Observable<UuidDto>
     */
    open func getUuid() -> Observable<UuidDto> {
        return Observable.create { [weak self] observer -> Disposable in
            self?.getUuid { data, error in
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
     Get application UUID token
     - GET /token/uuid

     - :
       - type: http
       - name: bearerAuth
     - examples: [{contentType=application/json, example={
  "uuid" : "uuid"
}}]

     - returns: RequestBuilder<UuidDto> 
     */
    open func getUuidWithRequestBuilder() -> RequestBuilder<UuidDto> {
        let path = "/token/uuid"
        let URLString = clientApi.basePath + path
        let parameters: [String: Any]? = nil

        let url = URLComponents(string: URLString)

        let requestBuilder: RequestBuilder<UuidDto>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }

}
