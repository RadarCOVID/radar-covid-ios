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
import UIKit
import UserNotifications

class ReminderNotificationUseCase {
    
    private let settingsRepository: SettingsRepository
    private let notificationCenter = UNUserNotificationCenter.current()
    private let identifierNotification: String = "identifierReminderNotification"
    private let defaultTimerInterval: Int64 = 1440
    
    init(settingsRepository: SettingsRepository) {
        
        self.settingsRepository = settingsRepository
        
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                debugPrint("User has declined notifications")
            }
        }
    }
    
    func cancel() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifierNotification])
    }
    
    func start(_ timerInterval: Int64? = nil) {
        cancel()
        
        let notificationReminder = timerInterval ?? settingsRepository.getSettings()?.parameters?.notificationReminder ?? defaultTimerInterval
        
        scheduleNotification(notificationTitle: "NOTIFICATION_REMINDER_TITLE".localized,
                             notificationBody: "NOTIFICATION_REMINDER_BODY".localized,
                             timerInterval: ((notificationReminder) * 60))
    }
    
    func scheduleNotification(notificationTitle: String, notificationBody: String, timerInterval: Int64) {
        
        let content = UNMutableNotificationContent()
        let userActions = "User Actions"
        
        content.title = notificationTitle
        content.body = notificationBody
        content.sound = UNNotificationSound.default
        content.badge = 0
        content.categoryIdentifier = userActions
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timerInterval), repeats: true)
        let identifier = identifierNotification
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                debugPrint("Error \(error.localizedDescription)")
            }
        }
    }
    
}
