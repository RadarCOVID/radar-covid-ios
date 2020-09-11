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
    public private(set) var parameters: [String: Any]
    public private(set) var headers = [String: String]()
    public private(set) var endpoint: HTTPEndpoint
    public let id: UUID
    public var url: URL?
    public var baseURL: URL?
    public var urlRequest: URLRequest?

    public init(endpoint: HTTPEndpoint, parameters: [String: Any]? = nil) {
        self.endpoint = endpoint
        self.parameters = parameters ?? [:]
        id = UUID()
    }

    mutating func configure(baseURL: URL) {
        self.baseURL = baseURL
        url = baseURL.appendingPathComponent(endpoint.address)
        urlRequest = URLRequest(url: baseURL.appendingPathComponent(endpoint.address))
    }

    init(request: HTTPRequest<ResponseModel>) {
        endpoint = request.endpoint
        parameters = request.parameters
        id = request.id
        baseURL = request.baseURL
        url = request.url
        urlRequest = request.urlRequest
    }
}
