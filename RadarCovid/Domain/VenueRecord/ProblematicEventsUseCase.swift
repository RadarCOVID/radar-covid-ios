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
import Logging

protocol ProblematicEventsUseCase {
    func sync() -> Observable<Void>
    var maxMinutesToKeep: Int { get set }
}

class ProblematicEventsUseCaseImpl : ProblematicEventsUseCase {
    
    private let logger = Logger(label: "ProblematicEventsUseCaseImpl")
    
    private let venueNotifier: VenueNotifier
    private let venueRecordRepository: VenueRecordRepository
    private let problematicEventsApi: ProblematicEventsApi
    private let notificationHandler: NotificationHandler
    private let qrCheckRepository: QrCheckRepository
    private let venueExpositionUseCase: VenueExpositionUseCase
    private let expositionRepository: ExpositionInfoRepository
    
    var maxMinutesToKeep: Int
    
    init(venueRecordRepository: VenueRecordRepository, qrCheckRepository: QrCheckRepository, venueNotifier: VenueNotifier, problematicEventsApi: ProblematicEventsApi, notificationHandler: NotificationHandler,
         settingsRepository: SettingsRepository,
         venueExpositionUseCase: VenueExpositionUseCase, expositionRepository: ExpositionInfoRepository) {
        self.venueNotifier = venueNotifier
        self.venueRecordRepository = venueRecordRepository
        self.problematicEventsApi = problematicEventsApi
        self.notificationHandler = notificationHandler
        self.qrCheckRepository = qrCheckRepository
        self.venueExpositionUseCase = venueExpositionUseCase
        self.expositionRepository = expositionRepository
        maxMinutesToKeep = Int(settingsRepository.getSettings()?.parameters?.venueConfiguration?.quarentineAfterExposed ?? (14 * 24 * 60) )
    }
    
    func sync() -> Observable<Void> {
        
        let tag = qrCheckRepository.getSyncTag()
        
        logger.debug("Problematic Event Sync run tag: \(String(describing: tag))")
        
        return problematicEventsApi.getProblematicEvents(tag: tag)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap { [weak self] problematicEventData -> Observable<Void> in
        
            guard let self = self else { return .empty() }
            
            let problematicEvents = problematicEventData.problematicEvents
    
                var result = Observable<Void>.empty()
                
            if !problematicEvents.isEmpty {
                result = self.checkProblematicEvents(problematicEvents)
            }

            self.qrCheckRepository.save(syncTag: problematicEventData.tag)
            self.qrCheckRepository.save(lastCheck: Date())
            return result
        }
    }
    
    private func checkProblematicEvents(_ problematicEvents: [ProblematicEvent]) -> Observable<Void> {
        let exposedEvents = self.venueNotifier.checkForMatches(problematicEvents: problematicEvents)
        
        if !exposedEvents.isEmpty {
            
            self.logger.debug("Received \(exposedEvents.count) problematic events")
            
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
                
                return self.venueRecordRepository.update(visited: newVisited).map { _ in
                    self.venueExpositionUseCase.updateExpositionInfo()
                    return Void()
                }
            }
        }
        
        return .empty()
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
        
        let exposition = expositionRepository.getExpositionInfo()
        
        if notify && exposition?.level != .infected {
            notificationHandler.scheduleExposedEventNotification()
        }
        return modifiedVenues
    }
    
    private func isOutdated(_ venueRecord: VenueRecord) -> Bool {
        if let checkoutDate = venueRecord.checkOutDate {
            return checkoutDate.addingTimeInterval(Double(maxMinutesToKeep * 60)) < Date()
        }
        return false
    }
    
}
