import Foundation

extension String? {
  var orEmpty: String {
    self ?? ""
  }
}
