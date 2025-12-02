//
//  WeatherService.swift
//  wetherMVI
//
//  Created by . on 02/12/2025.
//


import Foundation
import Combine

protocol ForecastApiServiceProtocol {
    // performe
    func fetchForecast() async throws -> ForecastResponse
    
    /// A request to fetch data based on location changes or search for city
    func fetchForecast(for location: String) -> AnyPublisher<ForecastResponse, Error>
    
    /// A Combine publisher that emits hourly updates (e.g. when a new forecast is fetched)
    var hourlyPublisher: AnyPublisher<[HourlyPoint], Never> { get }
    
    /// A Combine publisher that emits daily updates
    var dailyPublisher: AnyPublisher<[DailyPoint], Never> { get }
    
    /// start periodic polling (e.g. every N seconds) - returns cancellable
    func startPolling(every seconds: TimeInterval) -> AnyCancellable
}

final class ForecastApiService: ForecastApiServiceProtocol {
    
    private let urlString = "https://api.open-meteo.com/v1/forecast?latitude=30.0626&longitude=31.2497&daily=sunrise,sunset,precipitation_hours,temperature_2m_max,temperature_2m_min,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant,shortwave_radiation_sum&hourly=temperature_2m&current=is_day,rain,cloud_cover,snowfall,temperature_2m,wind_speed_10m,wind_direction_10m,wind_gusts_10m&timezone=Africa%2FCairo"
    
    private let hourlySubject = PassthroughSubject<[HourlyPoint], Never>()
    private let dailySubject = PassthroughSubject<[DailyPoint], Never>()
    private var pollingCancellable: AnyCancellable?
    
    var hourlyPublisher: AnyPublisher<[HourlyPoint], Never> { hourlySubject.eraseToAnyPublisher() }
    var dailyPublisher: AnyPublisher<[DailyPoint], Never> { dailySubject.eraseToAnyPublisher() }
    
    
    func fetchForecast() async throws -> ForecastResponse {
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let forecastResponse = try decoder.decode(ForecastResponse.self, from: data)
        
        if let hourly = forecastResponse.hourly?.hourlyPoints {
            hourlySubject.send(hourly)
        }
        
        if let daily = forecastResponse.daily?.toDailyPoints() {
            dailySubject.send(daily)
        }
        
        return forecastResponse
    }
    
    // TODO: - update the api for location changes
    func fetchForecast(for location: String) -> AnyPublisher<ForecastResponse, Error> {
        Empty<ForecastResponse, Error>()
            .eraseToAnyPublisher()
    }
    
    func startPolling(every seconds: TimeInterval) -> AnyCancellable {
        pollingCancellable?.cancel()
        let publisher = Timer.publish(every: seconds, on: .main, in: .common).autoconnect()
            .flatMap { _ in
                Future<ForecastResponse, Never> { promise in
                    Task {
                        do {
                            let resp = try await self.fetchForecast()
                            promise(.success(resp))
                        } catch {
                            // swallow errors for polling demo; in real app report them
                            promise(.success(ForecastResponse(latitude: 0, longitude: 0, timezone: "", current: nil, hourly: nil, daily: nil)))
                        }
                    }
                }
            }
            .sink(
                receiveValue: { _ in /* we already emitted via subjects in fetchForecast() */
                })
            
        
        pollingCancellable = AnyCancellable { publisher.cancel() }
        return pollingCancellable!
    }
}
