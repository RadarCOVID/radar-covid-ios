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

class VenueListViewModel {
    
    private let disposeBag = DisposeBag()
    
    var venueRecordRepository: VenueRecordRepository!
    
    var venueMap: BehaviorSubject<[String:[VenueRecord]]> = BehaviorSubject<[String:[VenueRecord]]>(value: [:])
    
    private var allVenues: [VenueRecord] = []
    
    var showHidden = BehaviorSubject<Bool>(value: false)
    
    var error = PublishSubject<Error>()
    
    init() {
        showHidden.subscribe(onNext:  { [weak self] _ in  self?.refreshVenues() })
            .disposed(by: disposeBag)
    }
    
    func fetchVenues() {
//        venueRecordRepository.getVisited()
        mockedVenues()
            .subscribe(
                onNext: { [weak self] venues in
                    self?.allVenues = venues
                    self?.refreshVenues()
                }, onError: { [weak self] error in
                    debugPrint(error)
                    self?.error.onNext(error)
            }).disposed(by: disposeBag)
    }
    
    private func refreshVenues() {
        let map = groupByDate(allVenues.filter { venue in !((try? showHidden.value()) ?? false) || !venue.hidden })
        venueMap.onNext(map)
    }
    
    func hide(venue: VenueRecord) {
    }
    
    private func mockedVenues() -> Observable<[VenueRecord]> {
        .just( [VenueRecord(qr: "", checkOutId: nil, hidden: false, exposed: true, notified: false, name: "Un nombre muy largo de lugar que deberían ser mas de tres liiiiiineas", checkInDate: Calendar.current.date(byAdding: .minute, value: -31, to: Date()), checkOutDate: Date()),
            
               VenueRecord(qr: "", checkOutId: nil, hidden: true, exposed: true, notified: false, name: "Un nombre normal", checkInDate: Calendar.current.date(byAdding: .minute, value: -120, to: Date()), checkOutDate: Calendar.current.date(byAdding: .minute, value: -10, to: Date())),
               VenueRecord(qr: "", checkOutId: nil, hidden: true, exposed: true, notified: false, name: "Un nombre normal2", checkInDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()), checkOutDate: Calendar.current.date(byAdding: .hour, value: -28, to: Date())),
               VenueRecord(qr: "", checkOutId: nil, hidden: true, exposed: true, notified: false, name: "Un nombre normal2", checkInDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()), checkOutDate: Calendar.current.date(byAdding: .hour, value: -35, to: Date()))] )
    }
    
    private func groupByDate(_ venues: [VenueRecord]?) -> [String: [VenueRecord]] {
        var map: [String: [VenueRecord]] = [:]
        
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEEMMMMd")
        
        venues?.forEach { venue in
            if let checkOut = venue.checkOutDate {
                let section = dateFormatter.string(from: checkOut).capitalized
                let sectionVenues = map[section]
                if var sectionVenues = sectionVenues {
                    sectionVenues.append(venue)
                    map[section] = sectionVenues
                } else {
                    map[section] = [venue]
                }
            }
        }
        return map
    }
}
