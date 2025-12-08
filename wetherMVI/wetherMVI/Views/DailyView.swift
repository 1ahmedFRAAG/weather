//
//  DailyView.swift
//  wetherMVI
//
//  Created by . on 08/12/2025.
//


import SwiftUI

struct DailyRow: View {
    let point: DailyPoint

    var body: some View {
        HStack {
            Text(dayText)
                .font(.subheadline)
            Spacer()
            VStack(alignment: .trailing) {
                if let max = point.tMax { Text("H: \(String(format: "%.0f", max))°") }
                if let min = point.tMin { Text("L: \(String(format: "%.0f", min))°") }
            }
            .font(.caption)
        }
        .padding(.vertical, 6)
    }

    private var dayText: String {
        if let d = point.date {
            let f = DateFormatter()
            f.dateStyle = .medium
            return f.string(from: d)
        }
        return point.dateISO
    }
}
