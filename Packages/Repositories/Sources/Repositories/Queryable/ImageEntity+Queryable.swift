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

extension ImageEntity.CheckInId: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(
                .checkInImages,
                [ImageEntity.getQuery(.saved(nil)), "check_in_id"],
                withTableName
            )
        case let .product(withTableName):
            buildQuery(
                .checkInImages,
                [ImageEntity.getQuery(.saved(nil)), "check_in_id, check_ins!inner(product_id)"],
                withTableName
            )
        case let .imageDetailed(withTableName):
            buildQuery(
                .checkInImages,
                [
                    ImageEntity.getQuery(.saved(nil)),
                    CheckIn.getQuery(.joined(true)),
                    Report.getQuery(.joined(true)),
                    Profile.getQuery(.minimal(true)),
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case product(_ withTableName: Bool)
        case imageDetailed(_ withTableName: Bool)
    }
}
