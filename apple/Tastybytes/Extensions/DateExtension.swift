import SwiftUI

extension Date {
  func formatDateToTimestampTz() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    return dateFormatter.string(from: self)
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
