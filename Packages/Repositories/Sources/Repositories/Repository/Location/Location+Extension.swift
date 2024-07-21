import Foundation
import Models

extension Location: Queryable {
    private static let saved = "id, name, title, longitude, latitude, country_code, source, map_kit_identifier"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(.locations, [saved, Country.getQuery(.saved(true))], withTableName)
        case let .detailed(withTableName):
            buildQuery(
                .locations,
                [
                    saved,
                    Country.getQuery(.saved(true)),
                    Report.getQuery(.joined(true)),
                    modificationInfoFragment,
                ],
                withTableName
            )
        case .topLocations:
            "check_ins_count, \(buildQuery(.locations, [saved], false))"
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
        case detailed(_ withTableName: Bool)
        case topLocations
    }
}

extension Location.RecentLocation {
    var view: Database.Table {
        switch self {
        case .checkIn:
            .viewRecentLocationsFromCurrentUser
        case .purchase:
            .viewRecentPurchaseLocationsFromCurrentUser
        }
    }
}
