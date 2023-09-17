import Foundation

extension URL {
    init?(bucketId: String, fileName: String) {
        let urlString = "\(Config.supabaseUrl.absoluteString)/storage/v1/object/public/\(bucketId)/\(fileName)"
        self.init(string: urlString)
    }
}
