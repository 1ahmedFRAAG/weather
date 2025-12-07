//
//  WeatherStore.swift
//  wetherMVI
//
//  Created by . on 06/12/2025.
//

import Foundation
import Combine
import SwiftUI

class WeatherStore: ObservableObject {
    struct State {
        var currentweather: WeatherResponse?
        var hoursPoints: [HourlyPoint]?
        var dailyPoints: [DailyPoint]?
        var isLoading: Bool = false
        var error: Error?
    }
    
    @Published private(set) var state: State = State()
    
    // intents
    enum Intent {
        case fetchcurrentWeather
        case fetchWetherinLocation(city: String)
        
        case startPolling(interval: TimeInterval)
        case stopPolling
    }
    
    // dependancies
    private let api: ForecastApiServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    private var pollingCancellable: AnyCancellable?
    
    init(api: ForecastApiServiceProtocol) {
        self.api = api
        api.dailyPublisher
            .receive(on: DispatchQueue.main)
            .sink {[weak self] points in
                Task { @MainActor in
                    self?.state.dailyPoints = points
                }
            }.store(in: &cancellables)
        
        api.hourlyPublisher.receive(on: DispatchQueue.main).sink { [weak self] points in
            Task { @MainActor in
                self?.state.hoursPoints = points
            }
        }.store(in: &cancellables)
    }
    
    func send(_ intent: Intent) {
            switch intent {
            case .fetchcurrentWeather:
                Task { await performRefresh() }
            case .startPolling(let interval):
                pollingCancellable = api.startPolling(every: interval)
            case .stopPolling:
                pollingCancellable?.cancel()
                pollingCancellable = nil
            
            case .fetchWetherinLocation(let city):
                Task{
                    await performfetchWetherforLocation(city: city)
                }
            }
        }
    private func performRefresh() async {
        state.isLoading = true
        state.error = nil
           do {
               let resp = try await api.fetchWeather()
               // optionally map current temp
               state.currentweather = resp
               
               // hourly & daily are emitted via combine subjects and already assigned via sinks
           } catch {
               state.error = error
           }
           state.isLoading = false
       }
    
    private func performfetchWetherforLocation(city: String) async {
        state.isLoading = true
        state.error = nil
           do {
               let resp = try await api.fetchWeather(for: city)
               // optionally map current temp
               state.currentweather = resp
               
               // hourly & daily are emitted via combine subjects and already assigned via sinks
           } catch {
               state.error = error
           }
           state.isLoading = false
       }
}
