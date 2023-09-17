import Foundation
import Models

public extension URL {
    init?(bucketId: Bucket, fileName: String) {
        let urlString = "\(Config.supabaseUrl.absoluteString)/storage/v1/object/public/\(bucketId.rawValue)/\(fileName)"
        self.init(string: urlString)
    }
}
