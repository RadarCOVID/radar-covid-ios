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


open class AppleKpiControllerAPI {
    
    private let clientApi: SwaggerClientAPI

    init(clientApi: SwaggerClientAPI) {
        self.clientApi = clientApi
    }
    
    /**
     Save KPIs data sent by the iOS device, in compliance with the monthly policy, authorized with the provided analytics token.

     - parameter body: (body)  
     - parameter completion: completion handler to receive the data and the error objects
     */
    open func saveKpi(body: [KpiDto], token: String, completion: @escaping ((_ data: Void?,_ error: Error?) -> Void)) {
        saveKpiWithRequestBuilder(body: body, token: token).execute { (response, error) -> Void in
            if error == nil {
                completion((), error)
            } else {
                completion(nil, error)
            }
        }
    }

    /**
     Save KPIs data sent by the iOS device, in compliance with the monthly policy, authorized with the provided analytics token.
     - parameter body: (body)  
     - returns: Observable<Void>
     */
    open func saveKpi(body: [KpiDto], token: String) -> Observable<Void> {
        return Observable.create { [weak self] observer -> Disposable in
            self?.saveKpi(body: body, token: token) { data, error in
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
     Save KPIs data sent by the iOS device, in compliance with the monthly policy, authorized with the provided analytics token.
     - POST /apple
     - 

     - API Key:
       - type: apiKey x-sedia-authorization 
       - name: apiKeyAuth
     - parameter body: (body)  

     - returns: RequestBuilder<Void> 
     */
    open func saveKpiWithRequestBuilder(body: [KpiDto], token: String) -> RequestBuilder<Void> {
        let path = "/apple"
        let URLString = clientApi.basePath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)
        let url = URLComponents(string: URLString)
        let headers = ["x-sedia-authorization": token]
        


        let requestBuilder: RequestBuilder<Void>.Type = SwaggerClientAPI.requestBuilderFactory.getNonDecodableBuilder()

//        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true, headers: headers, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
                return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true, headers: headers)
    }
    /**
     Authorize the provided KPI token with the device authenticity SDK offered by the device operating system.

     - parameter body: (body)  
     - parameter completion: completion handler to receive the data and the error objects
     */
    open func verifyToken(body: AppleKpiTokenRequestDto, completion: @escaping ((_ data: VerifyResponse?,_ error: Error?) -> Void)) {
        verifyTokenWithRequestBuilder(body: body).execute { (response, error) -> Void in
            var res: VerifyResponse = .authorizationInProgress
            if let code = response?.statusCode {
                if code == 201 {
                    res = .authorized(token: response?.body?.token ?? "")
                }
            }
            completion(res, error)
        }
    }

    /**
     Authorize the provided KPI token with the device authenticity SDK offered by the device operating system.
     - parameter body: (body)  
     - returns: Observable<AppleKpiTokenResponseDto>
     */
    open func verifyToken(body: AppleKpiTokenRequestDto) -> Observable<VerifyResponse> {
        return Observable.create { [weak self] observer -> Disposable in
            self?.verifyToken(body: body) { data, error in
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
     Authorize the provided KPI token with the device authenticity SDK offered by the device operating system.
     - POST /apple/token
     - 

     - examples: [{contentType=application/json, example={
  "token" : "token"
}}]
     - parameter body: (body)  

     - returns: RequestBuilder<AppleKpiTokenResponseDto> 
     */
    open func verifyTokenWithRequestBuilder(body: AppleKpiTokenRequestDto) -> RequestBuilder<AppleKpiTokenResponseDto> {
        let path = "/apple/token"
        let URLString = clientApi.basePath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)
        let url = URLComponents(string: URLString)

        let requestBuilder: RequestBuilder<AppleKpiTokenResponseDto>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

//        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
}
