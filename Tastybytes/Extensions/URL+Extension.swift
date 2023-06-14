import Foundation

extension URL {
    init(_ string: StaticString) {
        // swiftlint:disable force_unwrapping
        self.init(string: "\(string)")!
        // swiftlint:enable force_unwrapping
    }
}

extension URL {
    init?(bucketId: String, fileName: String) {
        let urlString = "\(Config.supabaseUrl.absoluteString)/storage/v1/object/public/\(bucketId)/\(fileName)"
        self.init(string: urlString)
    }
}
