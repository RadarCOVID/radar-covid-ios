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
                    } else if entry.exposition.level == .unknown {
                        Text("Nivel de exposición desconocido. Comprueba que RadarCOVID está funcionando correctamente.")
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
                                    .font(Font.custom("Muli-ExtraBold", size: 16.0))
                            }
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
