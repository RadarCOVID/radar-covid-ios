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

protocol VenueNotifier {
        
    init (baseUrl: String)
    
    func getInfo(qrCode: String) -> Observable<VenueInfo>
    func checkOut(venue: VenueInfo, arrival: Date, departure: Date) -> Observable<VenueInfo>
    
}

class VenueNotifierImpl: VenueNotifier  {
    
    required init(baseUrl: String) {
        
    }
    
    func getInfo(qrCode: String) -> Observable<VenueInfo> {
        .empty()
    }
    
    func checkOut(venue: VenueInfo, arrival: Date, departure: Date) -> Observable<VenueInfo> {
        .empty()
    }
    
}
