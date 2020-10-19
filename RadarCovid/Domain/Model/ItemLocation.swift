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

struct ItemLocale: Codable {

    let id: String
    let description: String

    static func mappertToKeyValueDto(keyValueDto: KeyValueDto) -> ItemLocale {
        ItemLocale.init(id: keyValueDto.id ?? "", description: keyValueDto.description ?? "")
    }
    
    static func mappertToDic(dic: [String: String?]) -> [ItemLocale] {
        var locales: [ItemLocale] = []
        
        dic.forEach { loc in
            locales.append(ItemLocale.init(id: loc.key, description: loc.value ?? ""))
        }
        return locales
    }
}

struct Locales: Codable {

    let itemLocales: [ItemLocale]
}
