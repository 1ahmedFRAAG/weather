//
//  ContentView.swift
//  wetherMVI
//
//  Created by . on 01/12/2025.
//



import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: WeatherStore

    var body: some View {
        NavigationView {
            VStack {
                header
                loadingView
                hourlyList
                actionButtons
            }
            .navigationTitle("Weather — Cairo")
            .onAppear {
                store.send(.fetchcurrentWeather)
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                if let temp = store.state.currentweather?.current?.temperature_2m {
                    Text("\(String(format: "%.1f", temp)) °C")
                        .font(.largeTitle).bold()
                } else {
                    Text("-- °C")
                        .font(.largeTitle).bold()
                }
                Text("Cairo — Current")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private var loadingView: some View {
        Group {
            if store.state.isLoading {
                ProgressView("Loading…")
                    .padding()
            }
        }
    }

    private var hourlyList: some View {
        List {
            Section("Hourly") {
                ForEach(store.state.hoursPoints!.prefix(24)) { point in
                    HourlyRow(point: point)
                }
            }
//            Section("Daily") {
//                ForEach(store.state.daily) { day in
////                    DailyRow(point: day)
//                }
//            }
        }
        .listStyle(.insetGrouped)
    }

    private var actionButtons: some View {
        HStack {
            Button(action: { store.send(.fetchcurrentWeather) }) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            Button(action: { store.send(.startPolling(interval: 60)) }) {
                Label("Start Polling", systemImage: "play.fill")
            }
            Button(action: { store.send(.stopPolling) }) {
                Label("Stop Polling", systemImage: "stop.fill")
            }
        }
        .padding()
    }
}

private struct AlertItem: Identifiable {
    let id: UUID
    let text: String
}


#Preview {
    ContentView()
}
