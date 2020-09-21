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
        let allHeaders = headers.merging(defaultHTTPHeaders()) { (_, new) in new }
        urlRequest?.allHTTPHeaderFields = allHeaders
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

    private func defaultHTTPHeaders() -> [String: String] {
        var headersDictionary = [String: String]()
        // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
        headersDictionary["Accept-Encoding"] = "gzip;q=1.0, compress;q=0.5"

        // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
        let acceptLanguage = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(languageCode);q=\(quality)"
        }.joined(separator: ", ")
        headersDictionary["Accept-Language"] = acceptLanguage

        // User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
        if let info = Bundle.main.infoDictionary {
            let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
            let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
            let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
            let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
            let osNameVersion: String = {
                let version = ProcessInfo.processInfo.operatingSystemVersion
                let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

                let osName: String = {
                    #if os(iOS)
                        return "iOS"
                    #elseif os(watchOS)
                        return "watchOS"
                    #elseif os(tvOS)
                        return "tvOS"
                    #elseif os(macOS)
                        return "OS X"
                    #elseif os(Linux)
                        return "Linux"
                    #else
                        return "Unknown"
                    #endif
                }()

                return "\(osName) \(versionString)"
            }()

            headersDictionary["Accept-Language"] = "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) CFNetwork"
        }
        return headersDictionary
    }
}
