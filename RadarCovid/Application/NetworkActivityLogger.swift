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

/// The level of logging detail.
public enum NetworkActivityLoggerLevel {
    /// Do not log requests or responses.
    case off

    /// Logs HTTP method, URL, header fields, & request body for requests, and status code,
    /// URL, header fields, response string, & elapsed time for responses.
    case debug

    /// Logs HTTP method & URL for requests, and status code, URL, & elapsed time for responses.
    case info

    /// Logs HTTP method & URL for requests, and status code, URL, & elapsed time for responses,
    /// but only for failed requests.
    case warn

    /// Equivalent to `.warn`
    case error

    /// Equivalent to `.off`
    case fatal
}

/// `NetworkActivityLogger` logs requests and responses made by Alamofire.SessionManager,
/// with an adjustable level of detail.
public class NetworkActivityLogger {
    // MARK: - Properties

    /// The shared network activity logger for the system.
    public static let shared = NetworkActivityLogger()

    /// The level of logging detail. See NetworkActivityLoggerLevel enum for possible values. .info by default.
    public var level: NetworkActivityLoggerLevel

    /// Omit requests which match the specified predicate, if provided.
    public var filterPredicate: NSPredicate?

    private var startDates: [URLRequest: Date]

    // MARK: - Internal - Initialization

    init() {
        level = .info
        startDates = [URLRequest: Date]()
    }

    deinit {
        stopLogging()
    }

    // MARK: - Logging

    /// Start logging requests and responses.
    public func startLogging() {
        stopLogging()

        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(
            self,
            selector: #selector(NetworkActivityLogger.networkRequestDidStart(notification:)),
            name: Notification.Name("HTTPClientDidStartDataTask"),
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(NetworkActivityLogger.networkRequestDidComplete(notification:)),
            name: Notification.Name("HTTPClientDidCompleteDataTask"),
            object: nil
        )
    }

    /// Stop logging requests and responses.
    public func stopLogging() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private - Notifications

    @objc private func networkRequestDidStart(notification: Notification) {
        guard let task = notification.object as? URLSessionTask,
            let request = task.originalRequest,
            let httpMethod = request.httpMethod,
            let requestURL = request.url
            else { return }

        if let filterPredicate = filterPredicate, filterPredicate.evaluate(with: request) {
            return
        }

        startDates[request] = Date()

        switch level {
        case .debug:
            logDivider()

            print("\(httpMethod) '\(requestURL.absoluteString)':")

            if let httpHeadersFields = request.allHTTPHeaderFields {
                logHeaders(headers: httpHeadersFields)
            }

            if let httpBody = request.httpBody, let httpBodyString = String(data: httpBody, encoding: .utf8) {
                print(httpBodyString)
            }
        case .info:
            logDivider()

            print("\(httpMethod) '\(requestURL.absoluteString)'")
        default:
            break
        }
    }

    @objc private func networkRequestDidComplete(notification: Notification) {
        guard let object = notification.object as? [String: Any],
            let request = object["request"] as? URLRequest,
            let response = object["response"] as? HTTPURLResponse,
            let httpMethod = request.httpMethod,
            let requestURL = request.url
            else { return }

        if let filterPredicate = filterPredicate, filterPredicate.evaluate(with: request) {
            return
        }

        var elapsedTime: TimeInterval = 0.0

        if let startDate = startDates[request] {
            elapsedTime = Date().timeIntervalSince(startDate)
            startDates[request] = Date()
        }

        if let error = object["error"] as? Error {
            switch level {
            case .debug, .info, .warn, .error:
                logDivider()

                print("[Error] \(httpMethod) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:")
                print(error)
            default:
                break
            }
        } else {
            switch level {
            case .debug:
                logDivider()

                print("\(response.statusCode) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:")

                logHeaders(headers: response.allHeaderFields)

                guard let data = object["data"] as? Data else { break }

                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)

                    if let prettyString = String(data: prettyData, encoding: .utf8) {
                        print(prettyString)
                    }
                } catch {
                    if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        print(string)
                    }
                }
            case .info:
                logDivider()

                print("\(String(response.statusCode)) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]")
            default:
                break
            }
        }
    }
}

private extension NetworkActivityLogger {
    func logDivider() {
        print("---------------------")
    }

    func logHeaders(headers: [AnyHashable: Any]) {
        print("Headers: [")
        for (key, value) in headers {
            print("  \(key) : \(value)")
        }
        print("]")
    }
}
