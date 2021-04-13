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

protocol CheckInInProgressUseCase {
    func checkStauts() -> Observable<Void>
    var maxCheckInHours: Int { get set }
}

class CheckInInProgressUseCaseImpl: CheckInInProgressUseCase {
    
    private let logger = Logger(label: "CheckInInProgressUseCaseImpl")
    
    private let secondsAnHour = 60 * 60
    
    var maxCheckInHours: Int = 6
    var reminderIntervalHours: Int = 3
    
    private let notificationHandler: NotificationHandler
    private let venueRecordRepository: VenueRecordRepository
    private let appStateHandler: AppStateHandler
    private let qrCheckRepository: QrCheckRepository
    
    init(notificationHandler: NotificationHandler,
         venueRecordRepository: VenueRecordRepository,
         qrCheckRepository: QrCheckRepository,
         appStateHandler: AppStateHandler,
         settinsRepository: SettingsRepository) {
        self.notificationHandler = notificationHandler
        self.venueRecordRepository = venueRecordRepository
        self.appStateHandler = appStateHandler
        self.qrCheckRepository = qrCheckRepository
        maxCheckInHours = Int(settinsRepository.getSettings()?.parameters?.venueConfiguration?.autoCheckout ?? 6)
        
        reminderIntervalHours = Int(settinsRepository.getSettings()?.parameters?.venueConfiguration?.recordNotification ?? 3)
    }
    
    func checkStauts() -> Observable<Void> {
        
        venueRecordRepository.getCurrentVenue().flatMap { [weak self] currentVenue -> Observable<Void> in
            guard let self = self else { return .empty() }
            if let currentVenue = currentVenue {
                self.sendReminder(currentVenue)
                return self.checkIfAutoCheckOut(currentVenue)
            }
            return .just(Void())
        }
    }
    
    private func checkIfAutoCheckOut(_ currentVenue: VenueRecord) -> Observable<Void> {
        var editVenue = currentVenue
        logger.debug("Checking if auto checkout. State: \(appStateHandler.state) currentVenue.checkInDate \(currentVenue.checkInDate)" )
        if appStateHandler.state != .active && isOutdated(venueRecord: currentVenue, interval: maxCheckInHours) {
            logger.debug("Checking out automatically")
            return self.venueRecordRepository.removeCurrent().flatMap {  _ -> Observable<Void> in
                editVenue.checkOutDate = Date()
                return self.venueRecordRepository.save(visit: editVenue).map { _ in Void() }
            }
        }
        return .just(Void())
    }
    
    private func sendReminder(_ currentVenue: VenueRecord) {
        let date = qrCheckRepository.getLastReminder()
        logger.debug("Checking if sendReminder currentVenue.checkInDate \(currentVenue.checkInDate) lastReminder: \(String(describing: date)), reminderIntervalHours \(reminderIntervalHours)")
        if checkIfSendReminder(venueRecord: currentVenue, lastReminder: date) {
            logger.debug("Sending reminder")
            notificationHandler.scheduleCheckInReminderNotification()
        }
    }
        
    private func isOutdated(date: Date, interval: Int) -> Bool {
        date.addingTimeInterval(Double(interval * secondsAnHour)) < Date()
    }
    
    private func isOutdated(venueRecord: VenueRecord, interval: Int) -> Bool {
        isOutdated(date: venueRecord.checkInDate, interval: interval)
    }
        
    private func checkIfSendReminder(venueRecord: VenueRecord, lastReminder: Date?) -> Bool {
        if let lastReminder = lastReminder {
            return isOutdated(date: lastReminder, interval: reminderIntervalHours)
        }
        return isOutdated(venueRecord: venueRecord, interval: reminderIntervalHours)
    }
    
    
}
 
