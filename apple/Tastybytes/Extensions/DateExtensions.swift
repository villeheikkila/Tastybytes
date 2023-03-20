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
        return formatter.localizedString(for: self, relativeTo: Date.now)
      }
    case .timestampTz:
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
      dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
      return dateFormatter.string(from: self)
    case .date:
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
      return dateFormatter.string(from: self)
    }
  }
}

extension Date {
  enum DateParsingError: Error {
    case unsupportedFormat
  }

  init(timestamptzString: String) throws {
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
      throw DateParsingError.unsupportedFormat
    }
  }
}
