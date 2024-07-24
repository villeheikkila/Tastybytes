import Foundation
import Models

extension CheckIn.Comment: Queryable {
    private static let saved = "id, content"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joinedProfile(withTableName):
            buildQuery(.checkInComments, [saved, "created_at", buildQuery(name: "profiles", foreignKey: "created_by", [Profile.getQuery(.minimal(false))])], withTableName)
        case let .joinedCheckIn(withTableName):
            buildQuery(
                .checkInComments,
                [
                    saved,
                    "created_at",
                    buildQuery(name: "profiles", foreignKey: "created_by", [Profile.getQuery(.minimal(false))]),
                    CheckIn.getQuery(.joined(true)),
                ],
                withTableName
            )
        case let .detailed(withTableName):
            buildQuery(
                .checkInComments,
                [saved, CheckIn.getQuery(.joined(true)), Report.getQuery(.joined(true)), modificationInfoFragment],
                withTableName
            )
        }
    }

    enum QueryType {
        case joinedProfile(_ withTableName: Bool)
        case joinedCheckIn(_ withTableName: Bool)
        case detailed(_ withTableName: Bool)
    }
}
