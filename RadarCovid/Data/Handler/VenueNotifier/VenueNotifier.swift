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
import CrowdNotifierSDK

protocol VenueNotifier {
        
    init (baseUrl: String)
    
    func getInfo(qrCode: String) -> Observable<VenueInfo>
    func checkOut(venue: VenueInfo, arrival: Date, departure: Date) -> Observable<String>
    func checkForMatches(problematicEvents: [ProblematicEvent]) -> [ExposureEvent]
    
}

class VenueNotifierImpl: VenueNotifier  {
    
    private let baseUrl: String
    
    required init(baseUrl: String) {
        self.baseUrl = baseUrl
        CrowdNotifier.initialize()
    }
    
    func getInfo(qrCode: String) -> Observable<VenueInfo> {
        .create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            switch CrowdNotifier.getVenueInfo(qrCode: qrCode, baseUrl: self.baseUrl) {
            case .success(let venueInfo):
                observer.on(.next(venueInfo))
            case .failure(let error):
                observer.on(.error(error))
            }
            return Disposables.create()
        }
    }
    
    func checkOut(venue: VenueInfo, arrival: Date, departure: Date) -> Observable<String> {
        .create { observer in
            switch CrowdNotifier.addCheckin(venueInfo: venue, arrivalTime: arrival, departureTime: departure) {
            case .success(let checkinId):
                observer.on(.next(checkinId))
            case .failure(let error):
                observer.on(.error(error))
            }
            return Disposables.create()
        }
    }
    
    func checkForMatches(problematicEvents: [ProblematicEvent]) -> [ExposureEvent] {
        let peis = problematicEvents.map { pe in
            ProblematicEventInfo(
                privateKey: pe.identity.bytes,
                r2: pe.secretKeyForIdentity.bytes,
                entry: Date(timeIntervalSince1970: TimeInterval(pe.startTime / 1000)),
                exit:  Date(timeIntervalSince1970: TimeInterval(pe.endTime / 1000)),
                message: pe.message.bytes,
                nonce: pe.nonce.bytes)
        }
        return CrowdNotifier.checkForMatches(publishedSKs: peis)
    }
    

    
}
