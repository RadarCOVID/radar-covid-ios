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

class StatsViewModel {
    
    var countriesUseCase: CountriesUseCase!
    var statsUseCase: StatisticsUseCase!
    var recentStats: BehaviorSubject<StatsItemModel?> = BehaviorSubject(value: nil)
    var interoperabilityCountryCount: BehaviorSubject<Int> = BehaviorSubject(value: 0)

    private var disposeBag = DisposeBag()
    
    func loadFirst() {
        countriesUseCase.loadCountries().subscribe().disposed(by: disposeBag)
        statsUseCase.getStats().map { (statsItemModel) -> StatsItemModel? in
            let statsItem: StatsItemModel? = statsItemModel
                .sorted(by: { (first, second) -> Bool in
                    first.date > second.date
                }).first
            return statsItem
        }.subscribe { [weak self] (statisItem) in
            self?.recentStats.onNext(statisItem)
        }.disposed(by: disposeBag)

        statsUseCase.loadStats().map { (statsItemModel) -> StatsItemModel? in
            let statsItem: StatsItemModel? = statsItemModel
                .sorted(by: { (first, second) -> Bool in
                    first.date > second.date
                }).first
            return statsItem
        }.subscribe { [weak self] (statisItem) in
            self?.recentStats.onNext(statisItem)
        }.disposed(by: disposeBag)
        
        countriesUseCase.getCountries().map { (countrys) -> Int in
            return countrys.count
        }.subscribe { [weak self] (countCotry) in
            self?.interoperabilityCountryCount.onNext(countCotry)
        }.disposed(by: disposeBag)
        
        countriesUseCase.loadCountries().map { (countrys) -> Int in
            return countrys.count
        }.subscribe { [weak self] (countCotry) in
            self?.interoperabilityCountryCount.onNext(countCotry)
        }.disposed(by: disposeBag)
    }
    
    private func getMoreRecentStats() -> Observable<StatsItemModel?> {
        return recentStats
    }
    
    func getlastUpdateDate() -> Observable<Date> {
        return self.getMoreRecentStats().map { (stats) -> Date in
            return stats?.date ?? Date()
        }
    }
    
    func getTotalAcummulatedDownloads() -> Observable<String> {
        return self.getMoreRecentStats().map { (stats) -> String in
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let formattedNumber = numberFormatter.string(from: NSNumber(value:stats?.applicationsDownloads.totalAcummulated ?? 0))
            return formattedNumber ?? ""
        }
    }
    
    func getTotalAcummulatedContagious() -> Observable<String> {
        return self.getMoreRecentStats().map { (stats) -> String in
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let formattedNumber = numberFormatter.string(from: NSNumber(value:stats?.communicatedContagions.totalAcummulated ?? 0))
            return formattedNumber ?? ""
        }
    }
    
    func getNumberInteroperabilityCountry() -> Observable<String> {
        return self.countriesUseCase.getCountries().map { (countrys) -> String in
            return "\(countrys.count)"
        }
    }
}
