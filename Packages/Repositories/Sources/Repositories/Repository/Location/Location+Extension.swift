import Foundation
import Models

extension Location: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name, title, longitude, latitude, country_code, source"

        switch queryType {
        case let .joined(withTableName):
            return buildQuery(.locations, [saved, Country.getQuery(.saved(true))], withTableName)
        case .topLocations:
            return "check_ins_count, \(buildQuery(.locations, [saved], false))"
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
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
