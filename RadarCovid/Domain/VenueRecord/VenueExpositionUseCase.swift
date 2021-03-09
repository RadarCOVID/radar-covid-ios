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

protocol VenueExpositionUseCase {
    var expositionInfo: Observable<VenueExpositionInfo> { get }
}

class VenueExpositionUseCaseImpl: VenueExpositionUseCase {
    
    
    private let venueRecordRepository: VenueRecordRepository
    
    init(venueRecordRepository: VenueRecordRepository) {
        self.venueRecordRepository = venueRecordRepository
    }
    
    private(set) var expositionInfo: Observable<VenueExpositionInfo> {
        get {
            expositionInfoFromVenueRecord()
        }
        set {
            
        }
    }
    
    func updateExpositionInfo() {
        
    }
    
    private func expositionInfoFromVenueRecord() -> Observable<VenueExpositionInfo> {
        venueRecordRepository.getVisited().map { visited in
            var expositionInfo = VenueExpositionInfo(level: .healthy, since: nil)
            visited?.forEach { venue in
                if venue.exposed {
                    expositionInfo.level = .exposed
                    if let checkOutDate = venue.checkOutDate {
                        if let since = expositionInfo.since {
                            if since < checkOutDate {
                                expositionInfo.since = checkOutDate
                            }
                        } else {
                            expositionInfo.since = checkOutDate
                        }
                    }

                }
            }
            return expositionInfo
        }
    }
    
    
}
