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
    
    var venueMap: BehaviorSubject<[TimeInterval:[VenueRecord]]> = BehaviorSubject<[TimeInterval:[VenueRecord]]>(value: [:])
    
    private var allVenues: [VenueRecord] = []
    
    var showHidden = BehaviorSubject<Bool>(value: false)
    
    var numHidden =  BehaviorSubject<Int>(value: 0)
    
    var error = PublishSubject<Error>()
    
    init() {
        showHidden.subscribe(onNext:  { [weak self] _ in  self?.refreshVenues() })
            .disposed(by: disposeBag)
    }
    
    func fetchVenues() {
        venueRecordRepository.getVisited()
            .subscribe(
                onNext: { [weak self] venues in
                    self?.allVenues = venues ?? []
                    self?.refreshVenues()
                }, onError: { [weak self] error in
                    debugPrint(error)
                    self?.error.onNext(error)
            }).disposed(by: disposeBag)
    }
    
    private func refreshVenues() {
        let map = groupByDate(allVenues.filter { venue in
                ((try? showHidden.value()) ?? false) || !venue.hidden
            
        })
        venueMap.onNext(map)
        numHidden.onNext(countHidden())
    }
    
    func toggleHide(venue: VenueRecord) {
        
        allVenues = allVenues.map { v in
            var newVenue = v
            if venue.checkOutId == v.checkOutId {
                newVenue.hidden = !v.hidden
            }
            return newVenue
        }
        
        venueRecordRepository.update(visited: allVenues).subscribe(
            onNext: { [weak self] venues in
                self?.refreshVenues()
            }, onError: { [weak self] error in
                debugPrint(error)
                self?.error.onNext(error)
        }).disposed(by: disposeBag)
    }
    
//    TODO: remove 
    private func mockedVenues() -> Observable<[VenueRecord]> {
        .just( [VenueRecord(qr: "", checkOutId: "1", hidden: false, exposed: true, notified: false, name: "Un nombre muy largo de lugar que deberían ser mas de tres liiiiiineas", checkInDate: Calendar.current.date(byAdding: .minute, value: -31, to: Date())!, checkOutDate: Date()),
            
                VenueRecord(qr: "", checkOutId: "2", hidden: true, exposed: true, notified: false, name: "Un nombre normal", checkInDate: Calendar.current.date(byAdding: .minute, value: -120, to: Date())!, checkOutDate: Calendar.current.date(byAdding: .minute, value: -10, to: Date())),
                VenueRecord(qr: "", checkOutId: "3", hidden: true, exposed: true, notified: false, name: "Un nombre normal2", checkInDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, checkOutDate: Calendar.current.date(byAdding: .hour, value: -28, to: Date())),
                VenueRecord(qr: "", checkOutId: "4", hidden: true, exposed: true, notified: false, name: "Un nombre normal2", checkInDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, checkOutDate: Calendar.current.date(byAdding: .hour, value: -35, to: Date()))] )
    }
    
    private func countHidden() -> Int {
        allVenues.filter { $0.hidden }.count
    }
    
    private func groupByDate(_ venues: [VenueRecord]?) -> [TimeInterval: [VenueRecord]] {
        var map: [TimeInterval:[VenueRecord]] = [:]
        
        venues?.sorted(by: { $0.checkInDate >  $1.checkInDate })
            .forEach { venue in
            
                let section = Calendar.current.startOfDay(for: venue.checkInDate).timeIntervalSince1970
            let sectionVenues = map[section]
            if var sectionVenues = sectionVenues {
                sectionVenues.append(venue)
                map[section] = sectionVenues
            } else {
                map[section] = [venue]
            }

        }
        return map
    }
    
}
