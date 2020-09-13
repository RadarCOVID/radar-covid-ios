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
    private let httpClient: HTTPClient
    private let clientApi: SwaggerClientAPI

    init(clientApi: SwaggerClientAPI, httpClient: HTTPClient) {
        self.clientApi = clientApi
        self.httpClient = httpClient
    }

    /**
     Get texts by locale and CCAA

     - parameter ccaa: (query)  (optional, default to ES)
     - parameter locale: (query)  (optional, default to es-ES)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open func getTexts(ccaa: String? = nil, locale: String? = nil, completion: @escaping ((_ data: TextCustomMap?, _ error: Error?) -> Void)) {
        let getTextEndpoint = HTTPEndpoint(address: "/texts", method: .GET)
        var getTextCodeRequest = HTTPRequest<TextCustomMap>(endpoint: getTextEndpoint, parameters: ["ccaa": ccaa ?? "ES", "locale": locale ?? "es-ES"])

        guard let baseURL = URL(string: clientApi.basePath) else { completion(nil, HTTPClientError.invalidBaseURL); return}
        let configuration = HTTPClientConfiguration(baseURL: baseURL)
        httpClient.configure(using: configuration)

        httpClient.run(request: &getTextCodeRequest) { (result) in
            switch result {
            case .failure(let error): completion(nil, error)
            case .success(let texts): completion(texts, nil)
            }
        }
    }

    /**
     Get texts by locale and CCAA
     - parameter ccaa: (query)  (optional, default to ES)
     - parameter locale: (query)  (optional, default to es-ES)
     - returns: Observable<TextCustomMap>
     */
    open func getTexts(ccaa: String? = nil, locale: String? = nil) -> Observable<TextCustomMap> {
        return Observable.create { [weak self] observer -> Disposable in
            self?.getTexts(ccaa: ccaa, locale: locale) { data, error in
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
}
