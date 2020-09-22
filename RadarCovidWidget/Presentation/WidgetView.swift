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
                if let error = entry.error {
                    Text(error.localizedDescription)
                } else if entry.exposition.level == .unknown {
                    Text("error.localizedDescription")
                } else {
                    Text(entry.exposition.level.rawValue)
                }
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
        .configurationDisplayName("RadarCOVID")
        .description("This is an example widget.")
    }
}

struct RadarCovidWidget_Previews: PreviewProvider {
    static var previews: some View {
        RadarCovidWidgetEntryView(entry: WidgetTimelineEntry(exposition: ExpositionInfo(level: .unknown), date: Date(), error: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
