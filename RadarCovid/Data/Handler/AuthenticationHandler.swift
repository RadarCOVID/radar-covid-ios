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
import LocalAuthentication

class AuthenticationHandler {
    
    
    func authenticate() -> Observable<Bool> {
        
        .create { observer in
        
            var error: NSError?
            let context = LAContext()
            
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let reason = "VENUE_BIOMETRIC_PROMPT_MESSAGE".localized

                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in

                    if success {
                        observer.onNext(true)
                        observer.onCompleted()
                    } else {
                        debugPrint(authenticationError.debugDescription)
                        observer.onError(authenticationError ?? "Not authorized")
                    }

                }
            } else {
                observer.onNext(false)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
}
