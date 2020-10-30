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
class TermsAcceptedRepository {
    
    private var userDefaults: UserDefaults
    private let termsAcceptedKey = "UserDefaultsTermsAccepted.accepted"
    
    init() {
        self.userDefaults = UserDefaults.standard
    }
    
    var termsAccepted: Bool {
        get {
            return userDefaults.bool(forKey: termsAcceptedKey)
        }
        set(newVal) {
            userDefaults.setValue(newVal, forKey: termsAcceptedKey)
        }
    }
    
}


