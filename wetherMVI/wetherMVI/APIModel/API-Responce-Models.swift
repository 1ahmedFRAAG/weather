
import Foundation

// MARK: - Top-level response
struct ForecastResponse: Codable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let current: CurrentResponse?
    let hourly: HourlyResponse?
    let daily: DailyResponse?
}


// MARK: Current
struct CurrentResponse: Codable {
    let time: String
    let interval: Int?
    let is_day: Int?
    let rain: Double?
    let cloud_cover: Int?
    let snowfall: Double?
    let temperature_2m: Double?
    let wind_speed_10m: Double?
    let wind_direction_10m: Int?
    let wind_gusts_10m: Double?
}


// MARK: Hourly (arrays)
struct HourlyResponse: Codable {
    let time: [String]
    let temperature_2m: [Double]

    // map to typed hourly points
    private func toHourlyPoints() -> [HourlyPoint] {
        let count = min(time.count, temperature_2m.count)
        return (0..<count).map { idx in
            HourlyPoint(timeISO: time[idx], temperature: temperature_2m[idx])
        }
    }
    
    var hourlyPoints: [HourlyPoint] {
        zip(time, temperature_2m).map {
            HourlyPoint(timeISO: $0, temperature: $1)
        }
    }
}

// MARK: Daily (arrays)
struct DailyResponse: Codable {
    let time: [String]
    let sunrise: [String]?
    let sunset: [String]?
    let precipitation_hours: [Double]?
    let temperature_2m_max: [Double]?
    let temperature_2m_min: [Double]?
    let wind_speed_10m_max: [Double]?
    let wind_gusts_10m_max: [Double]?
    let wind_direction_10m_dominant: [Int]?
    let shortwave_radiation_sum: [Double]?

    func toDailyPoints() -> [DailyPoint] {
        let count = time.count
        return (0..<count).map { idx in
            DailyPoint(
                dateISO: time[idx],
                sunriseISO: sunrise?.safeGet(idx),
                sunsetISO: sunset?.safeGet(idx),
                precipHours: precipitation_hours?.safeGet(idx),
                tMax: temperature_2m_max?.safeGet(idx),
                tMin: temperature_2m_min?.safeGet(idx),
                windSpeedMax: wind_speed_10m_max?.safeGet(idx),
                windGustMax: wind_gusts_10m_max?.safeGet(idx),
                windDirDominant: wind_direction_10m_dominant?.safeGet(idx),
                radiation: shortwave_radiation_sum?.safeGet(idx)
            )
        }
    }
}

private extension Array {
    func safeGet(_ idx: Int) -> Element? {
        guard idx >= 0 && idx < count else { return nil }
        return self[idx]
    }
}

// MARK: - Domain friendly models
struct HourlyPoint: Identifiable {
    let id = UUID()
    let timeISO: String
    let temperature: Double

    var timeDate: Date? { ISO8601Formatter.shared.date(from: timeISO) }
}

struct DailyPoint: Identifiable {
    let id = UUID()
    let dateISO: String
    let sunriseISO: String?
    let sunsetISO: String?
    let precipHours: Double?
    let tMax: Double?
    let tMin: Double?
    let windSpeedMax: Double?
    let windGustMax: Double?
    let windDirDominant: Int?
    let radiation: Double?

    var date: Date? { ISO8601DateOnlyFormatter.shared.date(from: dateISO) }
    var sunrise: Date? { sunriseISO.flatMap { ISO8601Formatter.shared.date(from: $0) } }
    var sunset: Date? { sunsetISO.flatMap { ISO8601Formatter.shared.date(from: $0) } }
}

// Small helpers:
fileprivate class ISO8601Formatter {
    static let shared: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        // The API may omit fractional seconds; try fallback
        return f
    }()

    static func date(from iso: String) -> Date? {
        // try full ISO first, then fallback simple
        if let d = shared.date(from: iso) { return d }
        // fallback without fractional seconds
        let fallback = ISO8601DateFormatter()
        fallback.formatOptions = [.withInternetDateTime]
        return fallback.date(from: iso)
    }
}

fileprivate class ISO8601DateOnlyFormatter {
    static let shared: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()
}

