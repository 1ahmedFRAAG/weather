//
//  HourlyRow.swift
//  wetherMVI
//
//  Created by . on 08/12/2025.
//

import SwiftUI

struct HourlyRow: View {
    let point: HourlyPoint

    var body: some View {
        HStack {
            Text(timeText)
                .font(.subheadline)
            Spacer()
            Text("\(String(format: "%.1f", point.temperature)) °C")
                .font(.body)
        }
        .padding(.vertical, 6)
    }

    private var timeText: String {
        guard let date = point.timeDate else { return point.timeISO }
        let f = DateFormatter()
        f.dateFormat = "MMM d, HH:mm"
        return f.string(from: date)
    }
}

