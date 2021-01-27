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

protocol DeviceTokenHandler {
    func generateToken() -> Observable<Data>
}

enum DeviceTokenError: Error {
  case notSupported
  case underlyingError(error: Error)
  case unknownError
}

class DCDeviceTokenHandler : DeviceTokenHandler {
    
    private var cachedToken: Data?
    
    func generateToken() -> Observable<Data> {
        .create { [weak self] observer in
            
            if let token = self?.cachedToken  {
                observer.onNext(token)
                observer.onCompleted()
            } else if DCDevice.current.isSupported {
                DCDevice.current.generateToken { token, error in
                    if let error = error {
                        observer.onError(DeviceTokenError.underlyingError(error: error))
                    } else if let token = token {
                        self?.cachedToken = token
                        observer.onNext(token)
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
    
    
}
