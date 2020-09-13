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

open class VerificationControllerAPI {

    private let clientApi: SwaggerClientAPI

    init(clientApi: SwaggerClientAPI) {
        self.clientApi = clientApi
    }

    /**
     Verify provided Code

     - parameter body: (body)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open func verifyCode(body: Code, completion: @escaping ((_ data: TokenResponse?, _ error: Error?) -> Void)) {
        let verifyCodeEndpoint = HTTPEndpoint(address: "/verify/code",
                                              method: .POST)
        var verifyCodeRequest = HTTPRequest<TokenResponse>(endpoint: verifyCodeEndpoint,
                                                           parameters: JSONEncodingHelper.encodingParameters(forEncodableObject: body))

        let configuration = HTTPClientConfiguration(baseURL: URL(string: clientApi.basePath)!)
        HTTPClientDefault().configure(using: configuration)

        HTTPClientDefault().run(request: &verifyCodeRequest) { (result) in
            switch result {
            case .failure(let error): completion(nil, error)
            case .success(let token): completion(token, nil)
            }
        }

//        verifyCodeWithRequestBuilder(body: body).execute { (response, error) -> Void in
//            completion(response?.body, error)
//        }
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

    /**
     Verify provided Code
     - POST /verify/code

     - examples: [{contentType=application/json, example={
  "token" : "token"
}}]
     - parameter body: (body)

     - returns: RequestBuilder<TokenResponse>
     */
    open func verifyCodeWithRequestBuilder(body: Code) -> RequestBuilder<TokenResponse> {
        let path = "/verify/code"
        let URLString = clientApi.basePath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)

        let url = URLComponents(string: URLString)

        let requestBuilder: RequestBuilder<TokenResponse>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
}
