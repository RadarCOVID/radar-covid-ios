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
import RxSwift
import DP3TSDK
import SwiftJWT

class DiagnosisCodeUseCase {

    private let dateFormatter = DateFormatter()

    private let settingsRepository: SettingsRepository
    private let verificationApi: VerificationControllerAPI

    private var isfake = false

    init(settingsRepository: SettingsRepository,
         verificationApi: VerificationControllerAPI) {
        self.settingsRepository = settingsRepository
        self.verificationApi  = verificationApi
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "es_ES")
    }

    func sendDiagnosisCode(code: String, date: Date? = nil, share: Bool = false) -> Observable<Bool> {
        self.isfake = FakeRequestUseCase.FALSE_POSITIVE_CODE == code
        return verificationApi.verifyCode(body: Code( date: date, code: code ), share: share )
            .catchError { [weak self] error in throw self?.mapError(error) ?? error }
            .flatMap { [weak self] tokenResponse -> Observable<Bool> in
                guard let jwtOnset = try self?.parseToken(tokenResponse.token).claims.onset,
                      let onset = self?.dateFormatter.date(from: jwtOnset) else {
                    throw DiagnosisError.unknownError("Onset parameter not found in token")
                }
                return self?.iWasExposed(onset: onset, token: tokenResponse.token) ?? .empty()
            }
    }

    private func iWasExposed(onset: Date, token: String) -> Observable<Bool> {
        .create { [weak self] observer in
            DP3TTracing.iWasExposed(onset: onset,
                                    authentication: .HTTPAuthorizationBearer(token: token),
                                    isFakeRequest: self?.isfake ?? false) {  result in
                switch result {
                case let .failure(error):
                        observer.onError(self?.mapError(error) ?? error)
                default:
                        observer.onNext(true)
                        observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

    private func parseToken(_ signedJWT: String) throws -> JWT<MyClaims> {
        let key = Config.verificationKey
        print(key.base64EncodedString())
        let jwtVerifier = JWTVerifier.es512(publicKey: Config.verificationKey)
        let jwtDecoder = JWTDecoder(jwtVerifier: jwtVerifier)
        return try jwtDecoder.decode(JWT<MyClaims>.self, fromString: signedJWT)
    }

    private func is404(_ error: Error) -> Bool {
        if let code = getErrorCode(error) {
            return code == 404
        }
        return false
    }

    private func is400(_ error: Error) -> Bool {
        if let code = getErrorCode(error) {
            return code == 400
        }
        return false
    }

    private func isPermissionRejected(_ error: Error) -> Bool {
        if let error = error as? DP3TTracingError {
            if case .exposureNotificationError = error {
                return true
            }
        }
        return false
    }

    private func isNetworkError(_ error: Error) -> Bool {
        if let errorCode = getErrorDomain(error) {
            return errorCode <= -999
        }
        return false
    }

    private func getErrorCode(_ error: Error) -> Int? {
        if let error = error as? ErrorResponse {
            if case .error(let code, _, _) = error {
                return code
            }
        }
        return nil
    }

    private func getErrorDomain(_ error: Error) -> Int? {
        if let error = error as? ErrorResponse {
            if case .error(_, _, let errorDomain) = error {
                return (errorDomain as NSError).code
            }
        }
        return nil
    }

    private func mapError(_ error: Error) -> DiagnosisError {
        if is404(error) {
            return .wrongId(error)
        }
        if is400(error) {
            return .wrongId(error)
        }
        if isPermissionRejected(error) {
            return .apiRejected(error)
        }

        if isNetworkError(error) {
            return .noConnection(error)
        }

        return .unknownError(error)
    }

}

struct MyClaims: Claims {
    public var iss: String?
    public var sub: String?
    public var aud: String?
    public var exp: Int
    public var iat: Int
    public var jti: String?
    public var tan: String?
    public var scope: String?
    public var onset: String?
}

enum DiagnosisError: Error {
    case idAlreadyUsed(Error?)
    case apiRejected(Error?)
    case wrongId(Error?)
    case noConnection(Error?)
    case unknownError(Error?)
}
