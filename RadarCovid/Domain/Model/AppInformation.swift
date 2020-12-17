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

struct AppInformation: Codable {

    public var radarStatus: Bool
    public var notificationStatus: Bool
    public var bluetooth: Bool
    public var lastSync: Date?
    public var onSync: Bool = false
    public var lastUpdate: Date {
        if let infoPath = Bundle.main.path(forResource: "Info.plist", ofType: nil),
           let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
           let infoDate = infoAttr[FileAttributeKey(rawValue: "NSFileCreationDate")] as? Date
        { return infoDate }
        return Date()
    }
    public var version: String = Config.version
    public var so: String = "\(UIDevice.current.systemName) (\(UIDevice.current.systemVersion))"
    public var model: String = UIDevice.modelName
    
    public init() {
        self.radarStatus = false
        self.notificationStatus = false
        self.bluetooth = false
        self.lastSync = nil
    }
    
    public init(radarStatus: Bool?, notificationStatus: Bool?, bluetooth: Bool?, lastSync: Date?) {
        self.radarStatus = radarStatus ?? false
        self.notificationStatus = notificationStatus ?? false
        self.bluetooth = bluetooth ?? false
        self.lastSync = lastSync
    }
    
    func checkSyncDate() -> Bool {
        return (
            self.getSyncDateDiff()
                ?? Int(MAXINTERP) <= 1
        )
    }
    
    func getSyncDateDiff() -> Int? {
        return lastSync?.betweenDate(otherDate: Date())
    }
}
