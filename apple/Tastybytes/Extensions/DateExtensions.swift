import Foundation

extension Date {
  func relativeTime() -> String {
    let now = Date.now
    let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)
    let minuteAgo = Calendar.current.date(byAdding: .minute, value: -1, to: now)
    if let minuteAgo, self > minuteAgo {
      return "Just now"
    } else if let monthAgo, self < monthAgo {
      return formatted()
    } else {
      let formatter = RelativeDateTimeFormatter()
      formatter.unitsStyle = .full
      return formatter.localizedString(for: self, relativeTo: Date.now)
    }
  }
}
