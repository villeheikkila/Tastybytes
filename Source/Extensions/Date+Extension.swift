import Foundation

public struct CustomRelativeTimeFormat: FormatStyle {
    public func format(_ value: Date) -> String {
        let now = Date.now
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)
        let minuteAgo = Calendar.current.date(byAdding: .minute, value: -1, to: now)

        if let minuteAgo, value > minuteAgo {
            return String(localized: "customRelativeTimeFormat.justNow")
        }
        if let monthAgo, value < monthAgo {
            return value.formatted()
        }

        return value.formatted(.relative(presentation: .named))
    }
}

public extension FormatStyle where Self == CustomRelativeTimeFormat {
    static var customRelativetime: CustomRelativeTimeFormat { .init() }
}

public extension ClosedRange where Bound == Date {
    func dates(byAdding component: Calendar.Component, using calendar: Calendar = .current) -> [Date] {
        var dates: [Date] = []
        var date = lowerBound
        while date <= upperBound {
            dates.append(date)
            if let nextDate = calendar.date(byAdding: component, value: 1, to: date) {
                date = nextDate
            } else {
                break
            }
        }
        return dates
    }
}
