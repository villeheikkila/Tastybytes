import Foundation

extension Date {
  enum CustomFormat {
    case fileNameSuffix, relativeTime, timestampTz, date
  }

  func customFormat(_ type: CustomFormat) -> String {
    switch type {
    case .fileNameSuffix:
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy_MM_dd_HH_mm"
      return formatter.string(from: self)
    case .relativeTime:
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
        formatter.locale = Locale(identifier: "en_US")
        return formatter.localizedString(for: self, relativeTo: Date.now)
      }
    case .timestampTz:
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
      formatter.timeZone = TimeZone(abbreviation: "UTC")
      return formatter.string(from: self)
    case .date:
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US")
      formatter.dateFormat = "d MMM yyyy"
      formatter.timeZone = TimeZone(abbreviation: "UTC")
      return formatter.string(from: self)
    }
  }
}

enum DateParsingError: Error {
  case unsupportedFormat
}

extension Date {
  init?(timestamptzString: String) {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

    let formatStrings = [
      "yyyy-MM-dd HH:mm:ss.SSSSSSZZZZZ",
      "yyyy-MM-dd HH:mm:ss.SSSZZZZZ",
      "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
      "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
    ]

    var date: Date?
    for formatString in formatStrings {
      dateFormatter.dateFormat = formatString
      if let parsedDate = dateFormatter.date(from: timestamptzString) {
        date = parsedDate
        break
      }
    }

    if let date {
      self = date
    } else {
      return nil
    }
  }
}
