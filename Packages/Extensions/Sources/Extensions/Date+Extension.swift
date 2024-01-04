import Foundation

public class CustomDateFormatter {
    public enum Format {
        case fileNameSuffix, relativeTime, timestampTz, date
    }

    public static let shared = CustomDateFormatter()
    private let formatter = DateFormatter()

    public func format(date: Date, _ type: Format) -> String {
        switch type {
        case .fileNameSuffix:
            formatter.dateFormat = "yyyy_MM_dd_HH_mm"
            return formatter.string(from: date)
        case .relativeTime:
            let now = Date.now
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)
            let minuteAgo = Calendar.current.date(byAdding: .minute, value: -1, to: now)
            if let minuteAgo, date > minuteAgo {
                return "Just now"
            } else if let monthAgo, date < monthAgo {
                return date.formatted()
            } else {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .full
                formatter.locale = Locale(identifier: "en_US")
                return formatter.localizedString(for: date, relativeTo: Date.now)
            }
        case .timestampTz:
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter.string(from: date)
        case .date:
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "d MMM yyyy"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter.string(from: date)
        }
    }
}

public extension Date {
    func customFormat(_ type: CustomDateFormatter.Format) -> String {
        CustomDateFormatter.shared.format(date: self, type)
    }
}
