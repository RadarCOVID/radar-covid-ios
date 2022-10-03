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


protocol IsNewRepository {
    
    func setIsNew()
    func isNew() -> Bool
    
}

class IsNewRepositoryImpl:UserDefaultsRepository, IsNewRepository {
    
    private static let kIsNew = "IsNewRepositoryImpl.kIsNew"
    
    func setIsNew() {
        userDefaults.set(true, forKey: IsNewRepositoryImpl.kIsNew)
    }
    
    func isNew() -> Bool {
        guard let data = userDefaults.object(forKey: IsNewRepositoryImpl.kIsNew) as? Bool else  {
            return false
        }
        
        return data
    }
    
    
}
