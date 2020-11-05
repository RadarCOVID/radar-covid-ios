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

class LocalizationHolder {

    private static var _localizationMap: [String: String]?

    static var localizationMap: [String: String]? {
        get {
            if let source = source {
                _localizationMap = source.localizationMap
            } else if let userBack = UserDefaultsLocalizationRepository().getTexts() {
                _localizationMap = userBack
            } else {
                if let url = Bundle.main.url(forResource: "Localizable", withExtension: "strings"),
                    let stringsDict = NSDictionary(contentsOf: url) as? [String: String] {
                    print(stringsDict)
                    _localizationMap = stringsDict
                }
            }
            
            return _localizationMap
        }
        set (newLocalizationMap) {
            _localizationMap  = newLocalizationMap
        }

    }

    static var source: LocalizationSource?
}
