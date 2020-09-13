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
    private let httpClient: HTTPClient
    private let clientApi: SwaggerClientAPI

    init(clientApi: SwaggerClientAPI, httpClient: HTTPClient) {
        self.httpClient = httpClient
        self.clientApi = clientApi
    }

    /**
     Get availables autonomous communities

     - parameter locale: (query)  (optional, default to es-ES)
     - parameter additionalInfo: (query)  (optional, default to false)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open func getCcaa(locale: String? = nil, additionalInfo: Bool = true, completion: @escaping ((_ data: [CcaaKeyValueDto]?, _ error: Error?) -> Void)) {
        let getCcaaEndpoint = HTTPEndpoint(address: "/masterData/ccaa", method: .GET)
        var getCcaaRequest = HTTPRequest<[CcaaKeyValueDto]>(endpoint: getCcaaEndpoint, parameters: ["additionalInfo": additionalInfo, "locale": locale ?? "es-ES"])

        guard let baseURL = URL(string: clientApi.basePath) else { completion(nil, HTTPClientError.invalidBaseURL); return }
        let configuration = HTTPClientConfiguration(baseURL: baseURL)
        httpClient.configure(using: configuration)

        httpClient.run(request: &getCcaaRequest) { (result) in
            switch result {
            case .failure(let error): completion(nil, error)
            case .success(let ccaa): completion(ccaa, nil)
            }
        }
    }

    /**
     Get availables autonomous communities
     - parameter locale: (query)  (optional, default to es-ES)
     - parameter additionalInfo: (query)  (optional, default to false)
     - returns: Observable<[CcaaKeyValueDto]>
     */
    open func getCcaa(locale: String? = nil, additionalInfo: Bool = true) -> Observable<[CcaaKeyValueDto]> {
        return Observable.create { [weak self] observer -> Disposable in
            self?.getCcaa(locale: locale, additionalInfo: additionalInfo) { data, error in
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

     - parameter locale: (query)  (optional, default to es-ES)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open func getLocales(locale: String? = nil, completion: @escaping ((_ data: [KeyValueDto]?, _ error: Error?) -> Void)) {
        let getLocalesEndpoint = HTTPEndpoint(address: "/masterData/locales", method: .GET)
        var getLocalesRequest = HTTPRequest<[KeyValueDto]>(endpoint: getLocalesEndpoint, parameters: ["locale": locale ?? "es-ES"])

        guard let baseURL = URL(string: clientApi.basePath) else { completion(nil, HTTPClientError.invalidBaseURL); return}
        let configuration = HTTPClientConfiguration(baseURL: baseURL)
        httpClient.configure(using: configuration)

        httpClient.run(request: &getLocalesRequest) { (result) in
            switch result {
            case .failure(let error): completion(nil, error)
            case .success(let locales): completion(locales, nil)
            }
        }
    }

    /**
     Get availables locales
     - parameter locale: (query)  (optional, default to es-ES)
     - returns: Observable<[KeyValueDto]>
     */
    open func getLocales(locale: String? = nil) -> Observable<[KeyValueDto]> {
        return Observable.create { [weak self] observer -> Disposable in

            self?.getLocales(locale: locale) { data, error in
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
