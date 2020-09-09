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

open class SettingsAPI {

    private let clientApi: SwaggerClientAPI

    init(clientApi: SwaggerClientAPI) {
        self.clientApi = clientApi
    }

    /**
     Get application settings

     - parameter completion: completion handler to receive the data and the error objects
     */
    open func getSettings(completion: @escaping ((_ data: SettingsDto?, _ error: Error?) -> Void)) {
        getSettingsWithRequestBuilder().execute { (response, error) -> Void in
            completion(response?.body, error)
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

    /**
     Get application settings
     - GET /settings

     - :
       - type: http
       - name: bearerAuth
     - examples: [{contentType=application/json, example=[ {
  "minRiskScore" : 2,
  "riskScoreClassification" : [ {
    "minValue" : 4,
    "maxValue" : 7,
    "label" : "label"
  }, {
    "minValue" : 4,
    "maxValue" : 7,
    "label" : "label"
  } ],
  "exposureConfiguration" : {
    "transmission" : {
      "riskLevelValue1" : 0,
      "riskLevelValue3" : 1,
      "riskLevelValue2" : 6,
      "riskLevelValue8" : 9,
      "riskLevelValue5" : 5,
      "riskLevelValue4" : 5,
      "riskLevelWeight" : 3.616076749251911,
      "riskLevelValue7" : 7,
      "riskLevelValue6" : 2
    }
  }
}, {
  "minRiskScore" : 2,
  "riskScoreClassification" : [ {
    "minValue" : 4,
    "maxValue" : 7,
    "label" : "label"
  }, {
    "minValue" : 4,
    "maxValue" : 7,
    "label" : "label"
  } ],
  "exposureConfiguration" : {
    "transmission" : {
      "riskLevelValue1" : 0,
      "riskLevelValue3" : 1,
      "riskLevelValue2" : 6,
      "riskLevelValue8" : 9,
      "riskLevelValue5" : 5,
      "riskLevelValue4" : 5,
      "riskLevelWeight" : 3.616076749251911,
      "riskLevelValue7" : 7,
      "riskLevelValue6" : 2
    }
  }
} ]}]

     - returns: RequestBuilder<[SettingsDto]> 
     */
    open func getSettingsWithRequestBuilder() -> RequestBuilder<SettingsDto> {
        let path = "/settings"
        let URLString = clientApi.basePath + path
        let parameters: [String: Any]? = nil

        let url = URLComponents(string: URLString)

        let requestBuilder: RequestBuilder<SettingsDto>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }

}
