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

struct RadarCovidWidgetEntryView : View {
    var entry: WidgetTimelineProvider.Entry

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("background")
                Image("background-image")
                    .resizable()
                    .aspectRatio(geometry.size, contentMode: .fill)
                Text(entry.exposition.level.rawValue)
            }
        }
    }
}

@main
struct RadarCovidWidget: Widget {
    let kind: String = "RadarCovidWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetTimelineProvider()) { entry in
            RadarCovidWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct RadarCovidWidget_Previews: PreviewProvider {
    static var previews: some View {
        RadarCovidWidgetEntryView(entry: WidgetTimelineEntry(exposition: ExpositionInfo(level: .healthy), date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
