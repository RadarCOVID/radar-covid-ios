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

open class SettingsAPI {
    private let httpClient: HTTPClient
    private let clientApi: SwaggerClientAPI

    init(clientApi: SwaggerClientAPI, httpClient: HTTPClient) {
        self.httpClient = httpClient
        self.clientApi = clientApi
    }

    /**
     Get application settings

     - parameter completion: completion handler to receive the data and the error objects
     */
    open func getSettings(completion: @escaping ((_ data: SettingsDto?, _ error: Error?) -> Void)) {
        let getSettingsEndpoint = HTTPEndpoint(address: "/settings", method: .GET)
        var getSettingsRequest = HTTPRequest<SettingsDto>(endpoint: getSettingsEndpoint)

        guard let baseURL = URL(string: clientApi.basePath) else { completion(nil, HTTPClientError.invalidBaseURL); return }
        let configuration = HTTPClientConfiguration(baseURL: baseURL)
        httpClient.configure(using: configuration)

        httpClient.run(request: &getSettingsRequest) { (result) in
            switch result {
            case .failure(let error): DispatchQueue.main.async { completion(nil, error) }
            case .success(let settings): DispatchQueue.main.async { completion(settings, nil) }
            }
        }
    }

    /**
     Get application settings
     - returns: Observable<[SettingsDto]>
     */
    open func getSettings() -> Observable<SettingsDto> {
        return Observable.create { [weak self] observer -> Disposable in
            self?.getSettings { data, error in
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
