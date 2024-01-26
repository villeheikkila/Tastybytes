import Models

extension ImageEntity {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, file, bucket"

        switch queryType {
        case let .saved(tableName):
            if let tableName {
                return queryWithTableName(tableName.rawValue, saved, true)
            } else {
                return queryWithTableName("", saved, false)
            }
        }
    }

    enum QueryType {
        case saved(_ tableName: Database.Table?)
    }
}
