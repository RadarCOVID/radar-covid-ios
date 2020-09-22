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
                        VStack(alignment: .leading, spacing: nil) {
                            ZStack {
                                Capsule()
                                    .fill(entry.color)
                                    .frame(height: 44, alignment: .center)
                                Text(entry.text)
                                    .foregroundColor(entry.textColor)
                                    .font(Font.system(size: 18, weight: .semibold, design: .rounded))
                            }
                            VStack(alignment: .leading, spacing: nil) {
                                if let syncDate = entry.lastSyncDateString {
                                    Text("Último chequeo:")
                                        .foregroundColor(Color("clearText"))
                                        .font(Font.system(size: 16, weight: .regular, design: .rounded))
                                    Text(syncDate)
                                        .foregroundColor(Color("clearText"))
                                        .font(Font.system(size: 16, weight: .regular, design: .rounded))
                                } else {
                                    Text("No existe registro de cuándo se realizó el último chequeo")
                                        .foregroundColor(Color("clearText"))
                                        .font(Font.system(size: 16, weight: .regular, design: .rounded))
                                }
                            }
                            Spacer()
                            if entry.isTracingActive {
                                Text("ACTIVO")
                                    .foregroundColor(Color("active"))
                                    .font(Font.system(size: 16, weight: .bold, design: .monospaced))
                            } else {
                                Text("INACTIVO")
                                    .foregroundColor(Color("inactive"))
                                    .font(Font.system(size: 16, weight: .bold, design: .monospaced))
                            }
                            Spacer()
                        }
                    }
                }
                .padding([.leading, .trailing, .top], 8)
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
        .supportedFamilies([.systemSmall])
    }
}

struct RadarCovidWidget_Previews: PreviewProvider {
    static var previews: some View {
        RadarCovidWidgetEntryView(entry: WidgetTimelineEntry(isTracingActive: true, lastSyncDate: nil, exposition: ExpositionInfo(level: .unknown), date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
