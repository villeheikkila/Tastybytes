import Foundation
import Models

extension Profile: Queryable {
    private static let minimal = "id, is_private, preferred_name, joined_at"
    private static let saved =
        "id, first_name, last_name, username, name_display, preferred_name, is_private, is_onboarded, joined_at"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .minimal(withTableName):
            buildQuery(.profiles, [minimal, ImageEntity.getQuery(.saved(.profileAvatars))], withTableName)
        case let .extended(withTableName):
            buildQuery(
                .profiles,
                [saved, Profile.Settings.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.profileAvatars))],
                withTableName
            )
        case let .detailed(withTableName):
            buildQuery(
                .profiles,
                [
                    saved,
                    Role.getQuery(.joined(true)),
                    ImageEntity.getQuery(.saved(.profileAvatars)),
                    buildQuery(name: "reports", foreignKey: "reports_profile_id_fkey", [Report.getQuery(.joined(false))]),
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case minimal(_ withTableName: Bool)
        case extended(_ withTableName: Bool)
        case detailed(_ withTableName: Bool)
    }
}
