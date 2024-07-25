import Models

extension ImageEntity: Queryable {
    private static let saved = "id, file, bucket, blur_hash, created_at"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(tableName):
            if let tableName {
                buildQuery(tableName, [saved], true)
            } else {
                saved
            }
        }
    }

    enum QueryType {
        case saved(_ tableName: Database.Table?)
    }
}
