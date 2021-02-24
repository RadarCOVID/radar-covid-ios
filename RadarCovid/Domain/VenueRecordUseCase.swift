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

protocol VenueRecordUseCase {
    func isCheckedIn() -> Bool
    func checkIn(venue: VenueRecord)
    func checkOut(date: Date)
    func cancelCheckIn()
}

class VenueRecordUseCaseImpl : VenueRecordUseCase{

    private let venueRecordRepository: VenueRecordRepository
    
    init(venueRecordRepository: VenueRecordRepository) {
        self.venueRecordRepository = venueRecordRepository
    }
    
    func isCheckedIn() -> Bool {
        venueRecordRepository.getCurrentVenue() != nil
    }
    
    func checkIn(venue: VenueRecord) {
        venueRecordRepository.save(current: venue)
    }
    
    func checkOut(date: Date) {
        venueRecordRepository.removeCurrent()
    }
    
    func cancelCheckIn() {
        venueRecordRepository.removeCurrent()
    }
}

