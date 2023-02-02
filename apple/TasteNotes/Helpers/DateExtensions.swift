import Foundation

extension Date {
  func convertDateToString() -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: self)
  }
}

extension Date {
  func relativeTime(in _: Locale = .current) -> String {
    let now = Date.now
    let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)
    if let monthAgo, self < monthAgo {
      return formatted()
    } else {
      let formatter = RelativeDateTimeFormatter()
      formatter.unitsStyle = .full
      return formatter.localizedString(for: self, relativeTo: Date.now)
    }
  }
}
