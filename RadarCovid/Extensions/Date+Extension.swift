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
extension Date {

    static let appDateFormat: String = "dd.MM.YYYY"
    
    func years(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.year], from: sinceDate, to: self).year
    }

    func months(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.month], from: sinceDate, to: self).month
    }

    func days(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.day], from: sinceDate, to: self).day
    }

    func hours(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.hour], from: sinceDate, to: self).hour
    }

    func minutes(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.minute], from: sinceDate, to: self).minute
    }

    func seconds(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.second], from: sinceDate, to: self).second
    }
    
    func getYears() -> Int? {
        return Calendar.current.component(.year, from: self)
    }

    func getMonths() -> Int? {
        return Calendar.current.component(.month, from: self)
    }

    func getDays() -> Int? {
        return Calendar.current.component(.day, from: self)
    }
    
    func getAccesibilityDate() -> String? {
        guard let day = self.getDays() else {
            return nil
        }
        guard let month = self.getMonths() else {
            return nil
        }
        guard let year = self.getYears() else {
            return nil
        }
        
        return "MY_HEALTH_DIAGNOSTIC_DATE_DAY".localized + "\(day) " + "MY_HEALTH_DIAGNOSTIC_DATE_MONTH".localized + "\(month) " + "MY_HEALTH_DIAGNOSTIC_DATE_YEAR".localized + " \(year)"
    }

}
