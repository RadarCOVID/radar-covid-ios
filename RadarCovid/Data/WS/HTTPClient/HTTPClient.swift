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

struct Empty: Codable {}

protocol HTTPClient {
    var isConfigured: Bool { get }

    func configure(using configuration: HTTPClientConfiguration)
    func run<ResponseModel: Codable>(request: inout HTTPRequest<ResponseModel>, _ completion: @escaping (Result<ResponseModel, Error>) -> Void)
}

class HTTPClientDefault: HTTPClient {
    var isConfigured: Bool { return configuration != nil }

    private var session: URLSession { return URLSession.shared }
    private var configuration: HTTPClientConfiguration?

    func configure(using configuration: HTTPClientConfiguration) {
        self.configuration = configuration
    }

    func run<ResponseModel: Codable>(request: inout HTTPRequest<ResponseModel>, _ completion: @escaping (Result<ResponseModel, Error>) -> Void) {
        guard let configuration = configuration else { completion(Result<ResponseModel, Error>.failure(HTTPClientError.notConfigured)); return }
        request.configure(baseURL: configuration.baseURL)
        let preparedRequest = request

        guard let urlRequest = request.urlRequest else { completion(Result<ResponseModel, Error>.failure(HTTPClientError.notConfigured)); return }
        let task = session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            guard let urlResponse = response as? HTTPURLResponse else { completion(Result<ResponseModel, Error>.failure(HTTPClientError.invalidResponse)); return }
            switch urlResponse.statusCode {
            case 200..<226:
                self.didCompleteDataTask(request: preparedRequest, data: data, error: error, completion: completion)

            case 400..<451:
                self.didCompleteDataTask(request: preparedRequest, data: data, error: error, completion: completion)

            case 500..<511:
                self.didCompleteDataTask(request: preparedRequest, data: data, error: error, completion: completion)

            default:
                self.didCompleteDataTask(request: preparedRequest, data: data, error: error, completion: completion)
            }
        })

        task.resume()
    }

    private func didCompleteDataTask<ResponseModel: Codable>(request: HTTPRequest<ResponseModel>, data: Data?, error: Error?, completion: @escaping (Result<ResponseModel, Error>) -> Void) {
        if let error = error {
            didFail(withError: error, completion: completion)
        } else if let data = data {
            didSuccess(withData: data, request: request, completion: completion)
        } else {
            didFail(withError: HTTPClientError.unknown, completion: completion)
        }
    }

    private func didFail<ResponseModel: Codable>(withError error: Error, completion: @escaping (Result<ResponseModel, Error>) -> Void) {
        completion(Result<ResponseModel, Error>.failure(error))
    }

    private func didSuccess<ResponseModel: Codable>(withData data: Data, request: HTTPRequest<ResponseModel>, completion: @escaping (Result<ResponseModel, Error>) -> Void) {
        do {
            if request is HTTPRequest<Empty> {
                completion(Result<ResponseModel, Error>.success(Empty() as! ResponseModel))
            } else {
                let expectedModel: ResponseModel
                if ResponseModel.self == String.self {
                    expectedModel = String(data: data, encoding: .utf8) as! ResponseModel
                } else {
                    expectedModel = try JSONDecoder().decode(ResponseModel.self, from: data)
                }
                completion(Result<ResponseModel, Error>.success(expectedModel))
            }
        } catch {
            completion(Result<ResponseModel, Error>.failure(error))
        }
    }
}
