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

protocol ShareUseCase {
    func getUrl() -> String
    func getTitle() -> String
    func getBody() -> String
}

class ShareUseCaseImpl: ShareUseCase {

    private let settingsRepository: SettingsRepository

    init(settingsRepository: SettingsRepository) {
        self.settingsRepository = settingsRepository
    }
    
    func getUrl() -> String {
        return settingsRepository.getSettings()?.parameters?.radarCovidDownloadUrl ?? ""
    }
    
    func getTitle() -> String {
        guard let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String else {
            return ""
        }
        return displayName
    }
     
    func getBody() -> String {
        return "SHARE_TEXT".localized
    }
}
