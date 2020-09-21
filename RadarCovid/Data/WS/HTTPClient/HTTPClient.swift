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

enum Environment {
    case pre
    case pro
}

protocol HTTPClient {
    var isConfigured: Bool { get }

    func configure(using configuration: HTTPClientConfiguration)
    func run<ResponseModel: Codable>(request: inout HTTPRequest<ResponseModel>, _ completion: @escaping (Result<ResponseModel, Error>) -> Void)
}

class HTTPClientDefault: NSObject, HTTPClient {
    var isConfigured: Bool { return configuration != nil }

    private(set) var session: URLSession!
    private var configuration: HTTPClientConfiguration?
    private var notificationCenter: NotificationCenter { NotificationCenter.default }

    override init() {
        super.init()
        let sessionConfiguration = URLSessionConfiguration.default
        session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
    }

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
            self.didCompleteDataTask(response: urlResponse, request: preparedRequest, data: data, error: error, completion: completion)

            // Errors here can be differentiated if at some point in the future they are typed by code from the server
            // switch urlResponse.statusCode {
            // case 200..<226:
            // case 400..<451:
            // case 500..<511:
            // default:
            // }
        })

        task.resume()

        notificationCenter.post(name: Notification.Name("HTTPClientDidStartDataTask"), object: task)
    }

    private func didCompleteDataTask<ResponseModel: Codable>(response: HTTPURLResponse, request: HTTPRequest<ResponseModel>, data: Data?, error: Error?, completion: @escaping (Result<ResponseModel, Error>) -> Void) {
        var notificationObject: [String: Any] = ["response": response]
        if let urlRequest = request.urlRequest { notificationObject["request"] = urlRequest }
        if let responseData = data { notificationObject["data"] = responseData }
        if let responseError = error { notificationObject["error"] = responseError }

        self.notificationCenter.post(name: Notification.Name("HTTPClientDidCompleteDataTask"), object: notificationObject)
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
                let expectedModel = try JSONDecoder().decode(ResponseModel.self, from: data)
                completion(Result<ResponseModel, Error>.success(expectedModel))
            }
        } catch {
            completion(Result<ResponseModel, Error>.failure(error))
        }
    }
}

extension HTTPClientDefault: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust, challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        var hostname: CFString
        switch Config.endpoints {
        case .pre: hostname = "radarcovidpre.covid19.gob.es" as CFString
        case .pro: hostname = "radarcovid.covid19.gob.es" as CFString
        }
        
        let policy = SecPolicyCreateSSL(true, hostname)
        let policies = NSArray(array: [policy])
        SecTrustSetPolicies(serverTrust, policies)

        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        guard certificateCount > 0, let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let serverCertificateData = SecCertificateCopyData(certificate) as Data
        let certificates = HTTPPinningCertificate.localCertificates()
        for localCert in certificates {
            if localCert.validate(against: serverCertificateData, using: serverTrust) {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }

        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
