import Models

extension ImageEntity {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, file, bucket"

        switch queryType {
        case let .saved(tableName):
            return queryWithTableName(tableName.rawValue, saved, true)
        }
    }

    enum QueryType {
        case saved(_ tableName: Database.Table)
    }
}
