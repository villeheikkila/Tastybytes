import Foundation

public extension Date {
    var relativeTime: String {
        let now = Date.now
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)
        let minuteAgo = Calendar.current.date(byAdding: .minute, value: -1, to: now)

        if let minuteAgo, self > minuteAgo {
            return "Just now"
        }
        if let monthAgo, self < monthAgo {
            return formatted()
        }

        return formatted(.relative(presentation: .named))
    }
}
