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

struct SelectorItem {
    let id: String
    let description: String
    let objectOrigin: Any
    
    static func mapperFromItemLocale(itemLocale:ItemLocale) -> SelectorItem {
        return SelectorItem(id: itemLocale.id, description: itemLocale.description, objectOrigin:itemLocale)
    }
    
    static func mapperFromItemLocale(caData:CaData) -> SelectorItem {
        return SelectorItem(id: caData.id ?? "", description: caData.description ?? "", objectOrigin:caData)
    }
}

class SelectorHelperViewModel {
    
    static func generateTransformation(val: ItemLocale) -> SelectorItem {
        return SelectorItem.mapperFromItemLocale(itemLocale: val)
    }
    
    static func generateTransformation(val: [ItemLocale]) -> [SelectorItem] {
        return val.map { SelectorItem.mapperFromItemLocale(itemLocale: $0) }
    }
    
    static func generateTransformation(val: CaData) -> SelectorItem {
        return SelectorItem.mapperFromItemLocale(caData: val)
    }
    
    static func generateTransformation(val: [CaData]) -> [SelectorItem] {
        return val.map { SelectorItem.mapperFromItemLocale(caData: $0) }
    }
}
