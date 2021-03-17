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
    func getVenueInfo(qrCode: String) -> Observable<VenueRecord>
    func isCheckedIn() -> Observable<Bool>
    func getCurrentVenue() -> Observable<VenueRecord?>
    func checkIn(venue: VenueRecord) -> Observable<VenueRecord>
    func checkOut(date: Date) -> Observable<Void>
    func cancelCheckIn() -> Observable<Void>
}

class VenueRecordUseCaseImpl : VenueRecordUseCase{

    private let venueRecordRepository: VenueRecordRepository
    private let venueNotifier: VenueNotifier

    init(venueRecordRepository: VenueRecordRepository, venueNotifier: VenueNotifier) {
        self.venueRecordRepository = venueRecordRepository
        self.venueNotifier = venueNotifier
    }
    
    func getVenueInfo(qrCode: String) -> Observable<VenueRecord> {
        venueNotifier.getInfo(qrCode: qrCode).map { VenueRecord(qr: qrCode, name: $0.name, checkInDate: Date()) }
    }
    
    func isCheckedIn() -> Observable<Bool> {
        venueRecordRepository.getCurrentVenue().map { $0 != nil }
    }
    
    func getCurrentVenue() -> Observable<VenueRecord?> {
        venueRecordRepository.getCurrentVenue()
    }
    
    func checkIn(venue: VenueRecord) -> Observable<VenueRecord> {
        venueRecordRepository.save(current: venue)
    }
    
    func checkOut(date: Date) -> Observable<Void> {
        venueRecordRepository.getCurrentVenue().flatMap { [weak self] current -> Observable<Void> in
            guard let self = self else { return .empty() }
            if var current = current {
                return self.venueNotifier.getInfo(qrCode: current.qr).flatMap { venueInfo -> Observable<Void> in
                    self.venueNotifier.checkOut(venue: venueInfo, arrival: current.checkInDate, departure: date)
                        .flatMap { checkOutId -> Observable<Void> in
                            current.name = venueInfo.name
                            current.checkOutId = checkOutId
                            current.checkOutDate = date
                            return self.venueRecordRepository.removeCurrent().flatMap { () -> Observable<Void> in
                                self.venueRecordRepository.save(visit: current).map { _ in Void () }
                            }
                        }
                }
            }
            return .error(VenueRecordError.noCheckedIn)
        }
    }
    
    func cancelCheckIn() -> Observable<Void> {
        venueRecordRepository.removeCurrent()
    }
}

enum VenueRecordError: Error {
    case noCheckedIn
}

