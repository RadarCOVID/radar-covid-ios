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
import RxSwift

open class TokenAPI {
    private let httpClient: HTTPClient
    private let clientApi: SwaggerClientAPI

    init(clientApi: SwaggerClientAPI, httpClient: HTTPClient) {
        self.httpClient = httpClient
        self.clientApi = clientApi
    }

    /**
     Get application UUID token

     - parameter completion: completion handler to receive the data and the error objects
     */
    open func getUuid(completion: @escaping ((_ data: UuidDto?, _ error: Error?) -> Void)) {
        let getUuidEndpoint = HTTPEndpoint(address: "/token/uuid", method: .GET)
        var getUuidRequest = HTTPRequest<UuidDto>(endpoint: getUuidEndpoint)

        guard let baseURL = URL(string: clientApi.basePath) else { completion(nil, HTTPClientError.invalidBaseURL); return }
        let configuration = HTTPClientConfiguration(baseURL: baseURL)
        httpClient.configure(using: configuration)

        httpClient.run(request: &getUuidRequest) { (result) in
            switch result {
            case .failure(let error): DispatchQueue.main.async { completion(nil, error) }
            case .success(let uuid): DispatchQueue.main.async { completion(uuid, nil) }
            }
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
}
