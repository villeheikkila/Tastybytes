import Models

extension Logo: Queryable {
    private static let saved = "id, file, bucket, label, blur_hash, created_at"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.logos, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
