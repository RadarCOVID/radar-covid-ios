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

class StatisticsUseCase {

    private let statisticsRepository: StatisticsRepository
    private let statisticsApi: StatisticsAPI

    private var stats: [StatsItemModel]?

    init(statisticsRepository: StatisticsRepository,
         statisticsApi: StatisticsAPI) {
        self.statisticsRepository = statisticsRepository
        self.statisticsApi = statisticsApi
    }

    func loadStats() -> Observable<[StatsItemModel]> {
        
        return statisticsApi.getStatistics().map { [weak self] statsDTO in
            let statsModel = StatsModel.mapperToStatsModel(items: statsDTO)
         
           
            self?.statisticsRepository.setStatistics(statsModel.stats)
            self?.stats = statsModel.stats
            return self?.stats ?? []
        }
        

    }

    public func getStats() -> Observable<[StatsItemModel]> {
        .deferred { [weak self] in
            if let stats = self?.stats {
                return .just(stats)
            }
            if let stats = self?.statisticsRepository.getStatistics() {
                return .just(stats)
            }
            return self?.loadStats() ?? .empty()
        }
    }

  
}
