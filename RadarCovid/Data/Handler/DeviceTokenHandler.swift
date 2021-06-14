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
import DeviceCheck
import Logging

protocol DeviceTokenHandler {
    func generateToken() -> Observable<DeviceToken>
    func clearCachedToken()
}

enum DeviceTokenError: Error {
  case notSupported
  case underlyingError(error: Error)
  case unknownError
}

class DCDeviceTokenHandler : DeviceTokenHandler {
    
    private let logger = Logger(label: "DCDeviceTokenHandler")
    
    private static let kDeviceToken = "DCDeviceTokenHandler.kDeviceToken"
    
    private let userDefaults: UserDefaults
    
    init() {
        userDefaults = UserDefaults(suiteName: Bundle.main.bundleIdentifier) ?? UserDefaults.standard
    }
    
    func generateToken() -> Observable<DeviceToken> {
        .create { [weak self] observer in
            
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            if let token = self.getCachedToken()  {
                self.logger.debug("generateToken() -> return cached token \(token.base64EncodedString())")
                observer.onNext(DeviceToken(token: token, isCached: true))
                observer.onCompleted()
            } else if DCDevice.current.isSupported {
                DCDevice.current.generateToken { token, error in
                    if let error = error {
                        observer.onError(DeviceTokenError.underlyingError(error: error))
                    } else if let token = token {
                        self.logger.debug("generateToken() -> return new token \(token.base64EncodedString())")
                        self.saveCached(token: token)
                        observer.onNext(DeviceToken(token: token, isCached: false))
                        observer.onCompleted()
                    } else {
                        observer.onError(DeviceTokenError.unknownError)
                    }
                }
            } else {
                observer.onError(DeviceTokenError.notSupported)
            }
            return Disposables.create()
        }
    }
    
    private func getCachedToken() -> Data? {
        userDefaults.data(forKey: DCDeviceTokenHandler.kDeviceToken)
    }
    
    private func saveCached(token: Data) {
        userDefaults.set(token, forKey: DCDeviceTokenHandler.kDeviceToken)
    }
    
    func clearCachedToken() {
        userDefaults.removeObject(forKey: DCDeviceTokenHandler.kDeviceToken)
    }

}
