import Foundation
import Models

func queryWithTableName(_ tableName: String, _ query: String, _ withTableName: Bool) -> String {
    withTableName ? "\(tableName) (\(query))" : query
}

public extension URL {
    init?(bucketId: Database.Bucket, fileName: String) {
        let urlString = "\(Config.supabaseUrl.absoluteString)/storage/v1/object/public/\(bucketId)/\(fileName)"
        self.init(string: urlString)
    }
}
