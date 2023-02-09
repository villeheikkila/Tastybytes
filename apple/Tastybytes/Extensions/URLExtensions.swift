import Foundation

extension URLCache {
  static let imageCache = URLCache(memoryCapacity: 512 * 1000 * 1000, diskCapacity: 10 * 1000 * 1000 * 1000)
}

extension URL {
  init(staticString string: StaticString) {
    guard let url = URL(string: "\(string)") else {
      preconditionFailure("Invalid static URL string: \(string)")
    }
    self = url
  }
}

extension URL {
  init(_ string: StaticString) {
    // swiftlint:disable force_unwrapping
    self.init(string: "\(string)")!
  }
}

extension URL {
  init(userId: UUID, avatarUrl: String) {
    let supabaseUrl = Config.supabaseUrl.absoluteString
    let bucketId = "avatars"
    let urlString =
      "\(supabaseUrl)/storage/v1/object/public/\(bucketId)/\(userId.uuidString.lowercased())/\(avatarUrl)"
    self.init(string: "\(urlString)")!
  }
}
