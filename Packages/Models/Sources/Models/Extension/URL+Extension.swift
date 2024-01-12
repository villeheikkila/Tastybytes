import Foundation

public extension URL {
    init?(baseUrl: URL, bucket: Bucket, fileName: String) {
        let urlString = "\(baseUrl)/storage/v1/object/public/\(bucket.rawValue)/\(fileName)"
        self.init(string: urlString)
    }
}
