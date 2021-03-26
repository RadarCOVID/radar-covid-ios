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
