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

protocol ExposureRecordRepository {
    
    func getExposureRecords() -> [ContactExpositionInfo]
    func addExposure(exposureInfo: ContactExpositionInfo)
    func removeExposures()
    
}


class ExposureRecordRepositoryImpl:UserDefaultsRepository, ExposureRecordRepository {
    
    private static let kExposureRecords = "ExposureRecordRepositoryImpl.kexposureRecords"
    
    func getExposureRecords() -> [ContactExpositionInfo] {
        guard let data = userDefaults.object(forKey: ExposureRecordRepositoryImpl.kExposureRecords) as? Data else  {
            return []
        }
        
        return try! decoder.decode([ContactExpositionInfo].self, from: data)

    }
    
    func addExposure(exposureInfo: ContactExpositionInfo) {
        var records = getExposureRecords()
        records.append(exposureInfo)
        userDefaults.set(records, forKey: ExposureRecordRepositoryImpl.kExposureRecords)
    }
    
    func removeExposures() {
        userDefaults.removeObject(forKey: ExposureRecordRepositoryImpl.kExposureRecords)
    }
    
    
}
