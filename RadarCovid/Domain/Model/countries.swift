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

struct ItemCountry: Codable {

    let id: String
    let description: String

    static func mappertToKeyValueDto(keyValueDto: KeyValueDto) -> ItemCountry {
        ItemCountry.init(id: keyValueDto.id ?? "", description: keyValueDto.description ?? "")
    }
    
    static func mappertToDic(dic: [String: String?]) -> [ItemCountry] {
        var countries: [ItemCountry] = []
        
        dic.forEach { loc in
            countries.append(ItemCountry.init(id: loc.key, description: loc.value ?? ""))
        }
        return countries
    }
}

struct Countries: Codable {

    let itemCountries: [ItemCountry]
}
