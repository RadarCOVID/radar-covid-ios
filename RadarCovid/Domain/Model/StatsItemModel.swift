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

struct StatsModel: Codable {
    let stats: [StatsItemModel]
    
    static func mapperToStatsModel(items: [StatsItem]) -> StatsModel {
        return StatsModel(stats: items.map{ StatsItemModel.mappertToStatsItemModel(statsItem: $0) })
    }
}


struct StatsItemModel: Codable {

    let date: Date
    let applicationsDownloads: TotalsModel
    let communicatedContagions: TotalsModel

    static func mappertToStatsItemModel(statsItem: StatsItem) -> StatsItemModel {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.date(from:statsItem.date)!
        
        let applicationsDownloads = TotalsModel.mappertToTotalsModel(total: statsItem.applicationsDownloads)
        let communicatedContagions = TotalsModel.mappertToTotalsModel(total: statsItem.communicatedContagions)

     
        return StatsItemModel(date: date, applicationsDownloads: applicationsDownloads, communicatedContagions: communicatedContagions)
        
    }
    
   
}
