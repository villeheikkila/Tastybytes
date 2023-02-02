import Foundation

extension String? {
  var isNilOrEmpty: Bool {
    self == nil || self == ""
  }
}

extension Bool? {
  var isNilOrFalse: Bool {
    self == nil || self == false
  }
}
