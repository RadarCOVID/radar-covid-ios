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

class AlamofireRequestBuilderFactory: RequestBuilderFactory {
    func getNonDecodableBuilder<T>() -> RequestBuilder<T>.Type {
        return AlamofireRequestBuilder<T>.self
    }

    func getBuilder<T: Decodable>() -> RequestBuilder<T>.Type {
        return AlamofireDecodableRequestBuilder<T>.self
    }
}

// Store manager to retain its reference
private var managerStore: [String: Alamofire.SessionManager] = [:]

// Sync queue to manage safe access to the store manager
private let syncQueue = DispatchQueue(label: "thread-safe-sync-queue", attributes: .concurrent)

open class AlamofireRequestBuilder<T>: RequestBuilder<T> {
    required public init(method: String, URLString: String, parameters: [String: Any]?, isBody: Bool, headers: [String: String] = [:], cachePolicy: URLRequest.CachePolicy? = nil) {
        super.init(method: method, URLString: URLString, parameters: parameters, isBody: isBody, headers: headers, cachePolicy: cachePolicy)
    }

    /**
     May be overridden by a subclass if you want to control the session
     configuration.
     */
    open func createSessionManager() -> Alamofire.SessionManager {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [

            "radarcovidpre.covid19.gob.es": .pinPublicKeys(
                publicKeys: [
                    try! CertificateUtil.publicKey(filename: "newradarcovidpre.covid19.gob.es"),
                    try! CertificateUtil.publicKey(filename: "oldradarcovidpre.covid19.gob.es"),
                ],
                validateCertificateChain: true,
                validateHost: true
            ),
            "radarcovid.covid19.gob.es": .pinPublicKeys(
                publicKeys: [
                    try! CertificateUtil.publicKey(filename: "oldradarcovid.covid19.gob.es"),
                    try! CertificateUtil.publicKey(filename: "newradarcovid.covid19.gob.es")
                ],
                validateCertificateChain: true,
                validateHost: true
            )
        ]
        let configuration = URLSessionConfiguration.default
        let serverTrusPolicyManager = ServerTrustPolicyManager(policies: serverTrustPolicies)
        configuration.httpAdditionalHeaders = buildHeaders()
        if let cachePolicy = cachePolicy {
            configuration.requestCachePolicy = cachePolicy
        }
        return Alamofire.SessionManager(configuration: configuration, serverTrustPolicyManager: serverTrusPolicyManager )
    }

    /**
     May be overridden by a subclass if you want to control the Content-Type
     that is given to an uploaded form part.

     Return nil to use the default behavior (inferring the Content-Type from
     the file extension).  Return the desired Content-Type otherwise.
     */
    open func contentTypeForFormPart(fileURL: URL) -> String? {
        return nil
    }

