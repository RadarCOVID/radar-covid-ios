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

protocol ProblematicEventsApi {
    func getProblematicEvents(tag: String?) -> Observable<ProblematicEventData>
}


class ProblematicEventsApiImpl : ProblematicEventsApi {
    
    private let clientApi: SwaggerClientAPI

    init(clientApi: SwaggerClientAPI) {
        self.clientApi = clientApi
    }
    
    func getProblematicEvents(tag: String?) -> Observable<ProblematicEventData> {
        return .create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            self.getProblematiEventsWithRequestBuilder(tag: tag).execute { response, error in
                if let error = error {
                    observer.on(.error(error))
                } else {
                    if let data = response?.body, let problematicEvents = self.parseProtobuf(data) {
                        let data = ProblematicEventData(problematicEvents: problematicEvents, tag: response?.header["x-key-bundle-tag"])
                        observer.on(.next(data))
                    } else {
                        observer.on(.error("Can't parse protobuf stream"))
                    }
                }
                observer.on(.completed)
            }
            return Disposables.create()
        }
    }
    
    private func parseProtobuf(_ data: Data) -> [ProblematicEvent]?  {
        let wrapper = try? ProblematicEventWrapper(serializedData: data)
        return wrapper?.events
        
    }
    
    private func getProblematiEventsWithRequestBuilder(tag: String?) -> RequestBuilder<Data>  {
        let URLString = clientApi.basePath + "/traceKeys"
        var parameters: [String: Any]? = nil
        if tag != nil {
            parameters = ["lastKeyBundleTag": tag as Any]
        }
        let headers = ["Accept": "application/x-protobuf"]
        let url = URLComponents(string: URLString)

        let requestBuilder: RequestBuilder<Data>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headers)
    }
}
