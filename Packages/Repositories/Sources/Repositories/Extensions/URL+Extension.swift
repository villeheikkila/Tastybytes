import Foundation
import Models

public extension URL {
    init?(bucket: Bucket, fileName: String) {
        let urlString = "\(Config.supabaseUrl.absoluteString)/storage/v1/object/public/\(bucket.rawValue)/\(fileName)"
        self.init(string: urlString)
    }
}