    /**
     May be overridden by a subclass if you want to control the request
     configuration (e.g. to override the cache policy).
     */
    open func makeRequest(
        manager: SessionManager,
        method: HTTPMethod,
        encoding: ParameterEncoding,
        headers: [String: String]) -> DataRequest {
        return manager.request(URLString, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }

    override open func execute(
        _ completion: @escaping (_ response: Response<T>?, _ error: Error?) -> Void) {
        let managerId: String = UUID().uuidString
        // Create a new manager for each request to customize its request header
        let manager = createSessionManager()
        syncQueue.async(flags: .barrier) {
            managerStore[managerId] = manager
        }

        let encoding: ParameterEncoding = isBody ? JSONDataEncoding() : URLEncoding()

        let xMethod = Alamofire.HTTPMethod(rawValue: method)
        let fileKeys = parameters == nil ? [] : parameters!.filter { $1 is NSURL }
                                                           .map { $0.0 }

        if fileKeys.count > 0 {
            manager.upload(multipartFormData: { mpForm in
                for (key, value) in self.parameters! {
                    switch value {
                    case let fileURL as URL:
                        if let mimeType = self.contentTypeForFormPart(fileURL: fileURL) {
                            mpForm.append(
                                fileURL,
                                withName: key,
                                fileName: fileURL.lastPathComponent,
                                mimeType: mimeType
                            )
                        } else {
                            mpForm.append(fileURL, withName: key)
                        }
                    case let string as String:
                        mpForm.append(string.data(using: String.Encoding.utf8)!, withName: key)
                    case let number as NSNumber:
                        mpForm.append(number.stringValue.data(using: String.Encoding.utf8)!, withName: key)
                    default:
                        fatalError("Unprocessable value \(value) with key \(key)")
                    }
                }
                }, to: URLString, method: xMethod!, headers: nil, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    if let onProgressReady = self.onProgressReady {
                        onProgressReady(upload.uploadProgress)
                    }
                    self.processRequest(request: upload, managerId, completion)
                case .failure(let encodingError):
                    completion(nil, ErrorResponse.error(415, nil, encodingError))
                }
            })
        } else {
            let request = makeRequest(manager: manager, method: xMethod!, encoding: encoding, headers: headers)
            if let onProgressReady = self.onProgressReady {
                onProgressReady(request.progress)
            }
            processRequest(request: request, managerId, completion)
        }

    }

    fileprivate func processRequest(
        request: DataRequest,
        _ managerId: String,
        _ completion: @escaping (_ response: Response<T>?, _ error: Error?) -> Void) {
        if let credential = self.credential {
            request.authenticate(usingCredential: credential)
        }

        let cleanupRequest = {
            syncQueue.async(flags: .barrier) {
                 _ = managerStore.removeValue(forKey: managerId)
            }
        }

        let validatedRequest = request.validate()

        switch T.self {
        case is String.Type:
            validatedRequest.responseString(completionHandler: { (stringResponse) in
                cleanupRequest()

                if stringResponse.result.isFailure {
                    completion(
                        nil,
                        ErrorResponse.error(
                            stringResponse.response?.statusCode ?? 500,
                            stringResponse.data, stringResponse.result.error!
                        )
                    )
                    return
                }

                completion(
                    Response(
                        response: stringResponse.response!,
                        body: ((stringResponse.result.value ?? "") as? T)
                    ),
                    nil
                )
            })
        case is URL.Type:
            validatedRequest.responseData(completionHandler: { (dataResponse) in
                cleanupRequest()

                do {

                    guard !dataResponse.result.isFailure else {
                        throw DownloadException.responseFailed
                    }

                    guard let data = dataResponse.data else {
                        throw DownloadException.responseDataMissing
                    }

                    guard let request = request.request else {
                        throw DownloadException.requestMissing
                    }

                    let fileManager = FileManager.default
                    let urlRequest = try request.asURLRequest()
                    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let requestURL = try self.getURL(from: urlRequest)

                    var requestPath = try self.getPath(from: requestURL)

                    if let headerFileName = self.getFileName(
                        fromContentDisposition: dataResponse.response?.allHeaderFields["Content-Disposition"] as? String
                        ) {
                        requestPath = requestPath.appending("/\(headerFileName)")
                    }

                    let filePath = documentsDirectory.appendingPathComponent(requestPath)
                    let directoryPath = filePath.deletingLastPathComponent().path

                    try fileManager.createDirectory(
                        atPath: directoryPath,
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    try data.write(to: filePath, options: .atomic)

                    completion(
                        Response(
                            response: dataResponse.response!,
                            body: (filePath as? T)
                        ),
                        nil
                    )

                } catch let requestParserError as DownloadException {
                    completion(nil, ErrorResponse.error(400, dataResponse.data, requestParserError))
                } catch let error {
                    completion(nil, ErrorResponse.error(400, dataResponse.data, error))
                }
                return
            })
        case is Void.Type:
            validatedRequest.responseData(completionHandler: { (voidResponse) in
                cleanupRequest()

                if voidResponse.result.isFailure {
                    completion(
                        nil,
                        ErrorResponse.error(
                            voidResponse.response?.statusCode ?? 500,
                            voidResponse.data, voidResponse.result.error!
                        )
                    )
                    return
                }

                completion(
                    Response(
                        response: voidResponse.response!,
                        body: nil),
                    nil
                )
            })
        default:
            validatedRequest.responseData(completionHandler: { (dataResponse) in
                cleanupRequest()

                if dataResponse.result.isFailure {
                    completion(
                        nil,
                        ErrorResponse.error(
                            dataResponse.response?.statusCode ?? 500,
                            dataResponse.data, dataResponse.result.error!
                        )
                    )
                    return
                }

                completion(
                    Response(
                        response: dataResponse.response!,
                        body: (dataResponse.data as? T)
                    ),
                    nil
                )
            })
        }
    }

    open func buildHeaders() -> [String: String] {
        var httpHeaders = SessionManager.defaultHTTPHeaders
        for (key, value) in self.headers {
            httpHeaders[key] = value
        }
        return httpHeaders
    }

    fileprivate func getFileName(fromContentDisposition contentDisposition: String?) -> String? {

        guard let contentDisposition = contentDisposition else {
            return nil
        }

        let items = contentDisposition.components(separatedBy: ";")

        var filename: String?

        for contentItem in items {

            let filenameKey = "filename="
            guard let range = contentItem.range(of: filenameKey) else {
                break
            }

            filename = contentItem
            return filename?
                .replacingCharacters(in: range, with: "")
                .replacingOccurrences(of: "\"", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return filename

    }

    fileprivate func getPath(from url: URL) throws -> String {

        guard var path = URLComponents(url: url, resolvingAgainstBaseURL: true)?.path else {
            throw DownloadException.requestMissingPath
        }

        if path.hasPrefix("/") {
            path.remove(at: path.startIndex)
        }

        return path

    }

    fileprivate func getURL(from urlRequest: URLRequest) throws -> URL {

        guard let url = urlRequest.url else {
            throw DownloadException.requestMissingURL
        }

        return url
    }

}

private enum DownloadException: Error {
    case responseDataMissing
    case responseFailed
    case requestMissing
    case requestMissingPath
    case requestMissingURL
}

public enum AlamofireDecodableRequestBuilderError: Error {
    case emptyDataResponse
    case nilHTTPResponse
    case jsonDecoding(DecodingError)
    case generalError(Error)
}

open class AlamofireDecodableRequestBuilder<T: Decodable>: AlamofireRequestBuilder<T> {

    override fileprivate func processRequest(
        request: DataRequest,
        _ managerId: String,
        _ completion: @escaping (_ response: Response<T>?, _ error: Error?)
        -> Void) {
        if let credential = self.credential {
            request.authenticate(usingCredential: credential)
        }

        let cleanupRequest = {
            syncQueue.async(flags: .barrier) {
                _ = managerStore.removeValue(forKey: managerId)
            }
        }

        let validatedRequest = request.validate()

        switch T.self {
        case is String.Type:
            validatedRequest.responseString(completionHandler: { (stringResponse) in
                cleanupRequest()

                if stringResponse.result.isFailure {
                    completion(
                        nil,
                        ErrorResponse.error(
                            stringResponse.response?.statusCode ?? 500,
                            stringResponse.data, stringResponse.result.error!
                        )
                    )
                    return
                }

                completion(
                    Response(
                        response: stringResponse.response!,
                        body: ((stringResponse.result.value ?? "") as? T)
                    ),
                    nil
                )
            })
        case is Void.Type:
            validatedRequest.responseData(completionHandler: { (voidResponse) in
                cleanupRequest()

                if voidResponse.result.isFailure {
                    completion(
                        nil,
                        ErrorResponse.error(
                            voidResponse.response?.statusCode ?? 500,
                            voidResponse.data, voidResponse.result.error!
                        )
                    )
                    return
                }

                completion(
                    Response(
                        response: voidResponse.response!,
                        body: nil),
                    nil
                )
            })
        case is Data.Type:
            validatedRequest.responseData(completionHandler: { (dataResponse) in
                cleanupRequest()

                if dataResponse.result.isFailure {
                    completion(
                        nil,
                        ErrorResponse.error(
                            dataResponse.response?.statusCode ?? 500,
                            dataResponse.data, dataResponse.result.error!
                        )
                    )
                    return
                }

                completion(
                    Response(
                        response: dataResponse.response!,
                        body: (dataResponse.data as? T)
                    ),
                    nil
                )
            })
        default:
            validatedRequest.responseData(completionHandler: { (dataResponse: DataResponse<Data>) in
                cleanupRequest()

                guard dataResponse.result.isSuccess else {
                    completion(nil, ErrorResponse.error(
                        dataResponse.response?.statusCode ?? 500,
                        dataResponse.data, dataResponse.result.error!)
                    )
                    return
                }

                guard let data = dataResponse.data, !data.isEmpty else {
                    completion(
                        nil,
                        ErrorResponse.error(
                            -1,
                            nil,
                            AlamofireDecodableRequestBuilderError.emptyDataResponse
                        )
                    )
                    return
                }

                guard let httpResponse = dataResponse.response else {
                    completion(nil, ErrorResponse.error(-2, nil, AlamofireDecodableRequestBuilderError.nilHTTPResponse))
                    return
                }

                var responseObj: Response<T>?

                let decodeResult: (decodableObj: T?, error: Error?) = CodableHelper.decode(T.self, from: data)
                if decodeResult.error == nil {
                    responseObj = Response(response: httpResponse, body: decodeResult.decodableObj)
                }

                completion(responseObj, decodeResult.error)
            })
        }
    }

}


