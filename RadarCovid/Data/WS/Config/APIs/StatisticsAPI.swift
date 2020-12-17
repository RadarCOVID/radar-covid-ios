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


open class StatisticsAPI {
    private let clientApi: SwaggerClientAPI

    init(clientApi: SwaggerClientAPI) {
        self.clientApi = clientApi
    }
    /**
     statistics
     
     - parameter completion: completion handler to receive the data and the error objects
     */
    open func statistics(completion: @escaping ((_ data: [StatsItem]?,_ error: Error?) -> Void)) {
        statisticsWithRequestBuilder().execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    open func getStatistics() -> Observable<[StatsItem]> {
        return Observable.create { [weak self] observer -> Disposable in
            self?.statistics { data, error in
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
     statistics
     - GET /kpi/statistics/basics
     - Show statistic data 
     - examples: [{contentType=application/json, example=[ {
  "date" : "date",
  "communicatedContagions" : {
    "totalActualDay" : 0.80082819046101150206595775671303272247314453125,
    "totalAcummulated" : 6.02745618307040320615897144307382404804229736328125
  },
  "applicationsDownloads" : {
    "totalActualDay" : 0.80082819046101150206595775671303272247314453125,
    "totalAcummulated" : 6.02745618307040320615897144307382404804229736328125
  }
}, {
  "date" : "date",
  "communicatedContagions" : {
    "totalActualDay" : 0.80082819046101150206595775671303272247314453125,
    "totalAcummulated" : 6.02745618307040320615897144307382404804229736328125
  },
  "applicationsDownloads" : {
    "totalActualDay" : 0.80082819046101150206595775671303272247314453125,
    "totalAcummulated" : 6.02745618307040320615897144307382404804229736328125
  }
} ]}]

     - returns: RequestBuilder<[StatsItem]> 
     */
    open func statisticsWithRequestBuilder() -> RequestBuilder<[StatsItem]> {
        let path = "/kpi/statistics/basics"
        let URLString = clientApi.basePath.replacingOccurrences(of: "/configuration", with: "") + path
        let parameters: [String:Any]? = nil
        
        let url = URLComponents(string: URLString)

        let requestBuilder: RequestBuilder<[StatsItem]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }

}
