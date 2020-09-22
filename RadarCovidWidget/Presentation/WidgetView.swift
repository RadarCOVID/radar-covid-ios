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
                VStack {
                    if let error = entry.error {
                        Text(error.localizedDescription)
                            .foregroundColor(Color("accent"))
                        Spacer()
                    } else {
                        VStack(alignment: .leading, spacing: nil, content: {
                            ZStack {
                                Capsule()
                                    .fill(entry.color)
                                    .frame(height: 44, alignment: .center)
                                Text(entry.text)
                                    .foregroundColor(entry.textColor)
                                    .font(Font.system(size: 18, weight: .semibold, design: .rounded))
                            }
                            VStack(alignment: .leading, spacing: nil, content: {
                                Text("Último chequeo:")
                                    .foregroundColor(Color("clearText"))
                                    .font(Font.system(size: 16, weight: .regular, design: .rounded))
                                Text(entry.dateString)
                                    .foregroundColor(Color("clearText"))
                                    .font(Font.system(size: 16, weight: .regular, design: .rounded))
                            })
                            Spacer()
                        })
                    }
                }
                .padding([.leading, .trailing], 8)
                .padding([.top], 8)
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
        .supportedFamilies([.systemSmall])
    }
}

struct RadarCovidWidget_Previews: PreviewProvider {
    static var previews: some View {
        RadarCovidWidgetEntryView(entry: WidgetTimelineEntry(exposition: ExpositionInfo(level: .unknown), date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
