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

protocol VenueRecordUseCase {
    func getVenueInfo(qrCode: String) -> Observable<VenueInfo>
    func isCheckedIn() -> Bool
    func checkIn(venue: VenueRecord)
    func checkOut(date: Date) -> Observable<Void>
    func cancelCheckIn()
}

class VenueRecordUseCaseImpl : VenueRecordUseCase{

    private let venueRecordRepository: VenueRecordRepository
    private let venueNotifier: VenueNotifier
    
    init(venueRecordRepository: VenueRecordRepository, venueNotifier: VenueNotifier) {
        self.venueRecordRepository = venueRecordRepository
        self.venueNotifier = venueNotifier
    }
    
    func getVenueInfo(qrCode: String) -> Observable<VenueInfo> {
        venueNotifier.getInfo(qrCode: qrCode)
    }
    
    func isCheckedIn() -> Bool {
        venueRecordRepository.getCurrentVenue() != nil
    }
    
    func checkIn(venue: VenueRecord) {
        venueRecordRepository.save(current: venue)
    }
    
    func checkOut(date: Date) -> Observable<Void> {
        if let current = venueRecordRepository.getCurrentVenue() {
            return venueNotifier.getInfo(qrCode: current.qr).flatMap { [weak self] venueInfo -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.venueNotifier.checkOut(venue: venueInfo, arrival: current.checkIn, departure: date)
                    .map { venueInfo in
                        self.venueRecordRepository.removeCurrent()
                        return Void()
                    }
            }
        }
        return .error(VenueRecordError.noCheckedIn)
    }
    
    func cancelCheckIn() {
        venueRecordRepository.removeCurrent()
    }
}

enum VenueRecordError: Error {
    case noCheckedIn
}

