import Foundation

extension Array where Element: Equatable {
  mutating func remove(object: Element) {
    guard let index = firstIndex(of: object) else { return }
    remove(at: index)
  }
}

public extension Array where Element: Equatable {
  mutating func replace(_ element: Element, with new: Element) {
    if let toReplace = firstIndex(where: { $0 == element }) {
      self[toReplace] = new
    }
  }
}
