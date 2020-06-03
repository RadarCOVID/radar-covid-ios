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
import UserNotifications
import RxSwift

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {

    private let formatter: DateFormatter = DateFormatter()

    func setupNotifications() -> Observable<Bool> {
        .create { (observer) -> Disposable in
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.delegate = self
            let options: UNAuthorizationOptions = [.alert, .sound]
            notificationCenter.requestAuthorization(options: options) { didAllow, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    if !didAllow {
                        debugPrint("User has declined notifications")
                    }
                    observer.onNext(didAllow)
                    observer.onCompleted()
                }

            }
            return Disposables.create()
        }

    }

    func scheduleNotification(title: String, body: String, sound: UNNotificationSound) {

        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()

        content.title = title
        content.body = body
        content.sound = sound

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    func scheduleNotification(expositionInfo: ExpositionInfo) {
        var title, body: String?
        var sound: UNNotificationSound?
        formatter.dateFormat = "dd.MM.YYYY"
        switch expositionInfo.level {
            case .exposed:
                title = "NOTIFICATION_TITLE_EXPOSURE_HIGH".localized
                body = "NOTIFICATION_MESSAGE_EXPOSURE_HIGH".localized

                sound = .defaultCritical
            default:
                debugPrint("No notification for exposition: \(expositionInfo.level.rawValue)")
        }
        if let title = title, let body = body, let sound = sound {
            scheduleNotification(title: title, body: body, sound: sound)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Forground notifications.
        completionHandler([.alert, .sound, .badge])
    }

}
