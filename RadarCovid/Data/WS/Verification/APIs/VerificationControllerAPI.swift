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

open class VerificationControllerAPI {
    private let httpClient: HTTPClient
    private let clientApi: SwaggerClientAPI

    init(clientApi: SwaggerClientAPI, httpClient: HTTPClient) {
        self.httpClient = httpClient
        self.clientApi = clientApi
    }

    /**
     Verify provided Code

     - parameter body: (body)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open func verifyCode(body: Code, completion: @escaping ((_ data: TokenResponse?, _ error: Error?) -> Void)) {
        let verifyCodeEndpoint = HTTPEndpoint(address: "/masterData/ccaa", method: .POST)
        var verifyCodeRequest = HTTPRequest<TokenResponse>(endpoint: verifyCodeEndpoint, parameters: JSONEncodingHelper.encodingParameters(forEncodableObject: body))

        guard let baseURL = URL(string: clientApi.basePath) else { completion(nil, HTTPClientError.invalidBaseURL); return }
        let configuration = HTTPClientConfiguration(baseURL: baseURL)
        httpClient.configure(using: configuration)

        httpClient.run(request: &verifyCodeRequest) { (result) in
            switch result {
            case .failure(let error): DispatchQueue.main.async { completion(nil, error) }
            case .success(let token): DispatchQueue.main.async { completion(token, nil) }
            }
        }
    }

    /**
     Verify provided Code
     - parameter body: (body)
     - returns: Observable<TokenResponse>
     */
    open func verifyCode(body: Code) -> Observable<TokenResponse> {
        return Observable.create { [weak self] observer -> Disposable in
            self?.verifyCode(body: body) {  data, error in
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
