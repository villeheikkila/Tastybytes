import Models

extension ImageEntity: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, file, bucket, blur_hash"

        switch queryType {
        case let .saved(tableName):
            if let tableName {
                return buildQuery(tableName, [saved], true)
            } else {
                return saved
            }
        }
    }

    enum QueryType {
        case saved(_ tableName: Database.Table?)
    }
}
