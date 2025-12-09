//
//  MockWeatherService.swift
//  wetherMVI
//
//  Created by . on 05/12/2025.
//

import Foundation
import Combine
/*
 
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
 
 */

final class MockWeatherService {
    private let hourlySubject: PassthroughSubject<[HourlyPoint], Never> = .init()
    private let dailySubject: PassthroughSubject<[DailyPoint], Never> = .init()
    init(){}
}

extension MockWeatherService: ForecastApiServiceProtocol {
    
    var hourlyPublisher: AnyPublisher<[HourlyPoint], Never> {
        hourlySubject.eraseToAnyPublisher()
    }
    
    var dailyPublisher: AnyPublisher<[DailyPoint], Never> {
        dailySubject.eraseToAnyPublisher()
    }
    
    func fetchWeather() async throws -> WeatherResponse {
        let simpleDate = Date()
        let isnow = ISO8601DateFormatter().string(from: simpleDate)
        
        let forcast = WeatherResponse(
            latitude: 30.1,
            longitude: 30.1,
            timezone: "Africa/Cairo",
            current: nil,
            hourly: nil,
            daily: nil
        )
        let mockhourspoints = (0...24).map { HourlyPoint(
            timeISO: isnow,
            temperature: 15 + Double($0),
        )
        }
        print(mockhourspoints.count)
        let mockdailypoints = (0..<7).map { indx in
            DailyPoint(
                dateISO: "2025-11-\(29 + indx)",
                sunriseISO: "sr \(indx)",
                sunsetISO: "ss \(indx)",
                precipHours: Double(10 + indx),
                tMax: 40.0,
                tMin: 10.0,
                windSpeedMax: 6.6,
                windGustMax: 12.8,
                windDirDominant: 1,
                radiation: 4.2
            )
        }
        print("mockdailypoints arry count is: \(mockdailypoints.count)")
        hourlySubject.send(mockhourspoints)
        dailySubject.send(mockdailypoints)
        return forcast
    }
    
    func fetchWeather(for location: String) async throws -> WeatherResponse {
        let simpleDate = Date()
        let isnow = ISO8601DateFormatter().string(from: simpleDate)
        
        let forcast = WeatherResponse(
            latitude: 30.1,
            longitude: 30.1,
            timezone: "Africa/Cairo",
            current: nil,
            hourly: nil,
            daily: nil
        )
        let mockhourspoints = (0...24).map { HourlyPoint(
            timeISO: isnow,
            temperature: 15 + Double($0),
        )
        }
        print(mockhourspoints.count)
        let mockdailypoints = (0..<7).map { indx in
            DailyPoint(
                dateISO: "2025-11-\(29 + indx)",
                sunriseISO: "sr \(indx)",
                sunsetISO: "ss \(indx)",
                precipHours: Double(10 + indx),
                tMax: 40.0,
                tMin: 10.0,
                windSpeedMax: 6.6,
                windGustMax: 12.8,
                windDirDominant: 1,
                radiation: 4.2
            )
        }
        print("mockdailypoints arry count is: \(mockdailypoints.count)")
        hourlySubject.send(mockhourspoints)
        dailySubject.send(mockdailypoints)
        return forcast
    }
    func startPolling(every seconds: TimeInterval) -> AnyCancellable {
            return Timer.publish(every: seconds, on: .main, in: .default)
            .autoconnect()
            .sink { _ in
                Task {
                    _ = try await self.fetchWeather()
                }
            }
    }
}

