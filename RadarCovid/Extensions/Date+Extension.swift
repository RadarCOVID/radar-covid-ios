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
    static let appDateFormatWithBar: String = "dd/MM/YYYY"
    
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
    
    func getStartOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func getAppDateFormat() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate(Date.appDateFormat)
        return df.string(from: self)
    }
    
    func getMonthName() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMMM")
        return df.string(from: self)
    }

    func getHourFormatter() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("HH:mm")
        return df.string(from: self)
    }
    
    func betweenDate(otherDate: Date) -> Int? {
        let calendar = Calendar.current

        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: otherDate)

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
        return components.day
    }
    
    func getAccesibilityDate() -> String? {
        return DateFormatter.localizedString(from: self, dateStyle: .full, timeStyle: .none)
    }

}
