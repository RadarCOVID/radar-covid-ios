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

protocol ProblematicEventsUseCase {
    func sync() -> Observable<Void>
    var maxDaysToKeep: Int { get set }
}

class ProblematicEventsUseCaseImpl : ProblematicEventsUseCase {
    
    private let secondsADay = 24 * 60 * 60
    
    private let venueNotifier: VenueNotifier
    private let venueRecordRepository: VenueRecordRepository
    private let problematicEventsApi: ProblematicEventsApi
    private let notificationHandler: NotificationHandler
    
    var maxDaysToKeep: Int = 14
    
    init(venueRecordRepository: VenueRecordRepository, venueNotifier: VenueNotifier, problematicEventsApi: ProblematicEventsApi, notificationHandler: NotificationHandler) {
        self.venueNotifier = venueNotifier
        self.venueRecordRepository = venueRecordRepository
        self.problematicEventsApi = problematicEventsApi
        self.notificationHandler = notificationHandler
    }
    
    func sync() -> Observable<Void> {
        
        problematicEventsApi.getProblematicEvents(tag: "").flatMap { [weak self] problematicEventData -> Observable<Void> in
            
            guard let self = self else { return .empty() }
            
            let problematicEvents = problematicEventData.problematicEvents
            
            let exposedEvents = self.venueNotifier.checkForMatches(problematicEvents: problematicEvents)
            
            if !exposedEvents.isEmpty {
                
                return self.venueRecordRepository.getVisited().flatMap { visitedVenues -> Observable<Void> in
                    var newVisited: [VenueRecord] = []
                    
                    visitedVenues?.forEach { v in
                        var visited = v
                        exposedEvents.forEach { exposed in
                            if exposed.checkinId == visited.checkOutId {
                                visited.exposed = true
                            }
                        }
                        if !self.isOutdated(visited) {
                            newVisited.append(visited)
                        }
                        
                    }
                    
                    newVisited = self.notifyIfExposed(newVisited)
                    
                    return self.venueRecordRepository.update(visited: newVisited).map { _ in Void() }
                }
            }
            
            return .just(Void())
        }
    }
    
    private func notifyIfExposed(_ venues: [VenueRecord]) -> [VenueRecord] {
        var notify = false
        var modifiedVenues: [VenueRecord] = []
        venues.forEach { v in
            var venue = v
            notify = notify || (v.exposed && !v.notified)
            venue.notified = true
            modifiedVenues.append(venue)
        }
        if notify {
            notificationHandler.scheduleExposedEventNotification()
        }
        return modifiedVenues
    }
    
    private func isOutdated(_ venueRecord: VenueRecord) -> Bool {
        if let checkoutDate = venueRecord.checkOutDate {
            return checkoutDate.addingTimeInterval(Double(maxDaysToKeep * secondsADay)) < Date()
        }
        return false
    }
    
}
