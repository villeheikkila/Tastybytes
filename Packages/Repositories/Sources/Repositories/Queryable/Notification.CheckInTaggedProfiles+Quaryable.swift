import Models

extension Models.Notification.CheckInTaggedProfiles: Queryable {
    private static let saved = "id"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .checkInTaggedProfiles,
                [saved, CheckIn.getQuery(.joined(true))],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
