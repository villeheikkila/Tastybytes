import Foundation

public struct CustomRelativeTimeFormat: FormatStyle {
    public func format(_ value: Date) -> String {
        let now = Date.now
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)
        let minuteAgo = Calendar.current.date(byAdding: .minute, value: -1, to: now)

        if let minuteAgo, value > minuteAgo {
            return String(localized: "Just now")
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
