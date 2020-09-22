//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import WidgetKit
import SwiftUI

struct WidgetTimelineProvider: TimelineProvider {
    var presenter = <~WidgetPresenter.self

    func placeholder(in context: Context) -> WidgetTimelineEntry {
        currentEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetTimelineEntry) -> ()) {
        let entry = currentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetTimelineEntry>) -> ()) {
        var entries: [WidgetTimelineEntry] = []

        let currentDate = Date()
        for hourOffset in 0..<5 {
            guard let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) else { continue }
            let entry = currentEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func currentEntry(date: Date? = Date()) -> WidgetTimelineEntry {
        if let error = presenter.expositionError {
            return WidgetTimelineEntry(exposition: ExpositionInfo(level: .unknown), date: date ?? Date(), error: error)
        } else if let error = presenter.expositionInfo.error {
            return WidgetTimelineEntry(exposition: presenter.expositionInfo, date: date ?? Date(), error: error)
        } else {
            return WidgetTimelineEntry(exposition: presenter.expositionInfo, date: date ?? Date(), error: nil)
        }
    }
}
