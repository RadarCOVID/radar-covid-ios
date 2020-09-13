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

struct HTTPRequest<ResponseModel: Codable> {
    private(set) var parameters: [String: Any]
    private(set) var headers = [String: String]()
    private(set) var endpoint: HTTPEndpoint
    let id: UUID
    var url: URL?
    var baseURL: URL?
    var urlRequest: URLRequest?

    init(endpoint: HTTPEndpoint, parameters: [String: Any]? = nil) {
        self.endpoint = endpoint
        self.parameters = parameters ?? [:]
        id = UUID()
    }

    mutating func configure(baseURL: URL) {
        self.baseURL = baseURL
        url = baseURL.appendingPathComponent(endpoint.address)
        prepareRequest()
        prepareParameters()
    }

    private mutating func prepareRequest() {
        guard let baseURL = baseURL else { return }
        urlRequest = URLRequest(url: baseURL.appendingPathComponent(endpoint.address))
        urlRequest?.httpMethod = endpoint.method.rawValue
        urlRequest?.allHTTPHeaderFields = headers
    }

    private mutating func prepareParameters() {
        switch endpoint.method {
        case .GET, .DELETE:
            guard let requestURL = url else { return }
            guard var paramsURL = URLComponents(string: requestURL.absoluteString) else { return }
            paramsURL.queryItems = []
            parameters.forEach({ paramsURL.queryItems?.append(URLQueryItem(name: $0.key, value: "\($0.value)")) })
            urlRequest = URLRequest(url: paramsURL.url!)

        case .POST, .PUT:
            let postData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            urlRequest?.httpBody = postData
        }
    }
}
