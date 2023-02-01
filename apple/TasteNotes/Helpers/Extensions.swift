import SwiftUI

extension Array where Element: Equatable {
  mutating func remove(object: Element) {
    guard let index = firstIndex(of: object) else { return }
    remove(at: index)
  }
}

extension URLCache {
  static let imageCache = URLCache(memoryCapacity: 512 * 1000 * 1000, diskCapacity: 10 * 1000 * 1000 * 1000)
}

public extension Array where Element: Equatable {
  mutating func replace(_ element: Element, with new: Element) {
    if let toReplace = firstIndex(where: { $0 == element }) {
      self[toReplace] = new
    }
  }
}

extension URL {
  init(staticString string: StaticString) {
    guard let url = URL(string: "\(string)") else {
      preconditionFailure("Invalid static URL string: \(string)")
    }
    self = url
  }
}

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
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return formatter.localizedString(for: self, relativeTo: Date())
  }
}
